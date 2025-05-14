;; ---- Constants ----
(define-constant ERR-OUT-OF-BOUNDS u104)
(define-constant ERR_TX_VALUE_TOO_SMALL (err u105))
(define-constant ERR_TX_NOT_FOR_RECEIVER (err u106))
(define-constant ERR_NOT_PROCESSED (err u107))
(define-constant ERR_BTC_TX_ALREADY_USED (err u109)) 
(define-constant ERR_IN_COOLDOWN (err u110))
(define-constant ERR_FORBIDDEN (err u114))
(define-constant ERR_AMOUNT_NULL (err u115))
(define-constant ERR_INSUFFICIENT_POOL_BALANCE (err u132))
(define-constant ERR_NATIVE_FAILURE (err u99)) 
(define-constant ERR-TRANSACTION-SEGWIT (err u130))
(define-constant ERR-TRANSACTION (err u131))
(define-constant ERR-ELEMENT-EXPECTED (err u129))

(define-constant FEE-RECEIVER 'SMHAVPYZ8BVD0BHBBQGY5AQVVGNQY4TNHAKGPYP)
(define-constant OPERATOR_STYX 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE) 
(define-constant COOLDOWN u6)
(define-constant MIN_SATS u10000) ;; min 10k satoshis 0.0001
(define-constant FIXED_FEE u2000)

;; ---- Data structures ----

;; Counter for processed transactions
(define-data-var processed-tx-count uint u0)

;; Pool structure to track sBTC liquidity (single pool per contract)
(define-data-var pool 
  {
    total-sbtc: uint, ;; Total sBTC amount originally deposited
    available-sbtc: uint,
    btc-receiver: (buff 40), ;; BTC address of the operator
    last-updated: uint
  }
  {
    total-sbtc: u0,
    available-sbtc: u0,
    btc-receiver: 0x0000000000000000000000000000000000000000,
    last-updated: u0
  }
)

;; Track processed BTC transactions
(define-map processed-btc-txs 
  (buff 128)  ;; BTC transaction ID
  {
    btc-amount: uint,
    sbtc-amount: uint,
    stx-receiver: principal,
    processed-at: uint,
    tx-number: uint
  }
)

;; ---- Helper functions ----

;; Read 32-bit unsigned integer in little-endian format
(define-read-only (read-uint32 (ctx { txbuff: (buff 4096), index: uint}))
		(let ((data (get txbuff ctx))
					(base (get index ctx)))
				(ok {uint32: (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap! (slice? data base (+ base u4)) (err ERR-OUT-OF-BOUNDS)) u4))),
						 ctx: { txbuff: data, index: (+ u4 base)}})))

;; Find output in BTC transaction for a given address
(define-private (find-out (entry {scriptPubKey: (buff 128), value: (buff 8)}) (result {pubscriptkey: (buff 40), out: (optional {scriptPubKey: (buff 128), value: uint})}))
  (if (is-eq (get scriptPubKey entry) (get pubscriptkey result))
    (merge result {out: (some {scriptPubKey: (get scriptPubKey entry), value: (get uint32 (unwrap-panic (read-uint32 {txbuff: (get value entry), index: u0})))})})
    result))

;; Get BTC output value for a given address
(define-public (get-out-value (tx {
    version: (buff 4),
    ins: (list 8
      {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
    outs: (list 8
      {value: (buff 8), scriptPubKey: (buff 128)}),
    locktime: (buff 4)}) (pubscriptkey (buff 40)))
    (ok (fold find-out (get outs tx) {pubscriptkey: pubscriptkey, out: none})))

;; ---- Pool initialization ----

;; Initialize or add liquidity to pool
(define-public (add-liquidity-to-pool (sbtc-amount uint) (btc-receiver (optional (buff 40))))
  (let (
        (current-pool (var-get pool))
        (this-bitcoin-receiver (default-to (get btc-receiver current-pool) btc-receiver))
        (new-total (+ (get total-sbtc current-pool) sbtc-amount))
        (new-available (+ (get available-sbtc current-pool) sbtc-amount))
      )
    ;; Verify caller is the operator
    (asserts! (is-eq tx-sender OPERATOR_STYX) ERR_FORBIDDEN)
    
    ;; Verify parameters
    (asserts! (> sbtc-amount u0) ERR_AMOUNT_NULL)
    
    ;; Transfer sBTC to contract
    (match (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                transfer sbtc-amount tx-sender (as-contract tx-sender) none)
      success 
      (begin
        ;; Update pool - set or update BTC receiver if provided
        (var-set pool (merge current-pool 
                  {
                    total-sbtc: new-total,
                    available-sbtc: new-available,
                    btc-receiver: this-bitcoin-receiver,
                    last-updated: burn-block-height
                  }))
        
        (print {
          type: "add-liquidity",
          operator: tx-sender,
          sbtc: sbtc-amount,
          btc-receiver: this-bitcoin-receiver,
          total-sbtc: new-total,
          available-sbtc: new-available,
          last-updated: burn-block-height
        })
        (ok true)
      )
      error (err (* error u1000))
    )
  )
)

;; Withdraw remaining sBTC from pool (operator only)
(define-public (withdraw-from-pool)
  (let (
        (current-pool (var-get pool))
        (available-sbtc (get available-sbtc current-pool))
      )
    ;; Verify caller is the operator
    (asserts! (is-eq tx-sender OPERATOR_STYX) ERR_FORBIDDEN)
    
    ;; Verify there is available balance
    (asserts! (> available-sbtc u0) ERR_INSUFFICIENT_POOL_BALANCE)
    
    ;; Update pool - set available to 0
    (var-set pool (merge current-pool { available-sbtc: u0 }))
    
    ;; Transfer sBTC to operator
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
            transfer available-sbtc tx-sender OPERATOR_STYX none)))
    
    (print {
      type: "withdraw-from-pool",
      sbtc-amount: available-sbtc
    })
    
    (ok available-sbtc)
  )
)

