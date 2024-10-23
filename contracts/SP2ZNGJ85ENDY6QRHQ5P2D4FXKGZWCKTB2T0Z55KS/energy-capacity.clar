;; Energy Capacity Contract
;;
;; This contract manages the energy storage capacity for users within the Charisma protocol.
;; It dynamically calculates and enforces maximum energy limits based on a user's Memobot ownership.
;;
;; Key Features:
;; 1. Dynamic Capacity Calculation: Computes max energy capacity based on base storage and Memobot count.
;; 2. Capacity Enforcement: Provides a function to cap energy amounts to the user's maximum capacity.
;; 3. Memobot Integration: Increases energy capacity for users who own Memobots.
;; 4. Configurable Parameters: Allows authorized entities to adjust base storage and per-Memobot energy bonus.
;;
;; Core Components:
;; - Base Energy Storage: A foundational amount of energy storage available to all users.
;; - Energy per Memobot: Additional energy storage granted for each Memobot owned.
;; - Max Capacity Calculation: Combines base storage with Memobot bonuses to determine total capacity.
;; - Capacity Application: Ensures energy amounts don't exceed a user's calculated capacity.
;;
;; Integration with Charisma Ecosystem:
;; - Interacts with Memobot contract to retrieve user's Memobot balance.
;; - Utilized by other contracts (e.g., Dungeon Keeper) to enforce energy limits.
;; - Authorizes actions through the Dungeon Master contract.
;;
;; Key Functions:
;; - get-max-capacity: Calculates a user's maximum energy capacity.
;; - apply-max-capacity: Caps an energy amount to the user's maximum capacity.
;; - set-energy-per-memobot: Admin function to adjust the energy bonus per Memobot.
;; - set-base-energy-storage: Admin function to adjust the base energy storage amount.
;;
;; Security Features:
;; - Authorization checks for admin functions.
;; - Integration with Dungeon Master for extension verification.
;;
;; This contract plays a crucial role in the Charisma protocol by managing energy limits,
;; incentivizing Memobot ownership, and ensuring fair and balanced energy distribution
;; across the ecosystem. It provides a flexible and upgradable system for energy capacity
;; management, allowing for future adjustments to the protocol's economic model.

(use-trait sip10-trait .dao-traits-v6.sip010-ft-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))

;; Data Variables
(define-data-var base-energy-storage uint u100000000) ;; Default: 100 energy
(define-data-var energy-per-memobot uint u10000000) ;; Default: +10 energy / Memobot

;; Authorization check
(define-private (is-authorized)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; Read-only functions

(define-read-only (get-max-capacity (user principal))
    (let
        ((memobot-count (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance user))))
        (+ (var-get base-energy-storage) (* memobot-count (var-get energy-per-memobot)))
    )
)

(define-read-only (apply-max-capacity (energy-amount uint))
    (let
        ((max-capacity (get-max-capacity tx-sender)))
        (min energy-amount max-capacity)
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