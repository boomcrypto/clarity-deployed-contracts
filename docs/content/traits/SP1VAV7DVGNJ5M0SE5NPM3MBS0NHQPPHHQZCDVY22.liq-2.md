---
title: "Trait liq-2"
draft: true
---
```
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(define-constant SCALING-FACTOR u10000)
(define-constant SUCCESS (ok true))
(define-constant ERR-UNAUTHORIZED (err u10000))
(define-constant ERR-TRANSFER-NULL (err u10001))
(define-constant ERR-TOKEN-NOT-SUPPORTED (err u10002))
(define-constant ERR-INSUFFICIENT-AMOUNT-OUT (err u10003))
(define-constant ERR-GRANITE-LIQUIDATION-FAILED (err u10004))
(define-constant ERR-INVALID-VALUE (err u10005))
(define-constant ERR-TIMEOUT (err u10006))
(define-map allowed-tokens principal bool)
(define-data-var unprofitability-threshold uint u0)
(define-data-var owner principal tx-sender)
(define-public (set-owner (new-owner principal))
  (begin
    (try! (is-owner))
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
    (try! (is-owner))
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
    (try! (is-owner))
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
    (try! (is-owner))
    (asserts! (unwrap! (map-get? allowed-tokens (contract-of token)) ERR-TOKEN-NOT-SUPPORTED) ERR-TOKEN-NOT-SUPPORTED)
    (try! (transfer-from token contract-caller amount))
    SUCCESS
  )
)
;; no assert needed, if the token has been deposited and removed from allow list afterwards, it could get stuck
(define-public (withdraw (token <ft-trait>) (amount uint))
  (begin
    (try! (is-owner))
    (try! (transfer-to token contract-caller amount))
    SUCCESS
  )
)
(define-public (liquidate-with-velar
  (pyth-price-feed-data (optional (buff 8192)))
  (user principal)
  (market-asset <ft-trait>)
  (collateral <ft-trait>)
  (liquidator-repay-amount uint)
  (min-collateral-expected uint)
  (deadline uint)
  (pool-trait <xyk-pool-trait>)
  (x-token-trait <ft-trait>)
  (y-token-trait <ft-trait>)
  (reversed bool)
  (id uint)
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (share-fee-to <share-fee-to-trait>)
)
  (begin
    (try! (is-owner))
    ;;(asserts! (> deadline (default-to u0 (get-stacks-block-info? time block-height))) ERR-TIMEOUT) ;; TODO uncomment for post Nakamoto
    (asserts! (unwrap! (map-get? allowed-tokens (contract-of token0)) ERR-TOKEN-NOT-SUPPORTED) ERR-TOKEN-NOT-SUPPORTED)
    (asserts! (unwrap! (map-get? allowed-tokens (contract-of token1)) ERR-TOKEN-NOT-SUPPORTED) ERR-TOKEN-NOT-SUPPORTED)
    (try! (liquidate-position
            pyth-price-feed-data
            collateral
            user
            liquidator-repay-amount
            min-collateral-expected
    ))
    (let 
      (
        (obtained-collateral (try! (contract-call? collateral get-balance (as-contract contract-caller))))
        (asset-min-out (compute-min-out liquidator-repay-amount obtained-collateral)) ;; TODO oracle or price as arg
        (swap-result (try!
          (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.router-xyk-velar-v-1-1 swap-helper-a
          obtained-collateral
          asset-min-out
          pool-trait
          x-token-trait
          y-token-trait
          reversed
          id
          token0
          token1
          collateral ;; token in
          market-asset ;; token out
          share-fee-to
        )))
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
  ;;
  ;;  (as-contract (contract-call? liquidator-granite liquidate-collateral
  ;;  pyth-price-feed-data
  ;;  collateral
  ;;  user
  ;;  liquidator-repay-amount
  ;;  min-collateral-expected
  ;;))
  ;;
  (begin
    (asserts! (> liquidator-repay-amount u0) ERR-INVALID-VALUE)
    SUCCESS
  )
)
(define-private (is-owner)
  (begin
    (asserts! (is-eq contract-caller (var-get owner)) ERR-UNAUTHORIZED)
    SUCCESS
  )
)
(define-private (compute-min-out (paid uint) (received uint))
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
    (try! (contract-call? token transfer amount user (as-contract contract-caller) none))
    SUCCESS
))
(define-private (transfer-to (token <ft-trait>) (user principal) (amount uint))
  (begin
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? token transfer amount (as-contract contract-caller) user none)))
    SUCCESS
))
```
