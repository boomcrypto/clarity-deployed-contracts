(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait) 
(use-trait faktory-pre 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B.prelaunch-faktory-trait.prelaunch-trait)
(use-trait faktory-dex 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.faktory-dex-trait.dex-trait) 
(use-trait bitflow-pool 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)

(define-constant ERR-OUT-OF-BOUNDS u104)
(define-constant ERR_TX_VALUE_TOO_SMALL (err u105))
(define-constant ERR_TX_NOT_SENT_TO_POOL (err u106))
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
(define-constant ERR_NOT_SIGNALED (err u133))
(define-constant ERR_IN_COOLOFF (err u134))
(define-constant ERR_INVALID_STX_RECEIVER (err u135))
(define-constant ERR_INVALID_ID (err u136))
(define-constant ERR_ALREADY_DONE (err u137))
(define-constant ERR_DEPOSIT_TOO_LARGE (err u138))
(define-constant ERR_FEE_TOO_LARGE (err u139))
(define-constant ERR_TOO_MUCH_SLIPPAGE (err u140))
(define-constant ERR-WRONG-DEX (err u141))
(define-constant ERR-WRONG-AI-ACCOUNT (err u142))



(define-constant ERR_NOT_APPROVER (err u143))
(define-constant ERR_PROPOSAL_EXPIRED (err u144))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u145))
(define-constant ERR_ALREADY_SIGNALED (err u146))
(define-constant ERR_INSUFFICIENT_SIGNALS (err u147))
(define-constant ERR_PROPOSAL_EXECUTED (err u148))
(define-constant ERR-DEX-NOT-ALLOWED (err u149))
(define-constant ERR-GET-CONFIG (err u150))
(define-constant ERR-GET-QUOTE (err u151))
(define-constant ERR-WRONG-FT (err u152))
(define-constant ERR-WRONG-POOL (err u153))
(define-constant ERR-GET-BONDED (err u154))
(define-constant ERR-WRONG-SBTC (err u155))
(define-constant ERR-NO-AI-ACCOUNT (err u156)) 
(define-constant ERR-GET-MARKET (err u157))
(define-constant ERR-WRONG-PRE (err u158))

(define-constant APPROVAL_WINDOW u1008) ;; 7 days * 144 blocks/day
(define-constant SIGNALS_REQUIRED u2)   ;; 3 out of 5

