;; SPDX-License-Identifier: BUSL-1.1

(define-read-only (get-market-data)
  (let (
    (lp-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params))
    ;; total assets
    ;; total lp shares
    (debt-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-debt-params))
    ;; open interest
    ;; total debt shares
    (borrowable-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-borrowable-balance))
    ;; free liquidity
    (interest-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-accrue-interest-params))
    ;; last accrued block time
    (reserve-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-reserve-balance))
    ;; reserve balance
  )
    (ok {
      lp-params: lp-params,
      debt-params: debt-params,
      borrowable-balance: borrowable-balance,
      interest-params: interest-params,
      reserve-balance: reserve-balance,
    })
  )
)

(define-read-only (get-user-state (user principal) (collateral principal))
  (let (
    (lp-shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-balance user))
    ;; lp shares
    (position (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-position user))
    ;; debt shares
    (collateral-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-collateral user collateral))
    ;; collateral deposited balance
  )
    (ok {
      lp-shares: lp-shares,
      position: position,
      collateral-balance: collateral-balance,
    })
  )
)
