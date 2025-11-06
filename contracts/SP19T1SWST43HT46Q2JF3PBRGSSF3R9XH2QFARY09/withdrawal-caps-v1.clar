;; TITLE: withdrawal-caps
;; SPDX-License-Identifier: BUSL-1.1
;; VERSION: 1.0

(use-trait token-trait .trait-sip-010.sip-010-trait)

;; CONSTANTS
(define-constant LP-CONTRACT (as-contract .liquidity-provider-v1))
(define-constant BORROWER-CONTRACT (as-contract .borrower-v1))
(define-constant LIQUIDATOR-CONTRACT (as-contract .liquidator-v1))
(define-constant SUCCESS (ok true))
(define-constant SCALING-FACTOR u100000000)

;; ERRORS
(define-constant ERR-RESTRICTED (err u120000))
(define-constant ERR-FAILED-TO-GET-BALANCE (err u120001))
(define-constant ERR-WITHDRAWAL-LP-CAP-EXCEEDED (err u120002))
(define-constant ERR-WITHDRAWAL-DEBT-CAP-EXCEEDED (err u120003))
(define-constant ERR-WITHDRAWAL-COLLATERAL-CAP-EXCEEDED (err u120004))
(define-constant ERR-INVALID-CAP-FACTOR (err u120005))
(define-constant ERR-NOT-AUTHORIZED (err u120006))

;; VARIABLES

;; refill time window of 24 hrs
;; updatable through governance
(define-data-var refill-time-window uint u86400)

;; decay time window of 3 hrs
;; updatable through governance
(define-data-var decay-time-window uint u10800)

;; LP
(define-data-var lp-cap-factor uint u0)
(define-data-var last-lp-bucket-update uint u0)
(define-data-var lp-bucket uint u0) ;; current available lp withdrawal credit

;; Debt
(define-data-var debt-cap-factor uint u0)
(define-data-var last-debt-bucket-update uint u0)
(define-data-var debt-bucket uint u0) ;; current available debt borrowing credit

;; Collateral
(define-map last-collateral-bucket-update principal uint)
(define-map collateral-bucket principal uint) ;; current available collateral withdrawal credit
(define-map collateral-cap-factor principal uint)


(define-read-only (get-refill-time-window) (var-get refill-time-window))
(define-read-only (get-decay-time-window) (var-get decay-time-window))

(define-read-only (get-lp-cap-factor) (var-get lp-cap-factor))
(define-read-only (get-last-lp-bucket-update) (var-get last-lp-bucket-update))
(define-read-only (get-lp-bucket) (var-get lp-bucket))

(define-read-only (get-debt-cap-factor) (var-get debt-cap-factor))
(define-read-only (get-last-debt-bucket-update) (var-get last-debt-bucket-update))
(define-read-only (get-debt-bucket) (var-get debt-bucket))

(define-read-only (get-collateral-cap-factor (collateral principal)) (default-to u0 (map-get? collateral-cap-factor collateral)))
(define-read-only (get-last-collateral-bucket-update (collateral principal)) (default-to u0 (map-get? last-collateral-bucket-update collateral)))
(define-read-only (get-collateral-bucket (collateral principal)) (default-to u0 (map-get? collateral-bucket collateral)))

(define-read-only (min (a uint) (b uint)) (if (> a b) b a ))

;; PRIVATE FUNCTIONS

(define-private (get-time-now)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

(define-private (refill-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (refill-window (get-refill-time-window))
      (elapsed (if (is-eq last-updated-at u0) refill-window (- time-now last-updated-at)))
      (refill-amount (if (>= elapsed refill-window) max-bucket (/ (* max-bucket elapsed) refill-window)))
      (new-bucket (min (+ current-bucket refill-amount) max-bucket))
  )
    (+ new-bucket inflow)
))