(define-constant OPERATOR_STYX 'SP12HZDARME0G89TYPA6Q5KPP5N7W04F65VPXS988) ;; only 1 pool per operator else double spending 
(define-constant SERVICE_STYX 'SMH8FRN30ERW1SX26NJTJCKTDR3H27NRJ6W75WQE) ;; amend it for mainnet Rafa
(define-constant SBTC_CONTRACT 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant COOLDOWN u6)
(define-constant MIN_SATS u10000)
(define-constant MAX_SLIPPAGE u200000)
(define-constant FIXED_FEE u21000)
(define-constant WITHDRAWAL_COOLOFF u144)

(define-constant PRECISION u1000000)


(define-constant PRICE-PER-SEAT u20000)

;; ---- Data structures ----
(define-data-var current-operator principal OPERATOR_STYX)

(define-data-var processed-tx-count uint u1)

(define-data-var pool {
  total-sbtc: uint,
  available-sbtc: uint,
  btc-receiver: (buff 40),
  last-updated: uint,
  withdrawal-signaled-at: (optional uint),
  max-deposit: uint,
  min-fee: uint,
  add-liq-signaled-at: (optional uint),
  set-param-signaled-at: (optional uint),
} {
  total-sbtc: u0,
  available-sbtc: u0,
  btc-receiver: 0x0000000000000000000000000000000000000000,
  last-updated: u0,
  withdrawal-signaled-at: none,
  max-deposit: u1000000000,
  min-fee: u3000,
  add-liq-signaled-at: none,
  set-param-signaled-at: none,
})

(define-map processed-btc-txs
  (buff 128)
  {
    btc-amount: uint,
    sbtc-amount: uint,
    stx-receiver: principal,
    processed-at: uint,
    tx-number: uint,
  }
)

(define-data-var is-initialized bool false)

(define-data-var next-proposal-id uint u1)

;; ---- Allow list mechanism ----
;;
(define-read-only (is-approver (who principal))
  (or 
    (is-eq who 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22)
    (is-eq who 'SP2BK886SQQPSQHJGJ8T1B3NQXG9V9F5EDTR7F7X4)
    (is-eq who 'SP2Z94F6QX847PMXTPJJ2ZCCN79JZDW3PJ4E6ZABY)      
    (is-eq who 'SP2GHGQRWSTM89SQMZXTQJ0GRHV93MSX9J84J7BEA)
  )
)

(define-map allowlist-proposals
  uint
  {
    ft-contract: principal,
    pre-contract: principal,
    dex-contract: principal,
    pool-contract: principal,
    proposed-at: uint,
    signals: uint,
    executed: bool
  }
)

(define-map proposal-signals
  { proposal-id: uint, approver: principal }
  bool
)

(define-map allowed-dexes uint { 
  ft-contract: principal, 
  pre-contract: principal,
  dex-contract: principal,
  pool-contract: principal
})

(define-public (propose-allowlist-dexes 
    (ft-contract <faktory-token>) 
    (pre-contract <faktory-pre>)
    (dex-contract <faktory-dex>)
    (pool-contract <bitflow-pool>)
  )
  (let ((proposal-id (var-get next-proposal-id)))
    (asserts! (is-approver tx-sender) ERR_NOT_APPROVER)
    
    (map-set allowlist-proposals proposal-id { 
      ft-contract: (contract-of ft-contract),
      pre-contract: (contract-of pre-contract),
      dex-contract: (contract-of dex-contract),
      pool-contract: (contract-of pool-contract),
      proposed-at: burn-block-height,
      signals: u1,
      executed: false
    })
    
    (map-set proposal-signals { proposal-id: proposal-id, approver: tx-sender } true)
    (var-set next-proposal-id (+ proposal-id u1))
    
    (print {
      type: "allowlist-proposal",
      proposal-id: proposal-id,
      ft-contract: (contract-of ft-contract),
      pre-contract: (contract-of pre-contract),
      dex-contract: (contract-of dex-contract),
      pool-contract: (contract-of pool-contract),
      proposer: tx-sender
    })
    
    (ok proposal-id)
  )
)

(define-public (signal-allowlist-approval (proposal-id uint))
  (let (
    (proposal (unwrap! (map-get? allowlist-proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
    (current-signals (get signals proposal))
  )
    (asserts! (is-approver tx-sender) ERR_NOT_APPROVER)
    (asserts! (not (get executed proposal)) ERR_PROPOSAL_EXECUTED)
    (asserts! (<= burn-block-height (+ (get proposed-at proposal) APPROVAL_WINDOW)) ERR_PROPOSAL_EXPIRED)
    (asserts! (is-none (map-get? proposal-signals { proposal-id: proposal-id, approver: tx-sender })) ERR_ALREADY_SIGNALED)
    
    (let ((new-signals (+ current-signals u1)))
      (map-set proposal-signals { proposal-id: proposal-id, approver: tx-sender } true)
      (map-set allowlist-proposals proposal-id
        (merge proposal { signals: new-signals })
      )
      
      ;; Auto-execute if we have enough signals
      (if (>= new-signals SIGNALS_REQUIRED)
        (begin
          ;; Store all four contracts using proposal-id as the key
          (map-set allowed-dexes proposal-id {
            ft-contract: (get ft-contract proposal),
            pre-contract: (get pre-contract proposal),
            dex-contract: (get dex-contract proposal),
            pool-contract: (get pool-contract proposal)
          })
          
          (map-set allowlist-proposals proposal-id
            (merge proposal { signals: new-signals, executed: true }) 
          )
          (print {
            type: "allowlist-approved",
            proposal-id: proposal-id,
            ft-contract: (get ft-contract proposal),
            pre-contract: (get pre-contract proposal),
            dex-contract: (get dex-contract proposal),
            pool-contract: (get pool-contract proposal),
            signals: new-signals
          })
        )
        (print {
          type: "allowlist-signal",
          proposal-id: proposal-id,
          ft-contract: (get ft-contract proposal),
          pre-contract: (get pre-contract proposal),
          dex-contract: (get dex-contract proposal),
          pool-contract: (get pool-contract proposal),
          signals: new-signals
        })
      )
      
      (ok new-signals)
    )
  )
)

;; Emergency pause flag - one way only
(define-data-var swaps-paused bool false)

;; Emergency stop - any approver can pause swaps permanently
(define-public (emergency-stop-swaps)
  (begin
    (asserts! (is-approver tx-sender) ERR_NOT_APPROVER)
    (asserts! (not (var-get swaps-paused)) ERR_ALREADY_DONE)
    (var-set swaps-paused true)
    (print {
      type: "emergency-stop",
      stopped-by: tx-sender,
      block-height: burn-block-height
    })
    (ok true)
  )
)

;; Read-only function to check pause status
(define-read-only (are-swaps-paused)
  (var-get swaps-paused)
)

(define-read-only (get-dex-allowed (dex-id uint))
  (map-get? allowed-dexes dex-id)
)

(define-read-only (get-allowlist-proposal (proposal-id uint))
  (map-get? allowlist-proposals proposal-id)
)

(define-read-only (has-signaled (proposal-id uint) (approver principal))
  (default-to false (map-get? proposal-signals { proposal-id: proposal-id, approver: approver }))
)

;; ---- Helper functions ----
(define-read-only (read-uint64 (ctx {
  txbuff: (buff 4096),
  index: uint,
}))
  (let (
      (data (get txbuff ctx))
      (base (get index ctx))
    )
    (ok {
      uint64: (buff-to-uint-le (unwrap-panic (as-max-len?
        (unwrap! (slice? data base (+ base u8)) (err ERR-OUT-OF-BOUNDS)) u8
      ))),
      ctx: {
        txbuff: data,
        index: (+ u8 base),
      },
    })
  )
)

(define-private (find-out
    (entry {
      scriptPubKey: (buff 1376),
      value: (buff 8),
    })
    (result {
      pubscriptkey: (buff 1376),
      out: (optional {
        scriptPubKey: (buff 1376),
        value: uint,
      }),
    })
  )
  (if (is-eq (get scriptPubKey entry) (get pubscriptkey result))
    (merge result { out: (some {
      scriptPubKey: (get scriptPubKey entry),
      value: (get uint64
        (unwrap-panic (read-uint64 {
          txbuff: (get value entry),
          index: u0,
        }))
      ),
    }) }
    )
    result
  )
)

(define-public (get-out-value
    (tx {
      version: (buff 4),
      ins: (list 50 {
        outpoint: {
          hash: (buff 32),
          index: (buff 4),
        },
        scriptSig: (buff 1376),
        sequence: (buff 4),
      }),
      outs: (list 50 {
        value: (buff 8),
        scriptPubKey: (buff 1376),
      }),
      locktime: (buff 4),
    })
    (pubscriptkey (buff 1376))
  )
  (ok (fold find-out (get outs tx) {
    pubscriptkey: pubscriptkey,
    out: none,
  }))
)

;; ---- Pool initialization ----
(define-public (set-new-operator (new-operator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (var-set current-operator new-operator)
    (print {
      type: "set-new-operator",
      old-operator: tx-sender,
      new-operator: new-operator,
      when: burn-block-height,
    })
    (ok true)
  )
)

(define-public (signal-add-liquidity)
  (let ((current-pool (var-get pool)))
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (var-set pool
      (merge current-pool { add-liq-signaled-at: (some burn-block-height) })
    )
    (print {
      type: "signal-add-liquidity",
      signaled-at: burn-block-height,
    })
    (ok true)
  )
)

(define-public (signal-set-params)
  (let ((current-pool (var-get pool)))
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (var-set pool
      (merge current-pool { set-param-signaled-at: (some burn-block-height) })
    )
    (print {
      type: "signal-set-params",
      signaled-at: burn-block-height,
    })
    (ok true)
  )
)

(define-public (add-liquidity-to-pool
    (sbtc-amount uint)
    (btc-receiver (optional (buff 40)))
  )
  (let (
      (current-pool (var-get pool))
      (this-bitcoin-receiver (default-to (get btc-receiver current-pool) btc-receiver))
      (new-total (+ (get total-sbtc current-pool) sbtc-amount))
      (new-available (+ (get available-sbtc current-pool) sbtc-amount))
      (signaled-at (default-to u0 (get add-liq-signaled-at current-pool)))
    )
    (asserts! (not (is-eq signaled-at u0)) ERR_NOT_SIGNALED)
    (asserts! (> burn-block-height (+ signaled-at COOLDOWN)) ERR_IN_COOLDOWN)
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> sbtc-amount u0) ERR_AMOUNT_NULL)
    (match (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer sbtc-amount tx-sender (as-contract tx-sender) none
    )
      success (begin
        (var-set pool
          (merge current-pool {
            total-sbtc: new-total,
            available-sbtc: new-available,
            btc-receiver: this-bitcoin-receiver,
            last-updated: burn-block-height,
            add-liq-signaled-at: none,
          })
        )
        (print {
          type: "add-liquidity",
          operator: tx-sender,
          sbtc: sbtc-amount,
          btc-receiver: this-bitcoin-receiver,
          total-sbtc: new-total,
          available-sbtc: new-available,
          last-updated: burn-block-height,
        })
        (ok true)
      )
      error (err (* error u1000))
    )
  )
)

;; this func without cool downs only adds liquidity - reserved
(define-public (add-only-liquidity (sbtc-amount uint))
  (let (
      (current-pool (var-get pool))
      (new-total (+ (get total-sbtc current-pool) sbtc-amount))
      (new-available (+ (get available-sbtc current-pool) sbtc-amount))
    )
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> sbtc-amount u0) ERR_AMOUNT_NULL)
    (match (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer sbtc-amount tx-sender (as-contract tx-sender) none
    )
      success (begin
        (var-set pool
          (merge current-pool {
            total-sbtc: new-total,
            available-sbtc: new-available,
          })
        )
        (print {
          type: "add-liquidity",
          operator: tx-sender,
          sbtc: sbtc-amount,
          total-sbtc: new-total,
          available-sbtc: new-available,
        })
        (ok true)
      )
      error (err (* error u1000))
    )
  )
)

(define-public (set-params
    (new-max-deposit uint)
    (min-fee uint)
  )
  (let (
      (current-pool (var-get pool))
      (signaled-at (default-to u0 (get set-param-signaled-at current-pool)))
    )
    (asserts! (not (is-eq signaled-at u0)) ERR_NOT_SIGNALED)
    (asserts! (> burn-block-height (+ signaled-at COOLDOWN)) ERR_IN_COOLDOWN)
    (asserts! (<= min-fee FIXED_FEE) ERR_FEE_TOO_LARGE)
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> new-max-deposit MIN_SATS) ERR_AMOUNT_NULL)
    (var-set pool
      (merge current-pool {
        last-updated: burn-block-height,
        max-deposit: new-max-deposit,
        min-fee: min-fee,
        set-param-signaled-at: none,
      })
    )
    (print {
      type: "set-max-deposit",
      max-deposit: new-max-deposit,
      min-fee: min-fee,
      set-param-signaled-at: none,
      last-updated: burn-block-height,
    })
    (ok true)
  )
)

(define-public (signal-withdrawal)
  (let ((current-pool (var-get pool)))
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> (get available-sbtc current-pool) u0)
      ERR_INSUFFICIENT_POOL_BALANCE
    )
    (var-set pool
      (merge current-pool { withdrawal-signaled-at: (some burn-block-height) })
    )
    (print {
      type: "signal-withdrawal",
      withdrawal-signaled-at: burn-block-height,
    })
    (ok true)
  )
)

(define-public (withdraw-from-pool)
  (let (
      (current-pool (var-get pool))
      (available-sbtc (get available-sbtc current-pool))
    )
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> available-sbtc u0) ERR_INSUFFICIENT_POOL_BALANCE)
    (match (get withdrawal-signaled-at current-pool)
      some-height (begin
        (asserts! (> burn-block-height (+ some-height WITHDRAWAL_COOLOFF))
          ERR_IN_COOLOFF
        )
        (var-set pool
          (merge current-pool {
            available-sbtc: u0,
            withdrawal-signaled-at: none,
          })
        )
        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          transfer available-sbtc tx-sender (var-get current-operator) none
        )))
        (print {
          type: "withdraw-from-pool",
          sbtc-amount: available-sbtc,
        })
        (ok available-sbtc)
      )
      ERR_NOT_SIGNALED
    )
  )
)

