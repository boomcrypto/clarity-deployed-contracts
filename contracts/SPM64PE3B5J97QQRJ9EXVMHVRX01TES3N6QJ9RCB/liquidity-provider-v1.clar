;; SPDX-License-Identifier: BUSL-1.1

;; ERRORS
(define-constant ERR-INTEREST-PARAMS (err u10000))

;; CONSTANTS
(define-constant SUCCESS (ok true))

;; PUBLIC FUNCTIONS
(define-public (deposit (assets uint) (recipient principal))
  (begin
    (try! (accrue-interest))
    (let ((shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.math-v1 convert-to-shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params) assets false)))
      (try! (contract-call? .withdrawal-caps-v1 lp-deposit assets))
      (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 add-assets contract-caller recipient assets shares))
      (print { 
        recipient: recipient,
        assets: assets,
        shares: shares,
        user: contract-caller,
        lp-params: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params),
        action: "deposit",
      }))
    SUCCESS  
))

(define-public (withdraw (assets uint) (recipient principal))
  (begin
    (try! (contract-call? .withdrawal-caps-v1 check-withdrawal-lp-cap assets))
    (try! (accrue-interest))
    (let ((shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.math-v1 convert-to-shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params) assets true)))
      (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 remove-assets contract-caller recipient assets shares))
      (print {
        recipient: recipient,
        assets: assets,
        shares: shares,
        user: contract-caller,
        lp-params: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params),
        action: "withdraw"
      }))
    SUCCESS  
))

(define-public (redeem (shares uint) (recipient principal))
  (begin
    (try! (accrue-interest))
    (let
      (
        (asset-params (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params))
        (assets (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.math-v1 convert-to-assets asset-params shares false))
      )
      (try! (contract-call? .withdrawal-caps-v1 check-withdrawal-lp-cap assets))
      (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 remove-assets contract-caller recipient assets shares))
      SUCCESS
    )
))

;; PRIVATE FUNCTIONS
(define-private (accrue-interest)
  (let (
      (accrue-interest-params (unwrap! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-accrue-interest-params) ERR-INTEREST-PARAMS))
      (accrued-interest (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.linear-kinked-ir-v1 accrue-interest
        (get last-accrued-block-time accrue-interest-params)
        (get lp-interest accrue-interest-params)
        (get staked-interest accrue-interest-params)
        (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.staking-reward-v1 calculate-staking-reward-percentage (contract-call? .staking-v1 get-active-staked-lp-tokens)))
        (get protocol-interest accrue-interest-params)
        (get protocol-reserve-percentage accrue-interest-params)
        (get total-assets accrue-interest-params)))
      )
    )
    (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 set-accrued-interest accrued-interest)
))