;; ---- BTC processing functions ----

;; Parse the payload from a segwit transaction
(define-read-only (parse-payload-segwit (tx (buff 4096)))
  (match (get-output-segwit tx u0)
    result
    (let
      (
        (script (get scriptPubKey result))
        (script-len (len script))
        ;; lenght is dynamic one or two bytes!
        (offset (if (is-eq (unwrap! (element-at? script u1) ERR-ELEMENT-EXPECTED) 0x4C) u3 u2)) 
        (payload (unwrap! (slice? script offset script-len) ERR-ELEMENT-EXPECTED))
      )
      (ok (from-consensus-buff? { p: principal } payload))
    )
    not-found ERR-ELEMENT-EXPECTED
  )
)

;; Get output from a segwit transaction
(define-read-only (get-output-segwit (tx (buff 4096)) (index uint))
  (let
    (
      (parsed-tx (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 parse-wtx tx false))
    )
    (match parsed-tx
      result
      (let
        (
          (tx-data (unwrap-panic parsed-tx)) 
          (outs (get outs tx-data)) 
          (out (unwrap! (element-at? outs index) ERR-TRANSACTION-SEGWIT))
          (scriptPubKey (get scriptPubKey out))
          (value (get value out)) 
        )
        (ok { scriptPubKey: scriptPubKey, value: value })
      )
      missing ERR-TRANSACTION
    )
  )
)

;; Process a BTC deposit and release sBTC - can be called by anyone
(define-public (process-btc-deposit
    (height uint) 
    (wtx {version: (buff 4),
      ins: (list 8
        {outpoint: {hash: (buff 32), index: (buff 4)}, scriptSig: (buff 256), sequence: (buff 4)}),
      outs: (list 8
        {value: (buff 8), scriptPubKey: (buff 128)}),
      locktime: (buff 4)})
    (witness-data (buff 1650))
    (header (buff 80)) 
    (tx-index uint) 
    (tree-depth uint) 
    (wproof (list 14 (buff 32))) 
    (witness-merkle-root (buff 32)) 
    (witness-reserved-value (buff 32)) 
    (ctx (buff 1024)) 
    (cproof (list 14 (buff 32)))) 
  (let (
        (current-pool (var-get pool))
        (tx-buff (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v1 concat-wtx wtx witness-data))
      )
    
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN)) ERR_IN_COOLDOWN)

    ;; Verify Bitcoin transaction proof
    (match (contract-call? 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v5 was-segwit-tx-mined-compact
                    height 
                    tx-buff 
                    header 
                    tx-index 
                    tree-depth 
                    wproof 
                    witness-merkle-root 
                    witness-reserved-value 
                    ctx 
                    cproof)
      result
        (begin
          ;; Verify transaction is not already used
          (asserts! (is-none (map-get? processed-btc-txs result)) ERR_BTC_TX_ALREADY_USED)
          
          ;; Verify BTC was sent to correct address
          (match (get out (unwrap! (get-out-value wtx (get btc-receiver current-pool)) ERR_NATIVE_FAILURE))
            out (if (>= (get value out) MIN_SATS)
              (let (
                    (btc-amount (get value out))
                    (payload (unwrap! (parse-payload-segwit tx-buff) ERR-ELEMENT-EXPECTED))
                    (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                    (sbtc-amount-out (- btc-amount FIXED_FEE))
                    (available-sbtc (get available-sbtc current-pool))
                    (current-count (var-get processed-tx-count))
                   ) 
                   
                   ;; Verify sufficient balance in pool
                   (asserts! (<= btc-amount available-sbtc) ERR_INSUFFICIENT_POOL_BALANCE)
                   
                   ;; Record processed transaction
                   (map-set processed-btc-txs result 
                     {
                       btc-amount: btc-amount,
                       sbtc-amount: sbtc-amount-out,
                       stx-receiver: stx-receiver,
                       processed-at: burn-block-height,
                       tx-number: current-count
                     })
                    
                    (var-set processed-tx-count (+ current-count u1))

                   ;; Update pool's available balance
                   (var-set pool 
                     (merge current-pool 
                       { available-sbtc: (- available-sbtc btc-amount) }
                     ))
                   
                   ;; Transfer fee to fee receiver
                   (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                             transfer FIXED_FEE tx-sender FEE-RECEIVER none)))
                   
                   ;; Transfer sBTC to user
                   (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token 
                             transfer sbtc-amount-out tx-sender stx-receiver none)))
                   
                   (print {
                     type: "process-btc-deposit",
                     btc-tx-id: result,
                     btc-amount: btc-amount,
                     sbtc-amount-out: sbtc-amount-out,
                     stx-receiver: stx-receiver,
                     processor: tx-sender
                   })
                   
                   (ok true))
            ERR_TX_VALUE_TOO_SMALL)
            ERR_TX_NOT_FOR_RECEIVER))
      error (err (* error u1000))))
)

;; ---- Read-only functions ----

;; Get pool information
(define-read-only (get-pool)
  (ok (var-get pool)))

;; Check if a transaction has been processed
(define-read-only (is-tx-processed (tx-id (buff 128)))
  (is-some (map-get? processed-btc-txs tx-id)))

;; Get transaction details
(define-read-only (get-processed-tx (tx-id (buff 128)))
  (match (map-get? processed-btc-txs tx-id)
    tx-info (ok tx-info)
    (err ERR_NOT_PROCESSED)))