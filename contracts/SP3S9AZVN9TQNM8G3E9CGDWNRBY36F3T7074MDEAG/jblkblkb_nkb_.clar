;; Define the contract's data variables

;; Maps a user's principal address to their deposited amount.
(define-map deposits { owner: principal } { amount: uint })

;; Maps a borrower's principal address to their loan details: amount and the last interaction block.
(define-map loans principal { amount: uint, last-interaction-block: uint })

;; Holds the total amount of deposits in the contract, initialized to 0.
(define-data-var total-deposits uint u0)

;; Represents the reserve funds in the pool, initialized to 0.
(define-data-var pool-reserve uint u0)

;; The interest rate for loans, represented as 10% (out of a base of 100).
(define-data-var loan-interest-rate uint u10) ;; Representing 10% interest rate

;; Error constants for various failure scenarios.
(define-constant err-no-interest (err u100))
(define-constant err-overpay (err u200))
(define-constant err-overborrow (err u300))
