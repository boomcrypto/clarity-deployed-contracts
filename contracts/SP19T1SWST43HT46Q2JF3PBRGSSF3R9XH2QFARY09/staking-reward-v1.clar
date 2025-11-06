;; TITLE: staking-reward contract
;; SPDX-License-Identifier: BUSL-1.1
;; VERSION: 1.0

  
;; ERROR VALUES
(define-constant SUCCESS (ok true))
(define-constant ERR-CONTRACT-ALREADY-INITIATED (err u90000))
(define-constant ERR-NEED-TO-INIT-FROM-LAUNCH-PRINCIPAL (err u90001))
(define-constant ERR-NOT-INITIALIZED (err u90002))
(define-constant ERR-NOT-GOVERNANCE (err u90003))
(define-constant ERR-INVALID-STAKED-KINK (err u90004))
(define-constant ERR-INVALID-SLOPES (err u90005))
(define-constant ERR-LP-TOKEN-SUPPLY (err u90006))
(define-constant ERR-INVALID-BASE-REWARD (err u90007))


;; CONSTANTS
(define-constant one-8 (contract-call? .constants-v1 get-scaling-factor))

;; DATA-VARS 
(define-constant contract-deployer contract-caller)
(define-data-var is-initialized bool false)
(define-data-var slope-1 int 0)
(define-data-var slope-2 int 0)
(define-data-var staked-kink uint u0)
(define-data-var base-reward uint u0) 


;; PUBLIC FUNCTIONS 
(define-public (update-reward-params (slope-1-val int) (slope-2-val int) (staked-kink-val uint) (base-reward-val uint))
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

    (asserts! (< staked-kink-val one-8) ERR-INVALID-STAKED-KINK)
    (asserts! (< base-reward-val one-8) ERR-INVALID-BASE-REWARD)
    (asserts! (> slope-1-val slope-2-val) ERR-INVALID-SLOPES)
    (print {
        old-slope-1: (var-get slope-1),
        new-slope-1: slope-1-val,
        old-slope-2: (var-get slope-2),
        new-slope-2: slope-2-val,
        old-staked-kink: (var-get staked-kink),
        new-staked-kink: staked-kink-val,
        old-base-reward: (var-get base-reward),
        new-base-reward: base-reward-val,
        user: contract-caller,
        action: "update-staking-params"
    })

    ;; set data-vars
    (var-set slope-1 slope-1-val)
    (var-set slope-2 slope-2-val)
    (var-set staked-kink staked-kink-val)
    (var-set base-reward base-reward-val)

    ;; return val
    SUCCESS
))

;; READ-ONLY FUNCTIONS
(define-read-only (calculate-staking-reward-percentage (staked-lp-tokens uint))
  (let ((total-lp-tokens (unwrap! (contract-call? .state-v1 get-total-supply) ERR-LP-TOKEN-SUPPLY)))
    (get-staking-reward-percentage staked-lp-tokens total-lp-tokens)
))

(define-read-only (get-staking-reward-percentage (staked-lp-tokens uint) (total-lp-tokens uint))
  (begin
  	(asserts! (var-get is-initialized) ERR-NOT-INITIALIZED)
    (let ((reward-percentage (calculate-reward-percentage (staked-percentage-calc staked-lp-tokens total-lp-tokens))))
      (if (> reward-percentage 0)
        (ok (to-uint reward-percentage))
        (ok u0)
      )
)))

(define-read-only (get-reward-params)
  {
    slope-1: (var-get slope-1),
    slope-2: (var-get slope-2),
    staked-kink: (var-get staked-kink),
    base-reward: (var-get base-reward)
})

;; PRIVATE HELPER FUNCTIONS 
(define-private (staked-percentage-calc (staked-lp-tokens uint) (total-lp-tokens uint))
  (if (> total-lp-tokens u0) (/ (* staked-lp-tokens one-8) total-lp-tokens) u0)
)

(define-private (staked-less-than-kink (staked-percentage uint)) 
  (+ (/ (* (var-get slope-1) (to-int staked-percentage)) (to-int one-8)) (to-int (var-get base-reward)))
)

(define-private (staked-geq-kink (staked-percentage uint)) 
  (+ 
    (/
      (+ 
        (* (var-get slope-2) (to-int (- staked-percentage (var-get staked-kink)))) 
        (* (var-get slope-1) (to-int (var-get staked-kink)))
      )
      (to-int one-8)
    ) 
    (to-int (var-get base-reward))
))

(define-private (calculate-reward-percentage (staked-percentage uint))
  (if (is-eq staked-percentage u0) 
    0
    (if (>= staked-percentage (var-get staked-kink)) 
      (staked-geq-kink staked-percentage)
      (staked-less-than-kink staked-percentage)
    )
))
