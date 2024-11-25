---
title: "Trait power-cells"
draft: true
---
```
;; Memobot Capacity Contract
;;
;; This contract manages the energy storage capacity for users within the Charisma protocol.
;; It dynamically calculates and enforces maximum energy limits based on a user's Memobot ownership.
;;
;; Key Features:
;; 1. Dynamic Capacity Calculation: Computes max energy capacity based on base storage and Memobot count
;; 2. Capacity Enforcement: Provides a function to cap energy amounts to user's maximum capacity 
;; 3. Memobot Integration: Increases energy capacity for users who own Memobots
;; 4. Configurable Parameters: Allows contract owner to adjust base storage and per-Memobot energy bonus
;;
;; Core Components:
;; - Base Energy Storage: A foundational amount of energy storage available to all users (100 energy)
;; - Energy per Memobot: Additional energy storage granted for each Memobot (+10 energy per Memobot)
;; - Max Capacity Calculation: Combines base storage with Memobot bonuses for total capacity
;; - Capacity Application: Ensures energy amounts don't exceed capacity while maintaining minimum gains
;;
;; Integration with Charisma Ecosystem:
;; - Interacts with Memobot contract to retrieve user's Memobot balance
;; - Enforces energy limits while providing informative feedback messages
;; - Ensures minimum energy gain of 1 unit even at capacity
;;
;; Key Functions:
;; - get-max-capacity: Calculates a user's maximum energy capacity
;; - apply: Caps energy gain to capacity while providing feedback messages
;; - set-energy-per-memobot: Owner function to adjust energy bonus per Memobot
;; - set-base-energy-storage: Owner function to adjust base energy storage
;;
;; Security Features:
;; - Contract owner authorization for admin functions
;; - Safe arithmetic operations with overflow checking
;; - Graceful handling of capacity limits
;;
;; User Feedback:
;; - Provides contextual messages about capacity status
;; - Informs users about Memobot benefits
;; - Encourages Memobot acquisition for increased capacity
;;
;; This contract plays a crucial role in the Charisma protocol by managing energy limits,
;; incentivizing Memobot ownership, and ensuring fair energy distribution while providing
;; clear feedback to users about their capacity status and options for improvement.

(use-trait sip10-trait .dao-traits-v7.sip010-ft-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant CONTRACT-OWNER tx-sender)

;; Data Variables
(define-data-var base-energy-storage uint u100000000) ;; Default: 100 energy
(define-data-var energy-per-memobot uint u10000000) ;; Default: +10 energy / Memobot

;; Authorization check
(define-private (is-authorized)
    (is-eq tx-sender CONTRACT-OWNER)
)

;; Read-only functions

(define-read-only (get-max-capacity (user principal))
    (let
        ((memobot-count (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance user))))
        (+ (var-get base-energy-storage) (* memobot-count (var-get energy-per-memobot)))
    )
)

(define-read-only (apply (energy-amount uint) (user principal))
    (let
        ((max-capacity (get-max-capacity user))
         (current-balance (get-energy-balance user))
         (energy-gain (if (> max-capacity current-balance)
                         (min (- max-capacity current-balance) energy-amount)
                         u1))  ;; Always return at least 1
         (memobot-count (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance user))))

        ;; Print message only if user has Memobots
        (if (>= current-balance (var-get base-energy-storage)) 
            (if (> energy-gain u1) (print "Your Memobot NFTs have allowed for increased energy capacity.")
                (print "You've reached your maximum energy capacity. Get more Memobots to increase it."))
            (print "You've added some energy to your reserves: not yet at max capacity."))
        energy-gain
    )
)

(define-read-only (get-energy-per-memobot)
    (ok (var-get energy-per-memobot))
)

(define-read-only (get-base-energy-storage)
    (ok (var-get base-energy-storage))
)

;; Private functions
(define-private (get-energy-balance (user principal))
    (unwrap-panic (contract-call? .energy get-balance user))
)

(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

;; Admin functions

(define-public (set-energy-per-memobot (new-amount uint))
    (begin
        (asserts! (is-authorized) ERR_UNAUTHORIZED)
        (ok (var-set energy-per-memobot new-amount))
    )
)

(define-public (set-base-energy-storage (new-amount uint))
    (begin
        (asserts! (is-authorized) ERR_UNAUTHORIZED)
        (ok (var-set base-energy-storage new-amount))
    )
)
```
