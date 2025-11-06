;; SPDX-License-Identifier: BUSL-1.1

(define-read-only (get-market-data)
  (let (
    (lp-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params))
    (interest-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-accrue-interest-params))
    (debt-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-debt-params))
    (borrowable-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-borrowable-balance))
    (asset-cap (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-asset-cap))
  )
    (ok {
      lp-params: lp-params,
      interest-params: interest-params,
      debt-params: debt-params,
      borrowable-balance: borrowable-balance,
      asset-cap: asset-cap,
    })
  )
)

(define-read-only (get-market-borrower-flags)
  (let
    (
      (borrow-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-borrow-enabled))
      (repay-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-repay-enabled))
      (add-collateral-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-add-collateral-enabled))
      (remove-collateral-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-remove-collateral-enabled))
      (interest-accrual-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-interest-accrual-enabled))
    )
    (ok {
      borrow-enabled: borrow-enabled,
      repay-enabled: repay-enabled,
      add-collateral-enabled: add-collateral-enabled,
      remove-collateral-enabled: remove-collateral-enabled,
      interest-accrual-enabled: interest-accrual-enabled,
    }))
)

(define-read-only (get-market-lp-liquidation-flags)
  (let
    (
      (deposit-asset-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-deposit-asset-enabled))
      (withdraw-asset-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-withdraw-asset-enabled))
      (liquidation-enabled (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 is-liquidation-enabled))
    )
    (ok {
      deposit-asset-enabled: deposit-asset-enabled,
      withdraw-asset-enabled: withdraw-asset-enabled,
      liquidation-enabled: liquidation-enabled,
    }))
)
