;; STXCITY Donation Contract 
;; This contract allows users to donate STX to a specified address
;; Written by STXCITY 
;; Version 1.0

;; ERRORS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-ZERO-AMOUNT (err u5002))
(define-constant ERR-INSUFFICIENT-AMOUNT (err u5003))
(define-constant ERR-INVALID-AMOUNT (err u5004))
(define-constant ERR-DONATION-PAUSED (err u6001))

;; CONSTANTS
(define-constant DONATION_RECIPIENT 'SP2WB6YSVW2WGT20MZRYMK2EV35N3GXQXDBS972J7) ;; STXCITY wallet - recipient of donations
(define-constant MINIMUM_DONATION u50000000) ;; 50 STX minimum donation
(define-constant DONATION_GOAL u10000000000) ;; 10,000 STX donation goal

;; STATE VARIABLES
(define-data-var contract-owner principal tx-sender)
(define-data-var donation-paused bool false)
(define-data-var total-donations uint u0)
(define-data-var donor-count uint u0)
(define-data-var donation-goal uint DONATION_GOAL)

;; MAPS
(define-map donor-records
    { donor: principal }
    { amount: uint, last-donation-height: uint }
)

;; READ-ONLY FUNCTIONS

;; Get information about the donation contract
(define-read-only (get-donation-info)
  (let
    (
      (current-goal (var-get donation-goal))
      (current-total (var-get total-donations))
      (progress-percentage (if (> current-goal u0)
                            (/ (* current-total u100) current-goal)
                            u0))
      (goal-reached (>= current-total current-goal))
    )
    (ok {
      recipient: DONATION_RECIPIENT,
      minimum-donation: MINIMUM_DONATION,
      total-donations: current-total,
      donor-count: (var-get donor-count),
      is-paused: (var-get donation-paused),
      contract-owner: (var-get contract-owner),
      donation-goal: current-goal,
      progress-percentage: progress-percentage,
      goal-reached: goal-reached
    })
  )
)

;; Get information about a specific donor
(define-read-only (get-donor-info (donor principal))
  (default-to 
    { amount: u0, last-donation-height: u0 } 
    (map-get? donor-records { donor: donor })
  )
)

;; Get the total amount donated by a specific donor
(define-read-only (get-donor-amount (donor principal))
  (get amount (get-donor-info donor))
)

;; PUBLIC FUNCTIONS

;; Donate STX to the recipient address
(define-public (donate (amount uint))
  (let
    (
      (donor tx-sender)
      (donor-record (get-donor-info donor))
      (previous-amount (get amount donor-record))
      (is-first-time (is-eq previous-amount u0))
    )
    ;; Check that donations are not paused
    (asserts! (not (var-get donation-paused)) ERR-DONATION-PAUSED)
    ;; Check that amount is greater than zero
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    ;; Check that amount is at least the minimum donation
    (asserts! (>= amount MINIMUM_DONATION) ERR-INSUFFICIENT-AMOUNT)
    
    ;; Transfer STX from sender to recipient
    (try! (stx-transfer? amount donor DONATION_RECIPIENT))
    
    ;; Update donor record
    (map-set donor-records 
      { donor: donor }
      { 
        amount: (+ previous-amount amount),
        last-donation-height: burn-block-height
      }
    )
    
    ;; Update total donations
    (var-set total-donations (+ (var-get total-donations) amount))
    
    ;; Update donor count if this is a first-time donor
    (if is-first-time
      (var-set donor-count (+ (var-get donor-count) u1))
      true
    )
    
    ;; Return success with donation details
    (ok {
      donor: donor,
      amount: amount,
      total-donated: (+ previous-amount amount),
      donation-height: burn-block-height
    })
  )
)

;; Get the current progress percentage towards the donation goal
(define-read-only (get-progress-percentage)
  (let
    (
      (current-goal (var-get donation-goal))
      (current-total (var-get total-donations))
    )
    (if (> current-goal u0)
      (/ (* current-total u100) current-goal)
      u0)
  )
)

;; Check if the donation goal has been reached
(define-read-only (is-goal-reached)
  (>= (var-get total-donations) (var-get donation-goal))
)

;; ADMIN FUNCTIONS

;; Pause donations
(define-public (pause-donations)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set donation-paused true)
    (ok true)
  )
)

;; Resume donations
(define-public (resume-donations)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set donation-paused false)
    (ok true)
  )
)

;; Transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Update the donation goal
(define-public (update-donation-goal (new-goal uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> new-goal u0) ERR-INVALID-AMOUNT)
    (var-set donation-goal new-goal)
    (ok true)
  )
)