;; Status Effects Contract
;;
;; This contract serves as the central modification layer for token operations in the
;; Charisma protocol. It intercepts token operations and applies various modifications
;; based on protocol conditions, NFT ownership, achievements, and other states.
;;
;; Architecture:
;; The contract follows a middleware pattern, where all token operations from the
;; Dungeon Keeper pass through this contract before execution. Each operation type
;; (reward, punish, energize, etc.) has its own modification function that applies
;; relevant effects.
;;
;; Key Components:
;; 1. Experience Modifications:
;;    - modify-reward: Adjusts experience rewards
;;    - modify-punish: Adjusts experience penalties
;;
;; 2. Energy Modifications:
;;    - modify-energize: Applies energy generation bonuses and capacity limits
;;    - modify-exhaust: Adjusts energy consumption
;;
;; 3. DMG Token Modifications:
;;    - modify-transfer: Applies transfer modifications (e.g., Raven reductions)
;;    - modify-burn: Applies burn modifications
;;    - modify-lock/unlock: Handles token locking modifications
;;
;; Integration Points:
;; - Energetic Welsh (.energetic-welsh): NFT-based energy generation bonuses
;; - Raven Resilience (.raven-resilience): Burn reduction calculations
;; - Energy Capacity (.energy-capacity): Maximum energy limits
;;
;; Modification Order:
;; The order of modifications is crucial for correct calculation:
;; 1. Base amount retrieved from context
;; 2. NFT-based modifications applied (e.g., Energetic Welsh)
;; 3. Protocol-wide limits applied (e.g., Energy Capacity)
;; 4. Final amount returned with modified target if applicable
;;
;; All functions in this contract are read-only to ensure deterministic behavior
;; and prevent state changes during modification calculations. The actual token
;; operations are performed by the Dungeon Keeper after modifications are applied.
;;
;; Usage:
;; This contract should never be called directly by users. Instead, it's called
;; by the Dungeon Keeper contract before executing any token operations. This ensures
;; all token operations in the protocol consistently apply the same modifications.

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant CONTRACT_OWNER tx-sender)

;; Effect modification functions for experience
(define-read-only (modify-reward (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx)))
        {
            amount: base-amount,
            target: (get target ctx)
        }))

(define-read-only (modify-punish (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx)))
        {
            amount: base-amount,
            target: (get target ctx)
        }))

;; Effect modification functions for energy
(define-read-only (modify-energize (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx))
        (energized-amount (apply-energetic-welsh base-amount (get target ctx) (get caller ctx)))
        (capacity-amount (apply-max-capacity energized-amount)))
        {
            amount: capacity-amount,
            target: (get target ctx)
        }))

(define-read-only (modify-exhaust (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx))
        (reduced-amount (apply-raven-reduction base-amount (get target ctx))))
        {
            amount: reduced-amount,
            target: (get target ctx)
        }))

;; Effect modification functions for governance tokens
(define-read-only (modify-transfer (ctx {amount: uint, sender: principal, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx))
        (reduced-amount (apply-raven-reduction base-amount (get sender ctx))))
        {
            amount: reduced-amount,
            sender: (get sender ctx),
            target: (get target ctx)
        }))

(define-read-only (modify-burn (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx))
        (reduced-amount (apply-raven-reduction base-amount (get target ctx))))
        {
            amount: reduced-amount,
            target: (get target ctx)
        }))

(define-read-only (modify-lock (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx)))
        {
            amount: base-amount,
            target: (get target ctx)
        }))

(define-read-only (modify-unlock (ctx {amount: uint, target: principal, caller: principal}))
    (let ((base-amount (get amount ctx)))
        {
            amount: base-amount,
            target: (get target ctx)
        }))

;; Helper functions for status effects

(define-private (apply-energetic-welsh (amount uint) (user principal) (caller principal))
  (contract-call? .energetic-welsh apply amount user caller))

(define-private (apply-raven-reduction (amount uint) (user principal))
  (contract-call? .raven-resilience apply amount user))

(define-private (apply-max-capacity (energy uint))
  (contract-call? .energy-capacity apply-max-capacity energy))