(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait granite-trait .trait-granite-liquidator.granite-liquidator-trait)

(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))
(define-constant ERR-UNAUTHORIZED (err u10000))
(define-constant ERR-TRANSFER-NULL (err u10001))
(define-constant ERR-TOKEN-NOT-SUPPORTED (err u10002))
(define-constant ERR-INSUFFICIENT-AMOUNT-OUT (err u10003))
(define-constant ERR-GRANITE-LIQUIDATION-FAILED (err u10004))
(define-constant ERR-INVALID-VALUE (err u10005))
(define-constant ERR-TIMEOUT (err u10006))
(define-constant ERR-SWAP-FACTOR-C (err u10020))
(define-constant ERR-SWAP-FACTOR-B (err u10021))
(define-constant ERR-SWAP-FACTOR-A (err u10022))
(define-constant ERR-SWAP-FACTOR (err u10023))
(define-constant ERR-SWAP-PATH (err u10024))
(define-constant ERR-SWAP-RESULT (err u10031))

(define-data-var owner principal contract-caller)
(define-map allowed-tokens principal bool)
(define-data-var unprofitability-threshold uint u0)

(define-read-only (is-owner)
  (is-eq contract-caller (var-get owner))
)

(define-read-only (is-token-supported (token principal))
  (ok (unwrap! (map-get? allowed-tokens token) ERR-TOKEN-NOT-SUPPORTED))
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      val-before: (var-get owner),
      val-after: new-owner,
      user: contract-caller,
      action: "set-owner"
    })
    (var-set owner new-owner)
    SUCCESS
  )
)

(define-public (set-unprofitability-threshold (new-val uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (> new-val u0) ERR-INVALID-VALUE)
    (print {
      val-before: (var-get unprofitability-threshold),
      val-after: new-val,
      user: contract-caller,
      action: "set-unprofitability-threshold"
    })
    (var-set unprofitability-threshold new-val)
    SUCCESS
  )
)

(define-public (set-allowed-token (token principal) (flag bool))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      token: token,
      val-before: (map-get? allowed-tokens token),
      val-after: flag,
      user: contract-caller,
      action: "set-allowed-token"
    })
    (map-set allowed-tokens token flag)
    SUCCESS
  )
)

(define-public (deposit (token <ft-trait>) (amount uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (try! (is-token-supported (contract-of token))) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (unwrap! (map-get? allowed-tokens (contract-of token)) ERR-TOKEN-NOT-SUPPORTED) ERR-TOKEN-NOT-SUPPORTED)
    (try! (transfer-from token contract-caller amount))
    SUCCESS
  )
)

