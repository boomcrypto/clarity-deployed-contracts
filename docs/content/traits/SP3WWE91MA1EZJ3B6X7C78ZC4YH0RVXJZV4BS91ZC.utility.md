---
title: "Trait utility"
draft: true
---
```
(define-read-only (get-contract-data)
  (let (
    (lp-params (contract-call? .state-v1 get-lp-params))
    (interest-params (contract-call? .state-v1 get-accrue-interest-params))
    (debt-params (contract-call? .state-v1 get-debt-params))
    (borrowable-balance (contract-call? .state-v1 get-borrowable-balance))
    (protocol-reserve-percentage (contract-call? .state-v1 get-protocol-reserve-percentage))
    (asset-cap (contract-call? .state-v1 get-asset-cap))
  )
    (ok {
      lp-params: lp-params,
      interest-params: interest-params,
      debt-params: debt-params,
      borrowable-balance: borrowable-balance,
      protocol-reserve-percentage: protocol-reserve-percentage,
      asset-cap: asset-cap,
    })
  )
)

(define-read-only (get-flags)
  (let
    (
      (borrow-enabled (contract-call? .state-v1 is-borrow-enabled))
      (repay-enabled (contract-call? .state-v1 is-repay-enabled))
      (add-collateral-enabled (contract-call? .state-v1 is-add-collateral-enabled))
      (remove-collateral-enabled (contract-call? .state-v1 is-remove-collateral-enabled))
      (liquidation-enabled (contract-call? .state-v1 is-liquidation-enabled))
      (interest-accrual-enabled (contract-call? .state-v1 is-interest-accrual-enabled))
      (deposit-asset-enabled (contract-call? .state-v1 is-deposit-asset-enabled))
      (withdraw-asset-enabled (contract-call? .state-v1 is-withdraw-asset-enabled))
    )
    (ok {
      borrow-enabled: borrow-enabled,
      repay-enabled: repay-enabled,
      add-collateral-enabled: add-collateral-enabled,
      remove-collateral-enabled: remove-collateral-enabled,
      liquidation-enabled: liquidation-enabled,
      interest-accrual-enabled: interest-accrual-enabled,
      deposit-asset-enabled: deposit-asset-enabled,
      withdraw-asset-enabled: withdraw-asset-enabled
    }))
)

```
