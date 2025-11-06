
(define-constant SCALING-FACTOR u100000000)
(define-constant ERR-FAILED-TO-GET-BALANCE (err u120001))

(define-read-only (min (a uint) (b uint)) (if (> a b) b a ))

(define-private (get-time-now)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

(define-private (refill-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (refill-window (contract-call? .withdrawal-caps-v1 get-refill-time-window))
      (elapsed (if (is-eq last-updated-at u0) refill-window (- time-now last-updated-at)))
      (refill-amount (if (>= elapsed refill-window) max-bucket (/ (* max-bucket elapsed) refill-window)))
      (new-bucket (min (+ current-bucket refill-amount) max-bucket))
  )
    (+ new-bucket inflow)
))

(define-private (decay-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (extra-bucket-amount (- current-bucket max-bucket))
      (decay-window (contract-call? .withdrawal-caps-v1 get-decay-time-window))
      (elapsed (if (is-eq last-updated-at u0) decay-window (- time-now last-updated-at)))
      (decayed-amount (if (>= elapsed decay-window) extra-bucket-amount (/ (* extra-bucket-amount elapsed) decay-window)))
      (new-bucket (- current-bucket decayed-amount))
  )
    (+ new-bucket inflow)
))

(define-read-only (get-lp-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (contract-call? .withdrawal-caps-v1 get-last-lp-bucket-update))
      (total-liquidity (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-lp-bucket (/ (* total-liquidity (contract-call? .withdrawal-caps-v1 get-lp-cap-factor)) SCALING-FACTOR))
      (current-bucket (contract-call? .withdrawal-caps-v1 get-lp-bucket))
      (new-bucket-value (if (>= current-bucket max-lp-bucket) 
          (decay-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)))
    )
    (ok {
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-lp-bucket
    })
  )
)

(define-read-only (get-debt-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (contract-call? .withdrawal-caps-v1 get-last-debt-bucket-update))
      (total-liquidity (contract-call? .state-v1 get-borrowable-balance))
      (max-debt-bucket (/ (* total-liquidity (contract-call? .withdrawal-caps-v1 get-debt-cap-factor)) SCALING-FACTOR))
      (current-bucket (contract-call? .withdrawal-caps-v1 get-debt-bucket))
      (new-bucket-value (if (>= current-bucket max-debt-bucket) 
          (decay-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)))
    )
    (ok {
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-debt-bucket
    })
  )
)

(define-read-only (get-collateral-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (collateral-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
      (last-ts (contract-call? .withdrawal-caps-v1 get-last-collateral-bucket-update collateral-token))
      (total-liquidity (unwrap! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-collateral-bucket (/ (* total-liquidity (contract-call? .withdrawal-caps-v1 get-collateral-cap-factor collateral-token)) SCALING-FACTOR))
      (current-bucket (contract-call? .withdrawal-caps-v1 get-collateral-bucket collateral-token))
      (new-bucket-value (if (>= current-bucket max-collateral-bucket) 
          (decay-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)))
    )
    (ok {
      old-bucket: current-bucket,
      new-bucket: new-bucket-value,
      max-bucket: max-collateral-bucket
    })
  )
)
