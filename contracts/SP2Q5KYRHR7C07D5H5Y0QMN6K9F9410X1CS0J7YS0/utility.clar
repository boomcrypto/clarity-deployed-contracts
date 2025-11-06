;; SPDX-License-Identifier: BUSL-1.1

(define-read-only (get-market-borrower-data)
  (let (
    (debt-params (contract-call? .state-v1 get-debt-params))
    (borrowable-balance (contract-call? .state-v1 get-borrowable-balance))
  )
    (ok {
      debt-params: debt-params,
      borrowable-balance: borrowable-balance,
    })
  )
)

(define-read-only (get-market-lp-data)
  (let (
    (lp-params (contract-call? .state-v1 get-lp-params))
    (asset-cap (contract-call? .state-v1 get-asset-cap))
  )
    (ok {
      lp-params: lp-params,
      asset-cap: asset-cap,
    })
  )
)

(define-read-only (get-interest-data)
  (let (
    (interest-params (contract-call? .state-v1 get-accrue-interest-params))
    (interest-accrual-enabled (contract-call? .state-v1 is-interest-accrual-enabled))
  )
    (ok {
      interest-params: interest-params,
      interest-accrual-enabled: interest-accrual-enabled,
    })
  )
)

(define-read-only (get-market-borrower-flags)
  (let
    (
      (borrow-enabled (contract-call? .state-v1 is-borrow-enabled))
      (repay-enabled (contract-call? .state-v1 is-repay-enabled))
    )
    (ok {
      borrow-enabled: borrow-enabled,
      repay-enabled: repay-enabled,
    }))
)

(define-read-only (get-market-collateral-flags)
  (let
    (
      (add-collateral-enabled (contract-call? .state-v1 is-add-collateral-enabled))
      (remove-collateral-enabled (contract-call? .state-v1 is-remove-collateral-enabled))
    )
    (ok {
      add-collateral-enabled: add-collateral-enabled,
      remove-collateral-enabled: remove-collateral-enabled,
    }))
)

(define-read-only (get-market-lp-flags)
  (let
    (
      (deposit-asset-enabled (contract-call? .state-v1 is-deposit-asset-enabled))
      (withdraw-asset-enabled (contract-call? .state-v1 is-withdraw-asset-enabled))
    )
    (ok {
      deposit-asset-enabled: deposit-asset-enabled,
      withdraw-asset-enabled: withdraw-asset-enabled,
    }))
)

(define-read-only (get-market-liquidation-flags)
  (let ((liquidation-enabled (contract-call? .state-v1 is-liquidation-enabled)))
    (ok {liquidation-enabled: liquidation-enabled}))
)
