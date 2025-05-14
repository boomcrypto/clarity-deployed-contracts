---
title: "Trait liquidator"
draft: true
---
```
(define-trait ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

(define-trait alex-ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
    (transfer-fixed (uint principal principal (optional (buff 34))) (response bool uint))
    (get-balance-fixed (principal) (response uint uint))
    (get-total-supply-fixed () (response uint uint))    
    (mint (uint principal) (response bool uint))
    (burn (uint principal) (response bool uint))  
    (mint-fixed (uint principal) (response bool uint))
		(burn-fixed (uint principal) (response bool uint))      
 )
)

(define-constant SELF (as-contract contract-caller))
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))

(define-constant MARKET-ASSET 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant COLLATERAL-ASSET 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant ERR-UNAUTHORIZED (err u10000))
(define-constant ERR-TRANSFER-NULL (err u10001))
(define-constant ERR-TOKEN-NOT-SUPPORTED (err u10002))
(define-constant ERR-INVALID-VALUE (err u10005))
(define-constant ERR-TIMEOUT (err u10006))
(define-constant ERR-SWAP-FACTOR-C (err u10020))
(define-constant ERR-SWAP-FACTOR-B (err u10021))
(define-constant ERR-SWAP-FACTOR-A (err u10022))
(define-constant ERR-SWAP-FACTOR (err u10023))
(define-constant ERR-SWAP-PATH (err u10024))
(define-constant ERR-SWAP-RESULT (err u10031))
(define-constant ERR-TESTNET-PRICE-DATA-ERROR (err u10051))
(define-constant ERR-TESTNET-PRICE-PARSE-ERROR (err u10052))

;; owner
(define-data-var owner principal contract-caller)
(define-read-only (get-owner) (var-get owner))
(define-read-only (is-owner) (is-eq contract-caller (var-get owner)))

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

;; operator
(define-data-var operator principal contract-caller)
(define-read-only (get-operator) (var-get operator))
(define-read-only (is-operator) (is-eq contract-caller (var-get operator)))

(define-public (set-operator (new-operator principal))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (print {
      val-before: (var-get operator),
      val-after: new-operator,
      user: contract-caller,
      action: "set-operator"
    })
    (var-set operator new-operator)
    SUCCESS
  )
)

;; unprofitability-threshold
(define-data-var unprofitability-threshold uint u0)
(define-read-only (get-unprofitability-threshold) (var-get unprofitability-threshold))

(define-public (set-unprofitability-threshold (new-val uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (<= new-val u10000) ERR-INVALID-VALUE)
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

(define-private (compute-min-out (paid uint))
  (- paid 
    (/ 
      (* paid (var-get unprofitability-threshold))
      SCALING-FACTOR
    )
  )
)


;; helper function to expose all essential info
(define-read-only (get-info) 
  {
    operator: (var-get operator),
    owner: (var-get owner),
    unprofitability-threshold: (var-get unprofitability-threshold),
    market-asset: MARKET-ASSET,
    collateral-asset: COLLATERAL-ASSET
  }
)


(define-public (liquidate
  (pyth-price-feed-data (optional (buff 8192)))
  (user principal)
  (market-asset <ft-trait>)
  (collateral <ft-trait>)
  (liquidator-repay-amount uint)
  (min-collateral-expected uint)
  (deadline uint)
  (swap-data (optional {
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
  ;; TODO: remove when we have a stable mainnet version
  (pyth-testnet-price-data (optional (buff 4096))) 
)
  (begin
    (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
    (asserts! (is-eq MARKET-ASSET (contract-of market-asset)) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (is-eq COLLATERAL-ASSET (contract-of collateral)) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (let 
      (
        (initial-market-balance (try! (contract-call? market-asset get-balance SELF)))
        (initial-collateral-balance (try! (contract-call? collateral get-balance SELF)))
      )
      (try! (set-price-testnet pyth-testnet-price-data))
      (try! (liquidate-position pyth-price-feed-data collateral user liquidator-repay-amount min-collateral-expected))
      (if (is-some swap-data)
        (let 
          (
            (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance SELF))))
            (collateral-obtained (- (try! (contract-call? collateral get-balance SELF)) initial-collateral-balance ))
            ;; TODO: Consider to make min out 0 and check expected market-asset in the end
            (asset-min-out (compute-min-out asset-amount-repaid))
            (market-balance-before (try! (contract-call? market-asset get-balance SELF)))
            (swap-result (swap-alex (merge (unwrap-panic swap-data) {dx: collateral-obtained, min-out: (some asset-min-out)})))
            (market-balance-after (try! (contract-call? market-asset get-balance SELF)))
          )
          ;; This check ensures that in the end of the swap operation we receive market-asset and swap-data passed properly.
          (asserts! (>= (- market-balance-after market-balance-before) asset-min-out) ERR-SWAP-RESULT)
          (print {
            initial-market-balance: initial-market-balance,
            initial-collateral-balance: initial-collateral-balance,
            asset-amount-repaid: asset-amount-repaid,
            collateral-obtained: collateral-obtained,
            asset-min-out: asset-min-out,
            market-balance-before: market-balance-before,
            market-balance-after: market-balance-after,
            swap-result: (- market-balance-after market-balance-before),
            action: "liquidate-swap"
          })
          SUCCESS
        )
        (let
          (
            (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance SELF))))
            (collateral-obtained (- (try! (contract-call? collateral get-balance SELF)) initial-collateral-balance ))
          ) 
          (print {
            initial-market-balance: initial-market-balance,
            initial-collateral-balance: initial-collateral-balance,
            asset-amount-repaid: asset-amount-repaid,
            collateral-obtained: collateral-obtained,
            action: "liquidate-no-swap"
          })
          SUCCESS
        )
      )
    )
  )
)

(define-public (batch-liquidate
  (pyth-price-feed-data (optional (buff 8192)))
  (market-asset <ft-trait>)
  (collateral <ft-trait>)
  (batch (list 20 (optional {
    user: principal,
    liquidator-repay-amount: uint,
    min-collateral-expected: uint
  })))
  (deadline uint)
  (swap-data (optional {
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
  ;; TODO: remove when we have a stable mainnet version
  (pyth-testnet-price-data (optional (buff 4096)))
)
  (begin
    (asserts! (or (is-owner) (is-operator)) ERR-UNAUTHORIZED)
    (asserts! (is-eq MARKET-ASSET (contract-of market-asset)) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (is-eq COLLATERAL-ASSET (contract-of collateral)) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (> deadline (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1)))) ERR-TIMEOUT)
    (let 
      (
        (initial-market-balance (try! (contract-call? market-asset get-balance SELF)))
        (initial-collateral-balance (try! (contract-call? collateral get-balance SELF)))
      )
      (try! (set-price-testnet pyth-testnet-price-data))
      (try! (batch-liquidate-position pyth-price-feed-data collateral batch))
      (if (is-some swap-data)
        (let 
          (
            (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance SELF))))
            (collateral-obtained (- (try! (contract-call? collateral get-balance SELF)) initial-collateral-balance))
            ;; TODO: Consider to make min out 0 and check expected market-asset in the end
            (asset-min-out (compute-min-out asset-amount-repaid))
            (market-balance-before (try! (contract-call? market-asset get-balance SELF)))
            (swap-result (swap-alex (merge (unwrap-panic swap-data) {dx: collateral-obtained, min-out: (some asset-min-out)})))
            (market-balance-after (try! (contract-call? market-asset get-balance SELF)))
          )
          ;; This check ensures that in the end of the swap operation we receive market-asset and swap-data passed properly.
          (asserts! (>= (- market-balance-after market-balance-before) asset-min-out) ERR-SWAP-RESULT)
          (print {
            initial-market-balance: initial-market-balance,
            initial-collateral-balance: initial-collateral-balance,
            asset-amount-repaid: asset-amount-repaid,
            collateral-obtained: collateral-obtained,
            asset-min-out: asset-min-out,
            market-balance-before: market-balance-before,
            market-balance-after: market-balance-after,
            swap-result: (- market-balance-after market-balance-before),
            action: "liquidate-batch-swap"
          })
          SUCCESS
        )
        (let
          (
            (asset-amount-repaid (- initial-market-balance (try! (contract-call? market-asset get-balance SELF))))
            (collateral-obtained (- (try! (contract-call? collateral get-balance SELF)) initial-collateral-balance ))
          ) 
          (print {
            initial-market-balance: initial-market-balance,
            initial-collateral-balance: initial-collateral-balance,
            asset-amount-repaid: asset-amount-repaid,
            collateral-obtained: collateral-obtained,
            action: "liquidate-batch-no-swap"
          })
          SUCCESS
        )
      )
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

;; TODO: remove when we have a stable mainnet version
(define-private (set-price-testnet-inner 
  (data {
    price-identifier: (buff 32),
    price: int,
    conf: uint,
    expo: int,
    ema-price: int,
    ema-conf: uint,
    publish-time: uint,
    prev-publish-time: uint})
  ) 
  (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-storage-v3 set-price-testnet data))
)

;; TODO: remove when we have a stable mainnet version
(define-public (set-price-testnet
  (data-raw (optional (buff 4096)))
)
  (begin
    (if (and (is-eq is-in-mainnet false) (is-some data-raw))
      (let 
        (
          (buff (unwrap! data-raw ERR-TESTNET-PRICE-DATA-ERROR))
          (data (unwrap! (from-consensus-buff? (list 20 {
                price-identifier: (buff 32),
                price: int,
                conf: uint,
                expo: int,
                ema-price: int,
                ema-conf: uint,
                publish-time: uint,
                prev-publish-time: uint,
              }) buff) ERR-TESTNET-PRICE-PARSE-ERROR))
        )
        (map set-price-testnet-inner data)
        SUCCESS
      )
      SUCCESS
    )
  )
)

(define-private (liquidate-position
    (pyth-price-feed-data (optional (buff 8192)))
    (collateral <ft-trait>)
    (user principal)
    (liquidator-repay-amount uint)
    (min-collateral-expected uint)
  )
  (as-contract (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.liquidator-v1 liquidate-collateral
    pyth-price-feed-data
    collateral
    user
    liquidator-repay-amount
    min-collateral-expected
  ))
)

(define-private (batch-liquidate-position
    (pyth-price-feed-data (optional (buff 8192)))
    (collateral <ft-trait>)
    (batch (list 20 (optional {
      user: principal,
      liquidator-repay-amount: uint,
      min-collateral-expected: uint
    })))
  )
  (as-contract (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.liquidator-v1 batch-liquidate
    pyth-price-feed-data
    collateral
    batch
  ))
)

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

(define-public (deposit-stx (amount uint))
  (stx-transfer? amount contract-caller SELF)
)

(define-public (withdraw-stx (amount uint))
  (let
    (
      (caller contract-caller)
    )
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (as-contract (stx-transfer? amount contract-caller caller))
  )
)
```