;; ---- BTC processing functions ----
(define-read-only (parse-payload-segwit (tx (buff 4096)))
  (match (get-output-segwit tx u0)
    result (let (
        (script (get scriptPubKey result))
        (script-len (len script))
        (offset (if (is-eq (unwrap! (element-at? script u1) ERR-ELEMENT-EXPECTED) 0x4c)
          u3
          u2
        ))
        (payload (unwrap! (slice? script offset script-len) ERR-ELEMENT-EXPECTED))
      )
      (ok (from-consensus-buff? { p: principal, a: uint, d: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (parse-payload-segwit-refund (tx (buff 4096)))
  (match (get-output-segwit tx u0)
    result (let (
        (script (get scriptPubKey result))
        (script-len (len script))
        (offset (if (is-eq (unwrap! (element-at? script u1) ERR-ELEMENT-EXPECTED) 0x4c)
          u3
          u2
        ))
        (payload (unwrap! (slice? script offset script-len) ERR-ELEMENT-EXPECTED))
      )
      (ok (from-consensus-buff? { i: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (get-output-segwit
    (tx (buff 4096))
    (index uint)
  )
  (let ((parsed-tx (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      parse-wtx tx false
    )))
    (match parsed-tx
      result (let (
          (tx-data (unwrap-panic parsed-tx))
          (outs (get outs tx-data))
          (out (unwrap! (element-at? outs index) ERR-TRANSACTION-SEGWIT))
          (scriptPubKey (get scriptPubKey out))
          (value (get value out))
        )
        (ok {
          scriptPubKey: scriptPubKey,
          value: value,
        })
      )
      missing
      ERR-TRANSACTION
    )
  )
)

(define-read-only (parse-payload-legacy (tx (buff 4096)))
  (match (get-output-legacy tx u0)
    parsed-result (let (
        (script (get scriptPubKey parsed-result))
        (script-len (len script))
        ;; lenght is dynamic one or two bytes!
        (offset (if (is-eq (unwrap! (element-at? script u1) ERR-ELEMENT-EXPECTED) 0x4c)
          u3
          u2
        ))
        (payload (unwrap! (slice? script offset script-len) ERR-ELEMENT-EXPECTED))
      )
      (asserts! (> (len payload) u2) ERR-ELEMENT-EXPECTED)
      (ok (from-consensus-buff? { p: principal, a: uint, d: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (parse-payload-legacy-refund (tx (buff 4096)))
  (match (get-output-legacy tx u0)
    parsed-result (let (
        (script (get scriptPubKey parsed-result))
        (script-len (len script))
        ;; lenght is dynamic one or two bytes!
        (offset (if (is-eq (unwrap! (element-at? script u1) ERR-ELEMENT-EXPECTED) 0x4c)
          u3
          u2
        ))
        (payload (unwrap! (slice? script offset script-len) ERR-ELEMENT-EXPECTED))
      )
      (asserts! (> (len payload) u2) ERR-ELEMENT-EXPECTED)
      (ok (from-consensus-buff? { i: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (get-output-legacy
    (tx (buff 4096))
    (index uint)
  )
  (let ((parsed-tx (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      parse-tx tx
    )))
    (match parsed-tx
      result (let (
          (tx-data (unwrap-panic parsed-tx))
          (outs (get outs tx-data))
          (out (unwrap! (element-at? outs index) ERR-ELEMENT-EXPECTED))
          (scriptPubKey (get scriptPubKey out))
          (value (get value out))
        )
        (ok {
          scriptPubKey: scriptPubKey,
          value: value,
        })
      )
      missing
      ERR-ELEMENT-EXPECTED
    )
  )
)

(define-public (process-btc-deposit
    (btc-amount uint)
  )
  (let (
      (current-pool (var-get pool))
      (percent-fee (/ btc-amount u100))
      (minimum-fee (get min-fee current-pool))
      (this-fee (if (> percent-fee minimum-fee) percent-fee minimum-fee))
      (service-fee (/ this-fee u2))
      (lp-fee (- this-fee service-fee))
      (sbtc-amount-to-user (- btc-amount this-fee))
      (available-sbtc (get available-sbtc current-pool))
      (current-count (var-get processed-tx-count))
      (max-deposit (get max-deposit current-pool))
      (stx-receiver tx-sender)
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (asserts! (<= btc-amount available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
    (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
    (var-set processed-tx-count (+ current-count u1))
    (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc btc-amount) })
              )
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                            sbtc-amount-to-user tx-sender stx-receiver none)))
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                            service-fee tx-sender SERVICE_STYX none)))
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                            lp-fee tx-sender OPERATOR_STYX none)))            
    (print {
                type: "process-btc-deposit",
                btc-tx-id: "simulated",
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: "simulated",
                when: burn-block-height,
                processor: tx-sender
              })
    (ok true)
  )
)

(define-public (swap-btc-to-aibtc
    (btc-amount uint)
    (min-amount-out uint)
    (dex-id uint)
    (ft <faktory-token>)
    (ai-dex <faktory-dex>)
    (ai-pre <faktory-pre>)
    (ai-pool <bitflow-pool>)
    (sbtc-token <faktory-token>)
  )
  (let (
      (current-pool (var-get pool))
      (dex-info (unwrap! (map-get? allowed-dexes dex-id) ERR-DEX-NOT-ALLOWED))
      (ai-ft-allowed (get ft-contract dex-info))
      (percent-fee (/ btc-amount u100))
      (minimum-fee (get min-fee current-pool))
      (this-fee (if (> percent-fee minimum-fee) percent-fee minimum-fee))
      (service-fee (/ this-fee u2))
      (lp-fee (- this-fee service-fee))
      (sbtc-amount-to-user (- btc-amount this-fee)) 
      (available-sbtc (get available-sbtc current-pool))
      (current-count (var-get processed-tx-count))
      (max-deposit (get max-deposit current-pool))
      (market-open (unwrap! (contract-call? ai-pre is-market-open) ERR-GET-MARKET))
      (bonded (unwrap! (contract-call? ai-dex get-bonded) ERR-GET-BONDED))
      (ai-account (unwrap! (contract-call? .agent-account-registry get-agent-account-by-owner tx-sender) ERR-NO-AI-ACCOUNT))) ;; 'ST29D6YMDNAKN1P045T6Z817RTE1AC0JAAAG2EQZZ.
    (asserts! (not (var-get swaps-paused)) ERR_FORBIDDEN)
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (asserts! (is-eq (contract-of ft) ai-ft-allowed) ERR-WRONG-FT)
    (asserts! (is-eq (contract-of sbtc-token) SBTC_CONTRACT) ERR-WRONG-SBTC)              
    (asserts! (<= btc-amount available-sbtc) ERR_INSUFFICIENT_POOL_BALANCE)
    (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
    (var-set processed-tx-count (+ current-count u1))
    (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc btc-amount) })
              )
    (print {
                type: "process-btc-deposit",
                btc-tx-id: "simulated",
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: tx-sender,
                ai-account: ai-account,
                btc-receiver: "simulated",
                when: burn-block-height,
                processor: tx-sender,
                min-amount-out: min-amount-out
            })
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                service-fee tx-sender SERVICE_STYX none)))
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                lp-fee tx-sender OPERATOR_STYX none)))
    (if bonded
        (let ((ai-pool-allowed (get pool-contract dex-info)))
                    (asserts! (is-eq (contract-of ai-pool) ai-pool-allowed) ERR-WRONG-POOL)
                    (match (as-contract (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                            ai-pool sbtc-token ft sbtc-amount-to-user min-amount-out))
                    swap-result (try! (as-contract (contract-call? ft transfer 
                                                      swap-result tx-sender ai-account none))) 
                    error (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                      sbtc-amount-to-user tx-sender ai-account none))))
                    (ok true))
        (if market-open
            (let ((in-info (unwrap! (contract-call? ai-dex get-in sbtc-amount-to-user) ERR-GET-QUOTE))
                            (tokens-out (get tokens-out in-info))
                            (ai-dex-allowed (get dex-contract dex-info)))
                        (asserts! (is-eq (contract-of ai-dex) ai-dex-allowed) ERR-WRONG-DEX)
                        (if (>= tokens-out min-amount-out)
                        (match (as-contract (contract-call? ai-dex buy ft sbtc-amount-to-user))
                        buy-result (try! (as-contract (contract-call? ft transfer 
                                                        tokens-out tx-sender ai-account none))) 
                        error (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                        sbtc-amount-to-user tx-sender ai-account none))))
                        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                        sbtc-amount-to-user tx-sender ai-account none))))
                        (ok true))
            (let ((ai-pre-allowed (get pre-contract dex-info))
                            (max-seat (/ sbtc-amount-to-user PRICE-PER-SEAT)))
                            (asserts! (is-eq (contract-of ai-pre) ai-pre-allowed) ERR-WRONG-PRE)
                            (match (as-contract (contract-call? ai-pre buy-up-to max-seat (some ai-account)))
                                actual-seat (let ((user-change (- sbtc-amount-to-user (* actual-seat PRICE-PER-SEAT))))
                                          (if (> user-change u0)
                                          (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                        user-change tx-sender ai-account none)))
                                          true)
                                          (ok true))
                                error (begin 
                                        (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
                                                        sbtc-amount-to-user tx-sender ai-account none)))
                                        (ok true)))
                        ))
    )  
  )
)

