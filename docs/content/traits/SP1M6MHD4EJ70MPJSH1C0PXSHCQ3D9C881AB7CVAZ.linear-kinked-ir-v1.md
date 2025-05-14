---
title: "Trait linear-kinked-ir-v1"
draft: true
---
```
;; TITLE: kinked-interest-rate-module
;; VERSION: 1.0

  
;; ERROR VALUES
(define-constant SUCCESS (ok true))
(define-constant ERR-CONTRACT-ALREADY-INITIATED (err u70000))
(define-constant ERR-NEED-TO-INIT-FROM-LAUNCH-PRINCIPAL (err u70001))
(define-constant ERR-NOT-INITIALIZED (err u70002))
(define-constant ERR-NOT-GOVERNANCE (err u70003))
(define-constant ERR-INVALID-UTILIZATION-KINK (err u70004))

;; CONSTANTS
(define-constant one-8 u100000000)
(define-constant one-12 u1000000000000)
(define-constant fact_2 u2000000000000)
(define-constant fact_3 u6000000000000)
(define-constant fact_4 u24000000000000)
(define-constant fact_5 u120000000000000)
(define-constant fact_6 u720000000000000)
(define-constant seconds-in-year u31536000)
(define-constant STACKS_BLOCK_TIME (contract-call? .constants-v1 get-stacks-block-time ))

;; DATA-VARS 
(define-constant contract-deployer contract-caller)
(define-data-var is-initialized bool false)
(define-data-var ir-slope-1 uint u0)
(define-data-var ir-slope-2 uint u0)
(define-data-var utilization-kink uint u0)
(define-data-var base-ir uint u0) ;; interest when utilization is 0


;; PUBLIC FUNCTIONS 
(define-public (update-ir-params (ir-slope-1-val uint) (ir-slope-2-val uint) (utilization-kink-val uint) (base-ir-val uint))
  (begin 
    ;; guard clauses
    (if (not (var-get is-initialized)) 
      (begin
        (asserts! (is-eq contract-caller contract-deployer) ERR-NEED-TO-INIT-FROM-LAUNCH-PRINCIPAL)
        (var-set is-initialized true)
      )
      (begin
        (asserts! (not (is-eq contract-caller contract-deployer)) ERR-CONTRACT-ALREADY-INITIATED)
        (asserts! (is-eq contract-caller (contract-call? .state-v1 get-governance)) ERR-NOT-GOVERNANCE)
      )
    )

    (asserts! (< utilization-kink-val one-12) ERR-INVALID-UTILIZATION-KINK)
    (print {
        old-ir-slope-1: (var-get ir-slope-1),
        new-ir-slope-1: ir-slope-1-val,
        old-ir-slope-2: (var-get ir-slope-2),
        new-ir-slope-2: ir-slope-2-val,
        old-utilization-kink: (var-get utilization-kink),
        new-utilization-kink: utilization-kink-val,
        old-base-ir: (var-get base-ir),
        new-base-ir: base-ir-val,
        user: contract-caller,
        action: "update-ir-params"
    })

    ;; set data-vars
    (var-set ir-slope-1 ir-slope-1-val)
    (var-set ir-slope-2 ir-slope-2-val)
    (var-set utilization-kink utilization-kink-val)
    (var-set base-ir base-ir-val)

    ;; return val
    SUCCESS
))

;; READ-ONLY FUNCTIONS 

;; Accrues interest based on the the last accrued block
;; returns updated lp interest, staked interest, protocol interest, total assets, and last accrued block
(define-read-only (accrue-interest (last-accrued-block-time uint) (lp-open-interest uint) (staked-open-interest uint) (staking-reward-percentage uint) (protocol-open-interest uint) (protocol-reserve-percentage uint) (total-assets uint))
  (let (
    (time-now (+ (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) STACKS_BLOCK_TIME))
    (elapsed-block-time (- time-now last-accrued-block-time))
    (premature-return (asserts!
      (not (or (is-eq u0 elapsed-block-time) (not (contract-call? .state-v1 is-interest-accrual-enabled))))
      (ok {
        last-accrued-block-time: last-accrued-block-time,
        lp-open-interest: lp-open-interest,
        protocol-open-interest: protocol-open-interest,
        staked-open-interest: staked-open-interest,
        total-assets: total-assets
      })))
    (open-interest (+ (+ lp-open-interest protocol-open-interest) staked-open-interest))
    (interest-rate-per-block (try! (get-ir total-assets open-interest)))
    (compounded-interest-rate (try! (compounded-interest interest-rate-per-block elapsed-block-time)))
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

;; total-assets and open-interest are fixed to u8 precision
(define-read-only (utilization-calc (total-assets uint) (open-interest uint))
  (if (> (+ total-assets open-interest) u0) (/ (* open-interest one-12) total-assets) u0)
)

(define-read-only (get-ir (total-assets uint) (open-interest uint))
  (begin
  	(asserts! (var-get is-initialized) ERR-NOT-INITIALIZED)
  	(ok (ir-calc (utilization-calc total-assets open-interest)))
))

(define-read-only (compounded-interest (current-interest-rate uint) (elapsed-block-time uint))
  (begin
    (asserts! (var-get is-initialized) ERR-NOT-INITIALIZED)
    (ok (taylor-6 (get-rt-by-block current-interest-rate elapsed-block-time)))
))

(define-read-only (get-ir-params)
  {
    ir-slope-1: (var-get ir-slope-1),
    ir-slope-2: (var-get ir-slope-2),
    utilization-kink: (var-get utilization-kink),
    base-ir: (var-get base-ir)
})
  
;; PRIVATE HELPER FUNCTIONS 
(define-read-only (calc-total-interest (ir uint) (open-ir uint))
  (let ((interest-factor (- ir one-12))
    (total-interest (contract-call? .math-v1 divide-round-up (* open-ir interest-factor) one-12)))
    total-interest
))

(define-private (interest-util-less-than-kink (util-with-res uint)) 
  (+ (/ (* (var-get ir-slope-1) util-with-res) one-12) (var-get base-ir))
)

(define-private (interest-util-geq-kink (util-with-res uint)) 
  (+ 
    (/
      (+ 
        (* (var-get ir-slope-2) (- util-with-res (var-get utilization-kink))) 
        (* (var-get ir-slope-1) (var-get utilization-kink))
      )
      one-12
    ) 
    (var-get base-ir)
))

(define-private (ir-calc (util-with-res uint))
  (if (is-eq util-with-res u0)
    u0
    (if
      (>= util-with-res (var-get utilization-kink))
        (interest-util-geq-kink util-with-res)
        (interest-util-less-than-kink util-with-res)
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
(define-read-only (get-rt-by-block (rate uint) (elapsed-block-time uint))
  (/ (* rate (/ (* elapsed-block-time one-12) seconds-in-year)) one-12)
)

;; taylor series expansion to the 6th degree to estimate e^x
(define-read-only (taylor-6 (x uint))
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

```
