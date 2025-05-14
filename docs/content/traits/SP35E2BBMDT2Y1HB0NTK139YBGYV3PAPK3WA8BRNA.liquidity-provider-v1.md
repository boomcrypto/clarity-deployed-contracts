---
title: "Trait liquidity-provider-v1"
draft: true
---
```
;; ERRORS
(define-constant ERR-INTEREST-PARAMS (err u10000))

;; CONSTANTS
(define-constant SUCCESS (ok true))

;; PUBLIC FUNCTIONS
(define-public (deposit (assets uint) (recipient principal))
  (begin
    (try! (accrue-interest))
    (try! (contract-call? .state-v1 add-assets contract-caller recipient assets (contract-call? .math-v1 convert-to-shares (contract-call? .state-v1 get-lp-params) assets false)))
    SUCCESS  
))

(define-public (withdraw (assets uint) (recipient principal))
  (begin
    (try! (accrue-interest))
    (try! (contract-call? .state-v1 remove-assets contract-caller recipient assets (contract-call? .math-v1 convert-to-shares (contract-call? .state-v1 get-lp-params) assets true)))
    SUCCESS  
))

(define-public (redeem (shares uint) (recipient principal))
  (begin
    (try! (accrue-interest))
    (let
      (
        (asset-params (contract-call? .state-v1 get-lp-params))
        (assets (contract-call? .math-v1 convert-to-assets asset-params shares false))
      )
      (try! (contract-call? .state-v1 remove-assets contract-caller recipient assets shares))
      SUCCESS
    )
))

;; PRIVATE FUNCTIONS
(define-private (accrue-interest)
  (let (
      (accrue-interest-params (unwrap! (contract-call? .state-v1 get-accrue-interest-params) ERR-INTEREST-PARAMS))
      (accrued-interest (try! (contract-call? .linear-kinked-ir-v1 accrue-interest
        (get last-accrued-block-time accrue-interest-params)
        (get lp-interest accrue-interest-params)
        (get staked-interest accrue-interest-params)
        (try! (contract-call? .staking-reward-v1 calculate-staking-reward-percentage (contract-call? .staking-v1 get-active-staked-lp-tokens)))
        (get protocol-interest accrue-interest-params)
        (get protocol-reserve-percentage accrue-interest-params)
        (get total-assets accrue-interest-params)))
      )
    )
    (contract-call? .state-v1 set-accrued-interest accrued-interest)
))

```