;; ---- Read-only functions ----
(define-read-only (get-pool)
  (ok (var-get pool))
)

(define-read-only (is-tx-processed (tx-id (buff 128)))
  (is-some (map-get? processed-btc-txs tx-id))
)

(define-read-only (get-processed-tx (tx-id (buff 128)))
  (match (map-get? processed-btc-txs tx-id)
    tx-info (ok tx-info)
    (err ERR_NOT_PROCESSED)
  )
)

;; ---- Edge case functions ----
(define-map refund-requests
  uint
  {
    btc-tx-id: (buff 128), ;; Original BTC transaction ID
    btc-tx-refund-id: (optional (buff 128)),
    btc-amount: uint, ;; Original BTC amount
    btc-receiver: (buff 40), ;; Where to send the BTC refund
    stx-receiver: principal, ;; can only be requested by stx receiver
    requested-at: uint,
    done: bool,
  }
)

(define-map processed-refunds
  (buff 128)
  uint
)

(define-data-var next-refund-id uint u1)

;; Read only functions
(define-read-only (get-refund-request (refund-id uint))
  (match (map-get? refund-requests refund-id)
    refund (ok refund)
    (err ERR_INVALID_ID)
  )
)

(define-read-only (is-refund-processed (tx-id (buff 128)))
  (match (map-get? processed-refunds tx-id)
    refund-id (ok refund-id)
    (err ERR_NOT_PROCESSED)
  )
)

