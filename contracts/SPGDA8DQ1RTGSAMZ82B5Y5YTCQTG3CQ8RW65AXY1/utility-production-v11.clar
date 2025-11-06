;; SPDX-License-Identifier: BUSL-1.1

;; constants
(define-constant SCALING-FACTOR u100000000)

;; errors
(define-constant ERR-INTEREST-PARAMS (err u120001))
(define-constant ERR-FAILED-TO-GET-BALANCE (err u120002))
(define-constant ERR-FAILED-TO-GET-DEBT-BUCKET (err u120003))


;; read-only functions
(define-read-only (get-market-state)
  (let (
    (accrue-interest-params (unwrap! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-accrue-interest-params) ERR-INTEREST-PARAMS))
    (accrued-interest (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.linear-kinked-ir-v1 accrue-interest
      (get last-accrued-block-time accrue-interest-params)
      (get lp-interest accrue-interest-params)
      (get staked-interest accrue-interest-params)
      (try! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.staking-reward-v1 calculate-staking-reward-percentage (contract-call? 'SP3BJR4P3W2Y9G22HA595Z59VHBC9EQYRFWSKG743.staking-v1 get-active-staked-lp-tokens)))
      (get protocol-interest accrue-interest-params)
      (get protocol-reserve-percentage accrue-interest-params)
      (get total-assets accrue-interest-params)))
    )
    (reserve-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-reserve-balance ))
    (asset-cap (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-asset-cap ))
    (borrowable-balance (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-borrowable-balance ))
    (total-debt-shares (get total-debt-shares (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-debt-params )))
    (total-lp-shares (unwrap! (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-total-supply ) ERR-FAILED-TO-GET-BALANCE)))
    (ok (merge accrued-interest {
        last-accrued-block-time: (get last-accrued-block-time accrue-interest-params),
        reserve-balance: reserve-balance,
        asset-cap: asset-cap,
        borrowable-balance: borrowable-balance,
        total-debt-shares: total-debt-shares,
        total-lp-shares: total-lp-shares
      }
    ))
))

(define-read-only (get-withdrawal-caps (inflow uint))
  (let (
      (lp (try! (get-lp-bucket inflow)))
      (debt (unwrap! (get-debt-bucket inflow) ERR-FAILED-TO-GET-DEBT-BUCKET))
      (collateral (try! (get-collateral-bucket inflow)))
    )
    (ok {lp: lp, debt: debt, collateral: collateral})
))



(define-private (min (a uint) (b uint)) (if (> a b) b a ))

(define-private (get-time-now) (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))))

(define-private (refill-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (refill-window (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-refill-time-window))
      (elapsed (if (is-eq last-updated-at u0) refill-window (- time-now last-updated-at)))
      (refill-amount (if (>= elapsed refill-window) max-bucket (/ (* max-bucket elapsed) refill-window)))
      (new-bucket (min (+ current-bucket refill-amount) max-bucket))
  )
    (+ new-bucket inflow)
))

(define-private (decay-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (extra-bucket-amount (- current-bucket max-bucket))
      (decay-window (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-decay-time-window))
      (elapsed (if (is-eq last-updated-at u0) decay-window (- time-now last-updated-at)))
      (decayed-amount (if (>= elapsed decay-window) extra-bucket-amount (/ (* extra-bucket-amount elapsed) decay-window)))
      (new-bucket (- current-bucket decayed-amount))
  )
    (+ new-bucket inflow)
))

(define-private (get-lp-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-last-lp-bucket-update))
      (total-liquidity (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1) ERR-FAILED-TO-GET-BALANCE))
      (lp-cap-factor (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-lp-cap-factor))
      (max-lp-bucket (/ (* total-liquidity lp-cap-factor) SCALING-FACTOR))
      (current-bucket (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-lp-bucket))
      (new-bucket-value (if (>= current-bucket max-lp-bucket) 
          (decay-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)))
    )
    (ok {
      cap-factor: lp-cap-factor,
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-lp-bucket
    })
  )
)

(define-private (get-debt-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-last-debt-bucket-update))
      (total-liquidity (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-borrowable-balance))
      (debt-cap-factor (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-debt-cap-factor))
      (max-debt-bucket (/ (* total-liquidity debt-cap-factor) SCALING-FACTOR))
      (current-bucket (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-debt-bucket))
      (new-bucket-value (if (>= current-bucket max-debt-bucket) 
          (decay-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)))
    )
    (ok {
      cap-factor: debt-cap-factor,
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-debt-bucket
    })
  )
)

(define-private (get-collateral-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (collateral-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
      (last-ts (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-last-collateral-bucket-update collateral-token))
      (total-liquidity (unwrap! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1) ERR-FAILED-TO-GET-BALANCE))
      (collateral-cap-factor (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-collateral-cap-factor collateral-token))
      (max-collateral-bucket (/ (* total-liquidity collateral-cap-factor) SCALING-FACTOR))
      (current-bucket (contract-call? 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.withdrawal-caps-v1 get-collateral-bucket collateral-token))
      (new-bucket-value (if (>= current-bucket max-collateral-bucket) 
          (decay-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)))
    )
    (ok {
      cap-factor: collateral-cap-factor,
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-collateral-bucket
    })
  )
)