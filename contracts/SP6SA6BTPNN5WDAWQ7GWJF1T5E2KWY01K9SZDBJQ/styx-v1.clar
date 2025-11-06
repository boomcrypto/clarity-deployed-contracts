;; Styx Pool structure to track sBTC liquidity (single pool per contract)
;; Trustless one-way bridge from Bitcoin to Economies on BTC 
;; Ultra-fast passage via Clarity's direct Bitcoin state reading 
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

(define-constant OPERATOR_STYX 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ) 
(define-constant COOLDOWN u6)
(define-constant MIN_SATS u10000)
(define-constant MAX_SLIPPAGE u200000)
(define-constant FIXED_FEE u21000)
(define-constant WITHDRAWAL_COOLOFF u144)

(define-constant PRECISION u1000000)

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
  max-slippage-rate: uint,
  fee: uint,
  fee-threshold: uint,
  add-liq-signaled-at: (optional uint),
  set-param-signaled-at: (optional uint),
} {
  total-sbtc: u0,
  available-sbtc: u0,
  btc-receiver: 0x0000000000000000000000000000000000000000,
  last-updated: u0,
  withdrawal-signaled-at: none,
  max-deposit: u1000000,
  max-slippage-rate: u69000,
  fee: u6000,
  fee-threshold: u203000,
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

(define-public (add-only-liquidity (sbtc-amount uint))
  ;; this func without cool downs only adds liquidity - reserved
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
    (fee uint)
    (fee-threshold uint)
    (new-max-slippage-rate uint)
  )
  (let (
      (current-pool (var-get pool))
      (signaled-at (default-to u0 (get set-param-signaled-at current-pool)))
    )
    (asserts! (not (is-eq signaled-at u0)) ERR_NOT_SIGNALED)
    (asserts! (> burn-block-height (+ signaled-at COOLDOWN)) ERR_IN_COOLDOWN)
    (asserts! (<= fee FIXED_FEE) ERR_FEE_TOO_LARGE)
    (asserts! (is-eq tx-sender (var-get current-operator)) ERR_FORBIDDEN)
    (asserts! (> new-max-deposit MIN_SATS) ERR_AMOUNT_NULL)
    (asserts! (< new-max-slippage-rate MAX_SLIPPAGE) ERR_TOO_MUCH_SLIPPAGE)
    (var-set pool
      (merge current-pool {
        last-updated: burn-block-height,
        max-deposit: new-max-deposit,
        max-slippage-rate: new-max-slippage-rate,
        fee: fee,
        fee-threshold: fee-threshold,
        set-param-signaled-at: none,
      })
    )
    (print {
      type: "set-max-deposit",
      max-deposit: new-max-deposit,
      max-slippage-rate: new-max-slippage-rate,
      fee: fee,
      fee-threshold: fee-threshold,
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
      (ok (from-consensus-buff? { p: principal, amount: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (parse-pay-segwit (tx (buff 4096)))
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
      (ok (from-consensus-buff? { p: principal} payload))
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
      (ok (from-consensus-buff? { p: principal, amount: uint } payload))
    )
    not-found
    ERR-ELEMENT-EXPECTED
  )
)

(define-read-only (parse-pay-legacy (tx (buff 4096)))
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
      (ok (from-consensus-buff? { p: principal } payload))
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

;; Process a BTC deposit and release sBTC - by anyone
(define-public (process-btc-deposit
    (height uint)
    (wtx {
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
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 4096))
    (cproof (list 14 (buff 32)))
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v2
        concat-wtx wtx witness-data
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-segwit-tx-mined-compact height tx-buff header tx-index tree-depth
      wproof witness-merkle-root witness-reserved-value ctx cproof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value wtx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-pay-segwit tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (if is-blaze
                (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                              sbtc-amount-to-user (some stx-receiver))))
                (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                              sbtc-amount-to-user tx-sender stx-receiver none))))
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze
              })
              (ok true)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

(define-public (process-btc-deposit-legacy
    (height uint)
    (blockheader (buff 80))
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
    (proof {
      tx-index: uint,
      hashes: (list 12 (buff 32)),
      tree-depth: uint,
    })
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-v2 concat-tx
        tx
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-tx-mined-compact height tx-buff blockheader proof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value tx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-pay-legacy tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (if is-blaze
                (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                              sbtc-amount-to-user (some stx-receiver))))
                (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                              sbtc-amount-to-user tx-sender stx-receiver none))))
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze
              })
              (ok true)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

