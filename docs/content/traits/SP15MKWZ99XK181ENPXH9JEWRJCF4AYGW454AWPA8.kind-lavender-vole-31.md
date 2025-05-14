---
title: "Trait kind-lavender-vole-31"
draft: true
---
```
(use-trait ft 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ft-trait.ft-trait)

(define-constant wstx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant zsbtc 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0)
(define-constant sbtc 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant err-not-found (err u8000000))

(define-constant one u100000000)

(define-read-only (get-sbtc-rewards (who principal))
    (let (
        ;; gets with interest
        (reward-balance (unwrap-panic (convert-to sbtc wstx (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 get-balance who)))))
        (reward-decimals (unwrap-panic (get-precision wstx)))
        (reward-program-income-state (unwrap-panic (get-reward-program-income sbtc wstx)))
        )
        ;; get increase in rewards
        (let (
            (cumulated-balance
                (unwrap-panic
                    (calculate-cumulated-balance
                        who
                        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
                        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
                        reward-balance
                        reward-decimals
                        reward-program-income-state
                    )
                )
            )
            (balance-increase (- cumulated-balance reward-balance))
            )
            balance-increase
        )
    )
)

(define-read-only (get-precision (asset <ft>))
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives get-precision asset)
)

(define-read-only (convert-to
    (from <ft>)
    (to <ft>)
    (from-amount uint))
    (begin
        (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives convert-to
            from
            to
            from-amount
        )
    )
)

(define-read-only (get-y-from-x
  (x uint)
  (x-decimals uint)
  (y-decimals uint)
  (x-price uint)
  (y-price uint)
  )
  (if (> x-decimals y-decimals)
    ;; decrease decimals if x has more decimals
    (/ (div-precision-with-factor (mul-precision-with-factor x x-decimals x-price) x-decimals y-price) (pow u10 (- x-decimals y-decimals)))
    ;; do operations in the amounts with greater decimals, convert x to y-decimals
    (div-precision-with-factor (mul-precision-with-factor ( * x (pow u10 (- y-decimals x-decimals))) y-decimals x-price) y-decimals y-price)
  )
)



(define-read-only (calculate-cumulated-balance
  (who principal)
  (lp-supplied-asset <ft>)
  (supplied-asset <ft>)
  (reward-asset <ft>)
  (asset-balance uint)
  (asset-decimals uint)
  (rewarded-reserve-data {
    liquidity-rate: uint,
    last-updated-block: uint,
    last-liquidity-cumulative-index: uint
  })
  )
  (let (
        (reserve-normalized-income
            (get-normalized-income
                (get liquidity-rate rewarded-reserve-data)
                (get last-updated-block rewarded-reserve-data)
                (get last-liquidity-cumulative-index rewarded-reserve-data))
        )
    )
      (ok 
        (mul-precision-with-factor
          asset-balance
          asset-decimals
          (div
            reserve-normalized-income
            (unwrap! (get-user-program-index-eval asset-balance who (get last-liquidity-cumulative-index rewarded-reserve-data)) err-not-found)))
      )
  )
)

(define-read-only (get-user-program-index-eval
    (balance uint)
    (who principal)
    (last-liquidity-cumulative-index uint))
    (match (get-user-program-index who sbtc wstx)
        index (ok index)
        (if (> balance u0)
            (ok one)
            (ok last-liquidity-cumulative-index)
        )
    )
)


(define-read-only (get-normalized-income
  (current-liquidity-rate uint)
  (last-updated-block uint)
  (last-liquidity-cumulative-index uint))
  (let (
    (cumulated 
      (calculate-linear-interest
        current-liquidity-rate
        (- stacks-block-height last-updated-block))))
    (mul cumulated last-liquidity-cumulative-index)
  )
)

(define-private (get-user-program-index
    (who principal)
    (supplied-asset <ft>)
    (reward-asset <ft>)
    )
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives get-user-program-index
        who
        supplied-asset
        reward-asset
    )
)

(define-private (get-reward-program-income
    (supplied-asset <ft>)
    (reward-asset <ft>)
    )
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives get-reward-program-income
        supplied-asset
        reward-asset
    )
)


(define-read-only (calculate-linear-interest
  (current-liquidity-rate uint)
  (delta uint))
  (let ((rate (get-rt-by-block current-liquidity-rate delta)))
    (+ one rate)
  )
)

(define-read-only (mul (x uint) (y uint)) (/ (+ (* x y) (/ one u2)) one))
(define-read-only (div (x uint) (y uint)) (/ (+ (* x one) (/ y u2)) y))

(define-read-only (div-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x (pow u10 arbitrary-prec)) (/ y u2)) y))

(define-read-only (mul-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x y) (/ (pow u10 arbitrary-prec) u2)) (pow u10 arbitrary-prec)))

(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a u8)
    (mul-arbitrary a (* b-fixed (pow u10 (- decimals-a u8))) decimals-a)
    (/
      (mul-arbitrary (* a (pow u10 (- u8 decimals-a))) b-fixed u8)
      (pow u10 (- u8 decimals-a)))
  )
)

(define-read-only (div-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a u8)
    (div-arbitrary a (* b-fixed (pow u10 (- decimals-a u8))) decimals-a)
    (/
      (div-arbitrary (* a (pow u10 (- u8 decimals-a))) b-fixed u8)
      (pow u10 (- u8 decimals-a)))
  )
)

(define-read-only (get-rt-by-block (rate uint) (delta uint))
  (if (is-eq delta u0)
    u0
    (let (
      (start-time (unwrap-panic (get-stacks-block-info? time (- stacks-block-height delta))))
      (end-time (+ u5 (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))))
      (delta-time (- end-time start-time))
    )
      (/ (* rate delta-time) u31536000)
    )
  )
)
```
