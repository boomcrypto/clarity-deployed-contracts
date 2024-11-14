---
title: "Trait dungeon-keeper-rc2"
draft: true
---
```
;; Dungeon Keeper Contract
;;
;; This contract serves as the central management and security hub for the Charisma protocol.
;; It controls critical parameters, authorizes interactions, and manages token operations
;; across the ecosystem. The Dungeon Keeper acts as a gatekeeper, ensuring the integrity
;; and security of the Charisma protocol's core functions.
;;
;; Key Responsibilities:
;; 1. Authorization Management: Controls contract ownership and access rights.
;; 2. Interaction Verification: Manages the list of verified interactions.
;; 3. Token Operations: Handles minting, burning, and transfers of protocol tokens.
;; 4. Security Controls: Implements limits and verification checks for various protocol actions.
;; 5. Energy Capacity Management: Applies maximum capacity to energy generation.
;;
;; Core Components:
;; - Contract Ownership: Multi-owner structure for enhanced security and governance.
;; - Verified Interactions: Whitelist of approved interaction contracts.
;; - Token Integration: Manages operations for Experience, Energy, and DMG tokens.
;; - Operation Limits: Configurable maximum limits for token operations.
;; - Raven Resistance Integration: Applies burn reductions in token transfers.
;;
;; Key Functions:
;; - Admin Functions: Add/remove contract owners, manage verified interactions, set operation limits.
;; - Token Operations: 
;;   - reward: Mint Experience tokens (max 1000 Experience).
;;   - punish: Burn Experience tokens (max 100 Experience).
;;   - energize: Mint Energy tokens with capacity limit (max 1000 Energy).
;;   - exhaust: Burn Energy tokens (max 100 Energy).
;;   - transfer: Transfer DMG tokens with Raven Resistance reduction (max 100 DMG).
;;
;; Security Features:
;; - Multi-owner structure to prevent single points of failure.
;; - Strict access controls on all admin functions.
;; - Verification checks for interaction contracts.
;; - Maximum limits on token operations to prevent abuse.
;; - Energy capacity limit applied through integration with energy-capacity contract.
;;
;; Integration with Charisma Ecosystem:
;; - Verifies and manages interaction contracts within the protocol.
;; - Interacts with token contracts (Experience, Energy, DMG) for core operations.
;; - Utilizes Raven Resistance for burn reductions in DMG transfers.
;; - Applies energy capacity limits using the energy-capacity contract.
;;
;; This contract is crucial for maintaining the security, flexibility, and proper functioning
;; of the Charisma protocol. By centralizing critical operations and access controls, it ensures
;; that only verified interactions can perform sensitive operations, maintaining the integrity
;; of the entire ecosystem. The Dungeon Keeper's role is essential in supporting the protocol's
;; innovative approach to stake-less participation and dynamic reward mechanisms within a
;; secure and controlled environment.

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_UNVERIFIED (err u403))
(define-constant ERR_EXCEEDS_LIMIT (err u405))

;; Maximum limits for token operations
(define-data-var max-reward uint u1000000000)  ;; 1000 Experience
(define-data-var max-punish uint u100000000)  ;; 100 Experience
(define-data-var max-energize uint u1000000000)  ;; 1000 Energy
(define-data-var max-exhaust uint u100000000)  ;; 100 Energy
(define-data-var max-transfer uint u100000000)  ;; 100 DMG

;; Maps
(define-map contract-owners principal bool)
(define-map verified-interactions principal bool)

;; Constants
(define-constant FEE-SCALE u1000000)

;; Authorization checks
(define-read-only (is-contract-owner)
  (default-to false (map-get? contract-owners contract-caller))
)

;; Initialize the contract with the deployer as the first owner
(map-set contract-owners tx-sender true)

;; Initialize the verified interactions map
(map-set verified-interactions .meme-engine-cha-rc3 true)
(map-set verified-interactions .meme-engine-iouwelsh-rc1 true)
(map-set verified-interactions .meme-engine-iouroo-rc1 true)
(map-set verified-interactions .charisma-mine-rc1 true)
(map-set verified-interactions .kraken-arbitrage-rc1 true)
(map-set verified-interactions .keepers-challenge-rc3 true)

;; Admin functions

(define-public (add-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set contract-owners new-owner true))
  )
)

(define-public (remove-contract-owner (owner principal))
  (begin
    (asserts! (and (is-contract-owner) (not (is-eq tx-sender owner))) ERR_UNAUTHORIZED)
    (ok (map-delete contract-owners owner))
  )
)

(define-public (add-verified-interaction (interaction principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set verified-interactions interaction true))
  )
)

(define-public (remove-verified-interaction (interaction principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-delete verified-interactions interaction))
  )
)

(define-public (set-max-reward (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-reward new-max))
  )
)

(define-public (set-max-punish (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-punish new-max))
  )
)

(define-public (set-max-energize (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-energize new-max))
  )
)

(define-public (set-max-exhaust (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-exhaust new-max))
  )
)

(define-public (set-max-transfer (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-transfer new-max))
  )
)

;; Public functions for token operations

(define-public (reward (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-reward)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience mint amount target)
  )
)

(define-public (punish (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-punish)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience burn amount target)
  )
)

(define-public (energize (amount uint) (target principal))
  (let
    ((capped-amount (apply-max-capacity amount)))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= capped-amount (var-get max-energize)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy mint capped-amount target)
  )
)

(define-public (exhaust (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-exhaust)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy burn amount target)
  )
)

(define-public (transfer (amount uint) (sender principal) (target principal))
  (let
    ((reduced-amount (apply-raven-reduction amount sender)))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= reduced-amount (var-get max-transfer)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token transfer reduced-amount sender target none)
  )
)

;; Private functions

(define-private (apply-raven-reduction (amount uint) (user principal))
  (let
    ((reduction (contract-call? .raven-resistance get-burn-reduction user)))
    (- amount (/ (* amount reduction) FEE-SCALE))
  )
)

(define-private (apply-max-capacity (energy uint))
  (contract-call? .energy-capacity apply-max-capacity energy)
)

;; Read-only functions

(define-read-only (is-verified-interaction (interaction principal))
  (default-to false (map-get? verified-interactions interaction))
)

(define-read-only (is-owner (address principal))
  (default-to false (map-get? contract-owners address))
)
```