;; Process a BTC deposit to USDA - by anyone
(define-public (swap-btc-to-usda
    (height uint)
    (wtx {
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
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 4096))
    (cproof (list 14 (buff 32)))
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (max-slip-rate (get max-slippage-rate current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v2
        concat-wtx wtx witness-data
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-segwit-tx-mined-compact height tx-buff header tx-index tree-depth
      wproof witness-merkle-root witness-reserved-value ctx cproof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value wtx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-payload-segwit tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (min-amount-out (unwrap! (get amount payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
                (delta-c (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool get-swap-quote sbtc-amount-to-user (some 0x00)))
                (dy-d (get dy delta-c))
                (fat-finger-out (/ (* dy-d (- PRECISION max-slip-rate)) PRECISION))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze,
                min-amount-out: min-amount-out,
                fat-finger-out: fat-finger-out 
              })
              (if (>= min-amount-out fat-finger-out)
                    (match (as-contract (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool swap-a-to-b sbtc-amount-to-user
                        min-amount-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP3AT0KR5GJBTWBR0YAZ9NV7B9QMMZSS27B1DC05V.usda-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                    (match (as-contract (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool swap-a-to-b sbtc-amount-to-user
                        fat-finger-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP3AT0KR5GJBTWBR0YAZ9NV7B9QMMZSS27B1DC05V.usda-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                )
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

(define-public (swap-btc-to-usda-legacy
    (height uint)
    (blockheader (buff 80))
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
    (proof {
      tx-index: uint,
      hashes: (list 12 (buff 32)),
      tree-depth: uint,
    })
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (max-slip-rate (get max-slippage-rate current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-v2 concat-tx
        tx
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-tx-mined-compact height tx-buff blockheader proof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value tx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-payload-legacy tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (min-amount-out (unwrap! (get amount payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
                (delta-c (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool get-swap-quote sbtc-amount-to-user (some 0x00)))
                (dy-d (get dy delta-c))
                (fat-finger-out (/ (* dy-d (- PRECISION max-slip-rate)) PRECISION))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze,
                min-amount-out: min-amount-out,
                fat-finger-out: fat-finger-out 
              })
              (if (>= min-amount-out fat-finger-out)
                    (match (as-contract (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool swap-a-to-b sbtc-amount-to-user
                        min-amount-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP3AT0KR5GJBTWBR0YAZ9NV7B9QMMZSS27B1DC05V.usda-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                    (match (as-contract (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool swap-a-to-b sbtc-amount-to-user
                        fat-finger-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP3AT0KR5GJBTWBR0YAZ9NV7B9QMMZSS27B1DC05V.usda-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                )
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

;; Process a BTC deposit to PEPE - by anyone
(define-public (swap-btc-to-pepe
    (height uint)
    (wtx {
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
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 4096))
    (cproof (list 14 (buff 32)))
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (max-slip-rate (get max-slippage-rate current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v2
        concat-wtx wtx witness-data
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-segwit-tx-mined-compact height tx-buff header tx-index tree-depth
      wproof witness-merkle-root witness-reserved-value ctx cproof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value wtx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-payload-segwit tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (min-amount-out (unwrap! (get amount payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
                (delta-c (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool get-swap-quote sbtc-amount-to-user (some 0x00)))
                (dy-d (get dy delta-c))
                (fat-finger-out (/ (* dy-d (- PRECISION max-slip-rate)) PRECISION))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze,
                min-amount-out: min-amount-out,
                fat-finger-out: fat-finger-out 
              })
              (if (>= min-amount-out fat-finger-out)
                    (match (as-contract (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool swap-a-to-b sbtc-amount-to-user
                        min-amount-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.pepe-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                    (match (as-contract (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool swap-a-to-b sbtc-amount-to-user
                        fat-finger-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.pepe-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                )
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

(define-public (swap-btc-to-pepe-legacy
    (height uint)
    (blockheader (buff 80))
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
    (proof {
      tx-index: uint,
      hashes: (list 12 (buff 32)),
      tree-depth: uint,
    })
    (is-blaze bool)
  )
  (let (
      (current-pool (var-get pool))
      (fixed-fee (get fee current-pool))
      (max-slip-rate (get max-slippage-rate current-pool))
      (btc-receiver (get btc-receiver current-pool))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-v2 concat-tx
        tx
      ))
    )
    (asserts! (> burn-block-height (+ (get last-updated current-pool) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-tx-mined-compact height tx-buff blockheader proof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out (unwrap! (get-out-value tx btc-receiver) ERR_NATIVE_FAILURE))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-payload-legacy tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
                (min-amount-out (unwrap! (get amount payload) ERR-ELEMENT-EXPECTED))
                (this-fee (if (<= btc-amount (get fee-threshold current-pool))
                  (/ fixed-fee u2)
                  fixed-fee
                ))
                (sbtc-amount-to-user (- btc-amount this-fee))
                (available-sbtc (get available-sbtc current-pool))
                (current-count (var-get processed-tx-count))
                (max-deposit (get max-deposit current-pool))
                (delta-c (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool get-swap-quote sbtc-amount-to-user (some 0x00)))
                (dy-d (get dy delta-c))
                (fat-finger-out (/ (* dy-d (- PRECISION max-slip-rate)) PRECISION))
              )
              (asserts! (<= sbtc-amount-to-user available-sbtc)
                ERR_INSUFFICIENT_POOL_BALANCE
              )
              (asserts! (<= sbtc-amount-to-user max-deposit)
                ERR_DEPOSIT_TOO_LARGE
              )
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: current-count,
              })
              (var-set processed-tx-count (+ current-count u1))
              (var-set pool
                (merge current-pool { available-sbtc: (- available-sbtc sbtc-amount-to-user) })
              )
              (print {
                type: "process-btc-deposit",
                btc-tx-id: result,
                btc-amount: btc-amount,
                sbtc-amount-to-user: sbtc-amount-to-user,
                stx-receiver: stx-receiver,
                btc-receiver: btc-receiver,
                when: burn-block-height,
                processor: tx-sender,
                is-blaze: is-blaze,
                min-amount-out: min-amount-out,
                fat-finger-out: fat-finger-out 
              })
              (if (>= min-amount-out fat-finger-out)
                    (match (as-contract (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool swap-a-to-b sbtc-amount-to-user
                        min-amount-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.pepe-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                    (match (as-contract (contract-call? 'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool swap-a-to-b sbtc-amount-to-user
                        fat-finger-out
                    ))
                        delta (let ((amount-received (get dy delta)))
                                (if is-blaze   
                                    (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.pepe-token-subnet-v1 deposit 
                                                            amount-received (some stx-receiver))))
                                    (try! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz transfer
                                                            amount-received tx-sender stx-receiver none))))
                                (ok delta))
                        error (begin
                        (if is-blaze
                            (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.sbtc-token-subnet-v1 deposit 
                                                    sbtc-amount-to-user (some stx-receiver))))
                            (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                                    sbtc-amount-to-user tx-sender stx-receiver none))))
                        (ok {
                            dx: sbtc-amount-to-user,
                            dy: u0,
                            dk: u0,
                        })
                        )
                    )
                )
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
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

(define-public (request-refund
    (btc-refund-receiver (buff 40))
    (height uint)
    (wtx {
      version: (buff 4),
      ins: (list 8 {
        outpoint: {
          hash: (buff 32),
          index: (buff 4),
        },
        scriptSig: (buff 256),
        sequence: (buff 4),
      }),
      outs: (list 8 {
        value: (buff 8),
        scriptPubKey: (buff 128),
      }),
      locktime: (buff 4),
    })
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 1024))
    (cproof (list 14 (buff 32)))
  )
  (let (
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v1
        concat-wtx wtx witness-data
      ))
      (refund-id (var-get next-refund-id))
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-segwit-tx-mined-compact height tx-buff header tx-index tree-depth
      wproof witness-merkle-root witness-reserved-value ctx cproof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out
          (unwrap! (get-out-value wtx (get btc-receiver (var-get pool)))
            ERR_NATIVE_FAILURE
          ))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-pay-segwit tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
              )
              (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: u0,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: u0,
              })
              (map-set refund-requests refund-id {
                btc-tx-id: result,
                btc-tx-refund-id: none,
                btc-amount: btc-amount,
                btc-receiver: btc-refund-receiver,
                stx-receiver: stx-receiver,
                requested-at: burn-block-height,
                done: false,
              })
              (var-set next-refund-id (+ refund-id u1))
              (print {
                type: "request-refund",
                refund-id: refund-id,
                btc-tx-id: result,
                btc-amount: btc-amount,
                btc-receiver: btc-refund-receiver,
                stx-receiver: stx-receiver,
                requested-at: burn-block-height,
                done: false,
              })
              (ok refund-id)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

;; Process a refund by providing proof of BTC return transaction
(define-public (process-refund
    (refund-id uint)
    (height uint)
    (wtx {
      version: (buff 4),
      ins: (list 8 {
        outpoint: {
          hash: (buff 32),
          index: (buff 4),
        },
        scriptSig: (buff 256),
        sequence: (buff 4),
      }),
      outs: (list 8 {
        value: (buff 8),
        scriptPubKey: (buff 128),
      }),
      locktime: (buff 4),
    })
    (witness-data (buff 1650))
    (header (buff 80))
    (tx-index uint)
    (tree-depth uint)
    (wproof (list 14 (buff 32)))
    (witness-merkle-root (buff 32))
    (witness-reserved-value (buff 32))
    (ctx (buff 1024))
    (cproof (list 14 (buff 32)))
  )
  (let (
      (refund (unwrap! (map-get? refund-requests refund-id) ERR_INVALID_ID))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-wtx-v1
        concat-wtx wtx witness-data
      ))
      (payload (unwrap! (parse-payload-segwit-refund tx-buff) ERR-ELEMENT-EXPECTED))
      (refund-id-extracted (unwrap! (get i payload) ERR-ELEMENT-EXPECTED))
      (btc-amount (get btc-amount refund))
    )
    (asserts! (>= burn-block-height (+ (get requested-at refund) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (asserts! (not (get done refund)) ERR_ALREADY_DONE)
    (asserts! (is-eq refund-id-extracted refund-id) ERR_INVALID_ID)
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-segwit-tx-mined-compact height tx-buff header tx-index tree-depth
      wproof witness-merkle-root witness-reserved-value ctx cproof
    )
      result (begin
        (asserts! (is-none (map-get? processed-refunds result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out
          (unwrap! (get-out-value wtx (get btc-receiver refund))
            ERR_NATIVE_FAILURE
          ))
          out (if (>= (get value out) btc-amount)
            (begin
              (map-set refund-requests refund-id
                (merge refund {
                  btc-tx-refund-id: (some result),
                  done: true,
                })
              )
              (map-set processed-refunds result refund-id)
              (print {
                type: "process-refund",
                refund-id: refund-id,
                btc-tx-refund-id: result,
                done: true,
              })
              (ok true)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

;; Refund Legacy
(define-public (request-refund-legacy
    (btc-refund-receiver (buff 40))
    (height uint)
    (blockheader (buff 80))
    (tx {
      version: (buff 4),
      ins: (list 8 {
        outpoint: {
          hash: (buff 32),
          index: (buff 4),
        },
        scriptSig: (buff 256),
        sequence: (buff 4),
      }),
      outs: (list 8 {
        value: (buff 8),
        scriptPubKey: (buff 128),
      }),
      locktime: (buff 4),
    })
    (proof {
      tx-index: uint,
      hashes: (list 12 (buff 32)),
      tree-depth: uint,
    })
  )
  (let (
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-v2 concat-tx
        tx
      ))
      (refund-id (var-get next-refund-id))
    )
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-tx-mined-compact height tx-buff blockheader proof
    )
      result (begin
        (asserts! (is-none (map-get? processed-btc-txs result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out
          (unwrap! (get-out-value tx (get btc-receiver (var-get pool)))
            ERR_NATIVE_FAILURE
          ))
          out (if (>= (get value out) MIN_SATS)
            (let (
                (btc-amount (get value out))
                (payload (unwrap! (parse-payload-legacy tx-buff) ERR-ELEMENT-EXPECTED))
                (stx-receiver (unwrap! (get p payload) ERR-ELEMENT-EXPECTED))
              )
              (asserts! (is-eq tx-sender stx-receiver) ERR_INVALID_STX_RECEIVER)
              (map-set processed-btc-txs result {
                btc-amount: btc-amount,
                sbtc-amount: u0,
                stx-receiver: stx-receiver,
                processed-at: burn-block-height,
                tx-number: u0,
              })
              (map-set refund-requests refund-id {
                btc-tx-id: result,
                btc-tx-refund-id: none,
                btc-amount: btc-amount,
                btc-receiver: btc-refund-receiver,
                stx-receiver: stx-receiver,
                requested-at: burn-block-height,
                done: false,
              })
              (var-set next-refund-id (+ refund-id u1))
              (print {
                type: "request-refund",
                refund-id: refund-id,
                btc-tx-id: result,
                btc-amount: btc-amount,
                btc-receiver: btc-refund-receiver,
                stx-receiver: stx-receiver,
                requested-at: burn-block-height,
                done: false,
              })
              (ok refund-id)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

;; Process a refund by providing proof of BTC return transaction
(define-public (process-refund-legacy
    (refund-id uint)
    (height uint)
    (blockheader (buff 80))
    (tx {
      version: (buff 4),
      ins: (list 8 {
        outpoint: {
          hash: (buff 32),
          index: (buff 4),
        },
        scriptSig: (buff 256),
        sequence: (buff 4),
      }),
      outs: (list 8 {
        value: (buff 8),
        scriptPubKey: (buff 128),
      }),
      locktime: (buff 4),
    })
    (proof {
      tx-index: uint,
      hashes: (list 12 (buff 32)),
      tree-depth: uint,
    })
  )
  (let (
      (refund (unwrap! (map-get? refund-requests refund-id) ERR_INVALID_ID))
      (tx-buff (contract-call?
        'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.bitcoin-helper-v2 concat-tx
        tx
      ))
      (payload (unwrap! (parse-payload-legacy-refund tx-buff) ERR-ELEMENT-EXPECTED))
      (refund-id-extracted (unwrap! (get i payload) ERR-ELEMENT-EXPECTED))
      (btc-amount (get btc-amount refund))
    )
    (asserts! (>= burn-block-height (+ (get requested-at refund) COOLDOWN))
      ERR_IN_COOLDOWN
    )
    (asserts! (not (get done refund)) ERR_ALREADY_DONE)
    (asserts! (is-eq refund-id-extracted refund-id) ERR_INVALID_ID)
    (match (contract-call?
      'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.clarity-bitcoin-lib-v7
      was-tx-mined-compact height tx-buff blockheader proof
    )
      result (begin
        (asserts! (is-none (map-get? processed-refunds result))
          ERR_BTC_TX_ALREADY_USED
        )
        (match (get out
          (unwrap! (get-out-value tx (get btc-receiver refund))
            ERR_NATIVE_FAILURE
          ))
          out (if (>= (get value out) btc-amount)
            (begin
              (map-set refund-requests refund-id
                (merge refund {
                  btc-tx-refund-id: (some result),
                  done: true,
                })
              )
              (map-set processed-refunds result refund-id)
              (print {
                type: "process-refund",
                refund-id: refund-id,
                btc-tx-refund-id: result,
                done: true,
              })
              (ok true)
            )
            ERR_TX_VALUE_TOO_SMALL
          )
          ERR_TX_NOT_SENT_TO_POOL
        )
      )
      error (err (* error u1000))
    )
  )
)

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