;; no assert needed, if the token has been deposited and removed from allow list afterwards, it could get stuck
(define-public (withdraw (token <ft-trait>) (amount uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (try! (transfer-to token contract-caller amount))
    SUCCESS
  )
)

(define-public (liquidate
  ;; granite liquidator data
  (liquidator-granite <granite-trait>)
  (pyth-price-feed-data (optional (buff 8192)))
  (user principal)
  (market-asset <ft-trait>)
  (collateral <ft-trait>)
  (liquidator-repay-amount uint)
  (min-collateral-expected uint)
  ;; swap router data
  (deadline uint)
  (swap-data {
    token-x: <alex-ft-trait>, 
    token-y: <alex-ft-trait>,
    token-z: (optional <alex-ft-trait>), 
    token-w: (optional <alex-ft-trait>),
    token-v: (optional <alex-ft-trait>),
    factor-x: uint,
    factor-y: (optional uint),
    factor-z: (optional uint),
    factor-w: (optional uint)
  })
)
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (asserts! (try! (is-token-supported (contract-of market-asset))) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (try! (is-token-supported (contract-of collateral))) ERR-TOKEN-NOT-SUPPORTED)
    (let 
      (
        (initial-market-balance (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
        (initial-collateral-balance (try! (contract-call? collateral get-balance (as-contract contract-caller))))
        (liquidate-res (try! (liquidate-position
            liquidator-granite
            pyth-price-feed-data
            collateral
            user
            liquidator-repay-amount
            min-collateral-expected
        )))
        (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance (as-contract contract-caller)))))
        (collateral-obtained (- (try! (contract-call? collateral get-balance (as-contract contract-caller))) initial-collateral-balance ))
        (asset-min-out (compute-min-out asset-amount-repaid))
        (market-balance-before (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
        (swap-result (swap-alex (merge swap-data {dx: collateral-obtained, min-out: (some asset-min-out)})))
        (market-balance-after (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
      )
      (asserts! (>= (- market-balance-after market-balance-before) asset-min-out) ERR-SWAP-RESULT)
      SUCCESS
    )
  )
)

(define-public (batch-liquidate
  ;; granite liquidator data
  (liquidator-granite <granite-trait>)
  (pyth-price-feed-data (optional (buff 8192)))
  (market-asset <ft-trait>)
  (collateral <ft-trait>)
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  ;; swap router data
  (deadline uint)
  (swap-data {
    token-x: <alex-ft-trait>, 
    token-y: <alex-ft-trait>,
    token-z: (optional <alex-ft-trait>), 
    token-w: (optional <alex-ft-trait>),
    token-v: (optional <alex-ft-trait>),
    factor-x: uint,
    factor-y: (optional uint),
    factor-z: (optional uint),
    factor-w: (optional uint)
  })
)
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (asserts! (try! (is-token-supported (contract-of market-asset))) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (try! (is-token-supported (contract-of collateral))) ERR-TOKEN-NOT-SUPPORTED)
    (let 
      (
        (initial-market-balance (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
        (initial-collateral-balance (try! (contract-call? collateral get-balance (as-contract contract-caller))))
        (liquidate-res  (try! (batch-liquidate-position
            liquidator-granite
            pyth-price-feed-data
            collateral
            batch
        )))
        (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance (as-contract contract-caller)))))
        (collateral-obtained (- (try! (contract-call? collateral get-balance (as-contract contract-caller))) initial-collateral-balance))
        (asset-min-out (compute-min-out asset-amount-repaid))
        (market-balance-before (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
        (swap-result (swap-alex (merge swap-data {dx: collateral-obtained, min-out: (some asset-min-out)})))
        (market-balance-after (try! (contract-call? market-asset get-balance (as-contract contract-caller))))
      )
      (asserts! (>= (- market-balance-after market-balance-before) asset-min-out) ERR-SWAP-RESULT)
      SUCCESS
    )
  )
)

(define-private (swap-alex
    (data {
      token-x: <alex-ft-trait>, 
      token-y: <alex-ft-trait>,
      token-z: (optional <alex-ft-trait>), 
      token-w: (optional <alex-ft-trait>),
      token-v: (optional <alex-ft-trait>),
      factor-x: uint,
      factor-y: (optional uint),
      factor-z: (optional uint),
      factor-w: (optional uint),
      dx: uint,
      min-out: (optional uint)
    })
  )
  (if is-in-mainnet (swap-alex-inner data) (ok u0))
)

(define-private (swap-alex-inner
    (data {
      token-x: <alex-ft-trait>, 
      token-y: <alex-ft-trait>,
      token-z: (optional <alex-ft-trait>), 
      token-w: (optional <alex-ft-trait>),
      token-v: (optional <alex-ft-trait>),
      factor-x: uint,
      factor-y: (optional uint),
      factor-z: (optional uint),
      factor-w: (optional uint),
      dx: uint,
      min-out: (optional uint)
    })
  )
  (let 
    (
      (token-x (get token-x data))
      (token-y (get token-y data))
      (token-z (get token-z data))
      (token-w (get token-w data))
      (token-v (get token-v data))
      (factor-x (get factor-x data))
      (factor-y (get factor-y data))
      (factor-z (get factor-z data))
      (factor-w (get factor-w data))
      (dx (get dx data))
      (min-out (get min-out data))
    )
    (if (and (is-some token-z) (is-some token-w) (is-some token-v))
      (begin 
        (asserts! (and (is-some factor-y) (is-some factor-z) (is-some factor-w)) ERR-SWAP-FACTOR-C)
        (ok (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
          token-x
          token-y
          (unwrap-panic token-z)
          (unwrap-panic token-w)
          (unwrap-panic token-v)
          factor-x
          (unwrap-panic factor-y)
          (unwrap-panic factor-z)
          (unwrap-panic factor-w)
          dx
          min-out
        )))
      )
      (if (and (is-some token-z) (is-some token-w))
          (begin 
              (asserts! (and (is-some factor-y) (is-some factor-z)) ERR-SWAP-FACTOR-B)
              (ok (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                token-x
                token-y
                (unwrap-panic token-z)
                (unwrap-panic token-w)
                factor-x
                (unwrap-panic factor-y)
                (unwrap-panic factor-z)
                dx
                min-out
              )))
          )
          (if (is-some token-z)
              (begin 
                (asserts! (is-some factor-z) ERR-SWAP-FACTOR-A)
                (ok (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x
                  token-y
                  (unwrap-panic token-z)
                  factor-x
                  (unwrap-panic factor-y)
                  dx
                  min-out
                )))
              )
              (begin
                (asserts! (and (is-none token-z) (is-none token-w) (is-none token-v)) ERR-SWAP-PATH)
                (asserts! (and (is-none factor-y) (is-none factor-z) (is-none factor-w)) ERR-SWAP-FACTOR)
                (ok (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  token-x
                  token-y
                  factor-x
                  dx
                  min-out
                )))
              )
          )
      )
    )
  )
)

(define-private (liquidate-position
    (liquidator-granite <granite-trait>)
    (pyth-price-feed-data (optional (buff 8192)))
    (collateral <ft-trait>)
    (user principal)
    (liquidator-repay-amount uint)
    (min-collateral-expected uint)
  )
  (as-contract (contract-call? liquidator-granite liquidate-collateral
    pyth-price-feed-data
    collateral
    user
    liquidator-repay-amount
    min-collateral-expected
  ))
)

(define-private (batch-liquidate-position
    (liquidator-granite <granite-trait>)
    (pyth-price-feed-data (optional (buff 8192)))
    (collateral <ft-trait>)
    (batch (list 20 (optional {
      user: principal,
      liquidator-repay-amount: uint,
      min-collateral-expected: uint
    })))
  )
  (as-contract (contract-call? liquidator-granite batch-liquidate
    pyth-price-feed-data
    collateral
    batch
  ))
)


(define-private (compute-min-out (paid uint))
  (if is-in-mainnet 
    (- paid 
      (/ 
        (* paid (var-get unprofitability-threshold))
        SCALING-FACTOR
      )
    )
    u0)
)

(define-private (transfer-from (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (try! (contract-call? token transfer amount user (as-contract contract-caller) none))
    SUCCESS
))

(define-private (transfer-to (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? token transfer amount (as-contract contract-caller) user none)))
    SUCCESS
))
