;; SPDX-License-Identifier: BUSL-1.1
;; TITLE: kinked-interest-rate-utility
;; VERSION: 1.0

;; CONSTANTS
(define-constant one-8 u100000000)
(define-constant one-12 u1000000000000)
(define-constant fact_2 u2000000000000)
(define-constant fact_3 u6000000000000)
(define-constant fact_4 u24000000000000)
(define-constant fact_5 u120000000000000)
(define-constant fact_6 u720000000000000)
(define-constant seconds-in-year u31536000)


;; READ-ONLY FUNCTIONS 

;; Accrues interest based on the the last accrued block
;; returns updated lp interest, staked interest, protocol interest, total assets, and last accrued block
(define-read-only (accrue-interest 
    (last-accrued-block-time uint)
    (lp-open-interest uint)
    (staked-open-interest uint)
    (staking-reward-percentage uint)
    (protocol-open-interest uint)
    (protocol-reserve-percentage uint)
    (total-assets uint)
    (time-now uint)
    (ir-slope-1 uint) (ir-slope-2 uint) (utilization-kink uint) (base-ir uint)
  )
  (let (
    (elapsed-block-time (- time-now last-accrued-block-time))
    (premature-return (asserts!
      (not (is-eq u0 elapsed-block-time))
      (ok {
        last-accrued-block-time: last-accrued-block-time,
        lp-open-interest: lp-open-interest,
        protocol-open-interest: protocol-open-interest,
        staked-open-interest: staked-open-interest,
        total-assets: total-assets
      })))
    (open-interest (+ (+ lp-open-interest protocol-open-interest) staked-open-interest))
    (interest-rate-per-block (get-ir total-assets open-interest ir-slope-1 ir-slope-2 utilization-kink base-ir))
    (compounded-interest-rate (compounded-interest interest-rate-per-block elapsed-block-time))
    (total-interest (calc-total-interest compounded-interest-rate open-interest))
    (protocol-interest (/ (* total-interest protocol-reserve-percentage) one-8))
    (lp-interest (- total-interest protocol-interest))
    (staked-interest (/ (* lp-interest staking-reward-percentage) one-8))
  )
    (print {
        interest-rate-per-block: interest-rate-per-block,
        compounded-interest-rate: compounded-interest-rate,
        total-interest: total-interest,
        lp-open-interest: lp-interest,
        protocol-open-interest: protocol-interest,
      })
    (ok {
      last-accrued-block-time: time-now,
      lp-open-interest: (+ lp-open-interest (- lp-interest staked-interest)),
      staked-open-interest: (+ staked-open-interest staked-interest),
      protocol-open-interest: (+ protocol-open-interest protocol-interest),
      total-assets: (+ total-assets lp-interest),
    })
  )
)

;; PRIVATE HELPER FUNCTIONS 
;; total-assets and open-interest are fixed to u8 precision
(define-private (utilization-calc (total-assets uint) (open-interest uint))
  (if (> (+ total-assets open-interest) u0) (/ (* open-interest one-12) total-assets) u0)
)

(define-private (get-ir (total-assets uint) (open-interest uint) (ir-slope-1 uint) (ir-slope-2 uint) (utilization-kink uint) (base-ir uint))
  (ir-calc (utilization-calc total-assets open-interest) ir-slope-1 ir-slope-2 utilization-kink base-ir))

(define-private (compounded-interest (current-interest-rate uint) (elapsed-block-time uint))
  (taylor-6 (get-rt-by-block current-interest-rate elapsed-block-time)))


(define-private (calc-total-interest (ir uint) (open-ir uint))
  (let ((interest-factor (- ir one-12))
    (total-interest (divide-round-up (* open-ir interest-factor) one-12)))
    total-interest
))

(define-private (divide-round-up (numerator uint) (denominator uint))
  (if (> (mod numerator denominator) u0)
    (+ u1 (/ numerator denominator))
    (/ numerator denominator)
))

(define-private (interest-util-less-than-kink (util-with-res uint) (ir-slope-1 uint) (base-ir uint)) 
  (+ (/ (* ir-slope-1 util-with-res) one-12) base-ir)
)

(define-private (interest-util-geq-kink (util-with-res uint) (ir-slope-1 uint) (ir-slope-2 uint) (utilization-kink uint) (base-ir uint)) 
  (+ 
    (/
      (+ 
        (* ir-slope-2 (- util-with-res utilization-kink)) 
        (* ir-slope-1 utilization-kink)
      )
      one-12
    ) 
    base-ir
))

(define-private (ir-calc (util-with-res uint) (ir-slope-1 uint) (ir-slope-2 uint) (utilization-kink uint) (base-ir uint))
  (if (is-eq util-with-res u0)
    u0
    (if
      (>= util-with-res utilization-kink)
        (interest-util-geq-kink util-with-res ir-slope-1 ir-slope-2 utilization-kink base-ir)
        (interest-util-less-than-kink util-with-res ir-slope-1 base-ir)
    )
))

(define-private (mul (x uint) (y uint))
	(/ (+ (* x y) (/ one-12 u2)) one-12)
)

(define-private (div (x uint) (y uint))
	(/ (+ (* x one-12) (/ y u2)) y)
)

;; rate in 12-fixed
;; n-blocks
(define-private (get-rt-by-block (rate uint) (elapsed-block-time uint))
  (/ (* rate (/ (* elapsed-block-time one-12) seconds-in-year)) one-12)
)

;; taylor series expansion to the 6th degree to estimate e^x
(define-private (taylor-6 (x uint))
  (let (
      (x_2 (mul x x))
      (x_3 (mul x x_2))
      (x_4 (mul x x_3))
      (x_5 (mul x x_4))
      (x_6 (mul x x_5))
    )
    (+
      one-12 
      x
      (div x_2 fact_2)
      (div x_3 fact_3)
      (div x_4 fact_4)
      (div x_5 fact_5)
      (div x_6 fact_6)
    )
))
