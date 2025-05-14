---
title: "Trait liquidator"
draft: true
---
```
;; TRAITS
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait alex-ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; Constants
(define-constant SELF (as-contract contract-caller))
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))

;; TODO
(define-constant ERR-UNAUTHORIZED (err u10000))
(define-constant ERR-TRANSFER-NULL (err u10001))
(define-constant ERR-INVALID-VALUE (err u10002))
(define-constant ERR-TIMEOUT (err u10003))
(define-constant ERR-SWAP-FACTOR-C (err u10004))
(define-constant ERR-SWAP-FACTOR-B (err u10005))
(define-constant ERR-SWAP-FACTOR-A (err u10006))
(define-constant ERR-SWAP-FACTOR (err u10007))
(define-constant ERR-SWAP-PATH (err u10008))
(define-constant ERR-SWAP-RESULT (err u10009))

;; data vars
(define-data-var owner principal contract-caller)
(define-data-var operator principal contract-caller)
(define-data-var unprofitability-threshold uint u0)

;; Read only functions
(define-read-only (is-owner) (is-eq contract-caller (var-get owner)))

(define-read-only (is-operator) (is-eq contract-caller (var-get operator)))

(define-read-only (get-unprofitability-threshold) (var-get unprofitability-threshold))

(define-read-only (get-info) 
  {
    operator: (var-get operator),
    owner: (var-get owner),
    unprofitability-threshold: (var-get unprofitability-threshold),
    market-asset: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc,
    collateral-asset: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
  }
)

;; Public functions

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      previous-owner: (var-get owner),
      new-owner: new-owner,
      caller: contract-caller,
      action: "set-owner"
    })
    (var-set owner new-owner)
    SUCCESS
  )
)

(define-public (set-operator (new-operator principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      previous-operator: (var-get operator),
      new-operator: new-operator,
      caller: contract-caller,
      action: "set-operator"
    })
    (var-set operator new-operator)
    SUCCESS
  )
)

(define-public (set-unprofitability-threshold (new-val uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (<= new-val u10000) ERR-INVALID-VALUE)
    (print {
      previous: (var-get unprofitability-threshold),
      new: new-val,
      user: contract-caller,
      action: "set-unprofitability-threshold"
    })
    (var-set unprofitability-threshold new-val)
    SUCCESS
  )
)

(define-public (liquidate-with-swap 
  (pyth-price-feed-data (optional (buff 8192)))
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
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
  }))
    (let (
      (initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
      (initial-collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
    )
      (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
      (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
      (try! (batch-liquidate-position pyth-price-feed-data batch))
      (let 
          (
            (market-balance-before-swap (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
            (collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
            (asset-amount-repaid (- initial-market-balance market-balance-before-swap))
            (collateral-obtained (- collateral-balance initial-collateral-balance))
            ;; TODO: Consider to make min out 0 and check expected market-asset in the end
            (asset-min-out (compute-min-out asset-amount-repaid))
            (swap-result (try! (swap-alex (merge swap-data {dx: collateral-obtained, min-out: (some asset-min-out)}))))
            (market-balance-after (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
          )
        ;; This check ensures that in the end of the swap operation we receive market-asset and swap-data passed properly.
        (asserts! (>= (- market-balance-after market-balance-before-swap) asset-min-out) ERR-SWAP-RESULT)
        (print {
          initial-market-balance: initial-market-balance,
          initial-collateral-balance: initial-collateral-balance,
          asset-amount-repaid: asset-amount-repaid,
          collateral-obtained: collateral-obtained,
          asset-min-out: asset-min-out,
          market-balance-before-swap: market-balance-before-swap,
          market-balance-after-swap: market-balance-after,
          swap-result: (- market-balance-after market-balance-before-swap),
          action: "liquidate-with-swap"
        })
        SUCCESS
)))

(define-public (liquidate
  (pyth-price-feed-data (optional (buff 8192)))
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  (deadline uint))
    (let (
      (initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF)))
      (initial-collateral-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)))
    )
      (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
      (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
      (try! (batch-liquidate-position pyth-price-feed-data batch))
      (let
        (
          (asset-amount-repaid (- initial-market-balance (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance SELF))))
          (collateral-obtained (- (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance SELF)) initial-collateral-balance ))
        ) 
        (print {
          initial-market-balance: initial-market-balance,
          initial-collateral-balance: initial-collateral-balance,
          asset-amount-repaid: asset-amount-repaid,
          collateral-obtained: collateral-obtained,
          action: "liquidate"
        })
        SUCCESS
)))

(define-public (deposit (token <ft-trait>) (amount uint))
  (begin
    (try! (transfer-from token contract-caller amount))
    SUCCESS
  )
)

(define-public (withdraw (token <ft-trait>) (amount uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (try! (transfer-to token contract-caller amount))
    SUCCESS
  )
)

(define-public (deposit-stx (amount uint))
  (stx-transfer? amount contract-caller SELF)
)

(define-public (withdraw-stx (amount uint))
  (let ((caller contract-caller))
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (as-contract (stx-transfer? amount (as-contract contract-caller) caller))
  )
)

;; Private functions
(define-private (compute-min-out (paid uint))
  (- paid 
    (/ 
      (* paid (var-get unprofitability-threshold))
      SCALING-FACTOR
    )
  )
)

(define-private (transfer-from (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (try! (contract-call? token transfer amount user SELF none))
    SUCCESS
))

(define-private (transfer-to (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? token transfer amount SELF user none)))
    SUCCESS
))

(define-private (batch-liquidate-position
    (pyth-price-feed-data (optional (buff 8192)))
    (batch (list 20 (optional {
      user: principal,
      liquidator-repay-amount: uint,
      min-collateral-expected: uint
    })))
  )
  (as-contract (contract-call? 'SP1XN57PMR6X7JZ8JXMNRAE065YBA3NKRCZF5N46B.liquidator-v1 batch-liquidate
    pyth-price-feed-data
    'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
    batch
  ))
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
        (ok (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
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
        ))))
      )
      (if (and (is-some token-z) (is-some token-w))
          (begin 
              (asserts! (and (is-some factor-y) (is-some factor-z)) ERR-SWAP-FACTOR-B)
              (ok (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                token-x
                token-y
                (unwrap-panic token-z)
                (unwrap-panic token-w)
                factor-x
                (unwrap-panic factor-y)
                (unwrap-panic factor-z)
                dx
                min-out
              ))))
          )
          (if (is-some token-z)
              (begin 
                (asserts! (is-some factor-y) ERR-SWAP-FACTOR-A)
                (ok (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x
                  token-y
                  (unwrap-panic token-z)
                  factor-x
                  (unwrap-panic factor-y)
                  dx
                  min-out
                ))))
              )
              (begin
                (asserts! (and (is-none token-z) (is-none token-w) (is-none token-v)) ERR-SWAP-PATH)
                (asserts! (and (is-none factor-y) (is-none factor-z) (is-none factor-w)) ERR-SWAP-FACTOR)
                (ok (try! (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  token-x
                  token-y
                  factor-x
                  dx
                  min-out
                ))))
              )
          )
      )
    )
  )
)

```