(define-read-only (get-refund-count)
  (ok (var-get next-refund-id))
)

(define-read-only (get-current-operator)
  (ok (var-get current-operator))
)

;; Add this initialization function
(define-public (initialize-pool
    (sbtc-amount uint)
    (btc-receiver (buff 40))
  )
  (let ((current-pool (var-get pool)))
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (not (var-get is-initialized)) ERR_ALREADY_DONE)
    (asserts! (> sbtc-amount u0) ERR_AMOUNT_NULL)
    (match (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer sbtc-amount tx-sender (as-contract tx-sender) none
    )
      success (begin
        (var-set pool
          (merge current-pool {
            total-sbtc: sbtc-amount,
            available-sbtc: sbtc-amount,
            btc-receiver: btc-receiver,
            last-updated: burn-block-height,
            add-liq-signaled-at: none,
          })
        )
        ;; Mark as initialized
        (var-set is-initialized true)
        
        (print {
          type: "initialize-pool",
          operator: tx-sender,
          sbtc: sbtc-amount,
          btc-receiver: btc-receiver,
          total-sbtc: sbtc-amount,
          available-sbtc: sbtc-amount,
          initialized-at: burn-block-height,
        })
        (ok true)
      )
      error (err (* error u1000))
    )
  )
)

;; Add read-only function to check initialization status
(define-read-only (is-pool-initialized)
  (ok (var-get is-initialized))
)