(define-private (decay-bucket-amount (last-updated-at uint) (time-now uint) (max-bucket uint) (current-bucket uint) (inflow uint))
  (let (
      (extra-bucket-amount (- current-bucket max-bucket))
      (decay-window (get-decay-time-window))
      (elapsed (if (is-eq last-updated-at u0) decay-window (- time-now last-updated-at)))
      (decayed-amount (if (>= elapsed decay-window) extra-bucket-amount (/ (* extra-bucket-amount elapsed) decay-window)))
      (new-bucket (- current-bucket decayed-amount))
  )
    (+ new-bucket inflow)
))

(define-private (sync-lp-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (var-get last-lp-bucket-update))
      (total-liquidity (unwrap! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-lp-bucket (/ (* total-liquidity (var-get lp-cap-factor)) SCALING-FACTOR))
      (current-bucket (var-get lp-bucket))
      (new-bucket-value (if (>= current-bucket max-lp-bucket) 
          (decay-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-lp-bucket current-bucket inflow)))
    )
    (print {
      old-lp-bucket-value: current-bucket,
      new-lp-bucket-value: new-bucket-value,
      max-lp-bucket: max-lp-bucket,
      inflow: inflow,
      sender: contract-caller,
      action: "sync-lp-bucket"
    })
    (var-set lp-bucket new-bucket-value)
    (var-set last-lp-bucket-update time-now)
    SUCCESS
  )
)

(define-private (sync-debt-bucket (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (last-ts (var-get last-debt-bucket-update))
      (total-liquidity (contract-call? .state-v1 get-borrowable-balance))
      (max-debt-bucket (/ (* total-liquidity (var-get debt-cap-factor)) SCALING-FACTOR))
      (current-bucket (var-get debt-bucket))
      (new-bucket-value (if (>= current-bucket max-debt-bucket) 
          (decay-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-debt-bucket current-bucket inflow)))
    )
    (print {
      old-debt-bucket-value: current-bucket,
      new-debt-bucket-value: new-bucket-value,
      inflow: inflow,
      sender: contract-caller,
      action: "sync-debt-bucket"
    })
    (var-set debt-bucket new-bucket-value)
    (var-set last-debt-bucket-update time-now)
    SUCCESS
  )
)

(define-private (sync-collateral-bucket (collateral <token-trait>) (inflow uint))
  (let
    (
      (time-now (get-time-now))
      (collateral-token (contract-of collateral))
      (last-ts (default-to u0 (map-get? last-collateral-bucket-update collateral-token)))
      (total-liquidity (unwrap! (contract-call? collateral get-balance .state-v1) ERR-FAILED-TO-GET-BALANCE))
      (max-collateral-bucket (/ (* total-liquidity (default-to u0 (map-get? collateral-cap-factor collateral-token))) SCALING-FACTOR))
      (current-bucket (default-to u0 (map-get? collateral-bucket collateral-token)))
      (new-bucket-value (if (>= current-bucket max-collateral-bucket) 
          (decay-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)
          (refill-bucket-amount last-ts time-now max-collateral-bucket current-bucket inflow)))
    )
    (print {
      old-collateral-bucket-value: current-bucket,
      new-collateral-bucket-value: new-bucket-value,
      inflow: inflow,
      sender: contract-caller,
      action: "sync-collateral-bucket"
    })
    (map-set collateral-bucket collateral-token new-bucket-value)
    (map-set last-collateral-bucket-update collateral-token time-now)
    SUCCESS
  )
)

(define-private (is-governance)
  (is-eq (contract-call? .state-v1 get-governance) contract-caller)
)

;; PUBLIC FUNCTIONS
(define-public (check-withdrawal-lp-cap (amount uint))
  (begin 
    (asserts! (is-eq contract-caller LP-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (var-get lp-cap-factor) u0)
      SUCCESS
      (begin
        (try! (sync-lp-bucket u0))
        (asserts! (<= amount (var-get lp-bucket)) ERR-WITHDRAWAL-LP-CAP-EXCEEDED)
        (var-set lp-bucket (- (var-get lp-bucket) amount))
        SUCCESS
      )
    )
  )
)

(define-public (lp-deposit (amount uint))
  (begin 
    (asserts! (is-eq contract-caller LP-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (var-get lp-cap-factor) u0)
      SUCCESS
      (sync-lp-bucket amount)
    )
  )
)

(define-public (check-withdrawal-debt-cap (amount uint))
  (begin 
    (asserts! (is-eq contract-caller BORROWER-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (var-get debt-cap-factor) u0)
      SUCCESS
      (begin
        (unwrap-panic (sync-debt-bucket u0))
        (asserts! (<= amount (var-get debt-bucket)) ERR-WITHDRAWAL-DEBT-CAP-EXCEEDED)
        (var-set debt-bucket (- (var-get debt-bucket) amount))
        SUCCESS
      )
    )
  )
)

(define-public (repay (amount uint))
  (begin 
    (asserts! (or (is-eq contract-caller BORROWER-CONTRACT) (is-eq contract-caller LIQUIDATOR-CONTRACT)) ERR-RESTRICTED)
    (if (is-eq (var-get debt-cap-factor) u0)
      SUCCESS
      (sync-debt-bucket amount)
    )
  )
)

(define-public (check-withdrawal-collateral-cap (collateral <token-trait>) (amount uint))
  (let ((collateral-token (contract-of collateral)))
    (asserts! (is-eq contract-caller BORROWER-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (default-to u0 (map-get? collateral-cap-factor collateral-token)) u0) 
      SUCCESS
      (begin 
        (try! (sync-collateral-bucket collateral u0))
        (asserts! (<= amount (default-to u0 (map-get? collateral-bucket collateral-token))) ERR-WITHDRAWAL-COLLATERAL-CAP-EXCEEDED)
        (map-set collateral-bucket collateral-token (- (default-to u0 (map-get? collateral-bucket collateral-token)) amount))
        SUCCESS
      )
    )
  )
)

(define-public (collateral-deposit (collateral <token-trait>) (amount uint))
  (let ((collateral-token (contract-of collateral)))
    (asserts! (is-eq contract-caller BORROWER-CONTRACT) ERR-RESTRICTED)
    (if (is-eq (default-to u0 (map-get? collateral-cap-factor collateral-token)) u0) 
      SUCCESS
      (sync-collateral-bucket collateral amount)
    )
  )
)

(define-public (set-lp-cap (new-cap uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-cap SCALING-FACTOR) ERR-INVALID-CAP-FACTOR)
    (print {
      action: "set-lp-cap",
      old-value: (var-get lp-cap-factor),
      new-value: new-cap
    })
    (var-set lp-cap-factor new-cap)
    SUCCESS
  )
)

(define-public (set-debt-cap (new-cap uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-cap SCALING-FACTOR) ERR-INVALID-CAP-FACTOR)
    (print {
      action: "set-debt-cap",
      old-value: (var-get lp-cap-factor),
      new-value: new-cap
    })
    (var-set debt-cap-factor new-cap)
    SUCCESS
  )
)

(define-public (set-collateral-cap (collateral principal) (new-cap uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-cap SCALING-FACTOR) ERR-INVALID-CAP-FACTOR)
    (print {
      action: "set-collateral-cap",
      collateral: collateral,
      old-value: (default-to u0 (map-get? collateral-cap-factor collateral)),
      new-value: new-cap
    })
    (map-set collateral-cap-factor collateral new-cap)
    SUCCESS
  )
)

(define-public (set-refill-time-window (new-window uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (print {
      action: "set-refill-time-window",
      old-value: (var-get refill-time-window),
      new-value: new-window
    })
    (var-set refill-time-window new-window)
    SUCCESS
  )
)

(define-public (set-decay-time-window (new-window uint))
  (begin
    (asserts! (is-governance) ERR-NOT-AUTHORIZED)
    (print {
      action: "set-decay-time-window",
      old-value: (var-get decay-time-window),
      new-value: new-window
    })
    (var-set decay-time-window new-window)
    SUCCESS
  )
)
