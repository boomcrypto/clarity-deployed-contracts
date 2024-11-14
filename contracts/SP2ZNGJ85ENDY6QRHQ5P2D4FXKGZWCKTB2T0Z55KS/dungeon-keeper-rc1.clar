;; Dungeon Keeper Contract
;;
;; This contract serves as the central management and security hub for the Charisma protocol.
;; It controls critical parameters, authorizes interactions, and manages token operations
;; across the ecosystem. The Dungeon Keeper acts as a gatekeeper, ensuring the integrity
;; and security of the Charisma protocol's core functions.
;;
;; Key Responsibilities:
;; 1. Authorization Management: Controls contract ownership and access rights.
;; 2. Protocol Parameter Management: Sets and updates key protocol parameters.
;; 3. Interaction Verification: Manages the list of verified interactions and enabled engines.
;; 4. Token Operations: Handles minting, burning, and transfers of protocol tokens.
;; 5. Security Controls: Implements freezing mechanisms for various protocol actions.
;;
;; Core Components:
;; - Contract Ownership: Multi-owner structure for enhanced security and governance.
;; - Verified Interactions: Whitelist of approved interaction contracts.
;; - Enabled Engines: List of authorized meme engines.
;; - Protocol Parameters: Configurable settings for burn percentages and rewards.
;; - Frozen States: Ability to pause listings, interactions, and unlistings.
;;
;; Token Integration:
;; - Experience: Minting rewards for protocol participation.
;; - Energy: Burning mechanism for protocol actions.
;; - DMG: Transfer functionality between principals.
;;
;; Security Features:
;; - Multi-owner structure to prevent single points of failure.
;; - Strict access controls on all admin functions.
;; - Flexible freezing mechanisms to respond to potential issues.
;;
;; Integration with Charisma Ecosystem:
;; - Works in conjunction with meme engines to manage energy generation.
;; - Interacts with token contracts (Experience, Energy, DMG) for reward and burn mechanics.
;; - Utilizes Raven Resistance for burn reductions in token transfers.
;;
;; This contract is crucial for maintaining the security, flexibility, and proper functioning
;; of the Charisma protocol. It provides the necessary controls and integrations to support
;; the protocol's innovative approach to stake-less energy generation and ecosystem governance.

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u501))
(define-constant ERR_EXCEED_MAX_LIMIT (err u502))

;; Configuration
(define-data-var minimum-burn-percentage uint u100)
(define-data-var minimum-experience-reward uint u1000000)
(define-data-var listings-frozen bool false)
(define-data-var interactions-frozen bool false)
(define-data-var unlistings-frozen bool false)

;; Maximum limits for token operations
(define-data-var max-exp-mint uint u1000000000)  ;; 1000 Experience
(define-data-var max-exp-burn uint u1000000000)  ;; 1000 Experience
(define-data-var max-energy-mint uint u1000000000)  ;; 1000 Energy
(define-data-var max-energy-burn uint u1000000000)  ;; 1000 Energy
(define-data-var max-dmg-transfer uint u1000000000)  ;; 1000 DMG

;; Maps
(define-map verified-interactions principal bool)
(define-map enabled-engines principal bool)
(define-map contract-owners principal bool)

;; Constants
(define-constant FEE-SCALE u1000000)

;; Authorization checks
(define-private (is-contract-owner)
  (default-to false (map-get? contract-owners contract-caller))
)

;; Initialize the contract with the deployer as the first owner
(map-set contract-owners tx-sender true)

;; Initialize the verified interactions map
(map-set verified-interactions .keepers-challenge-rc1 true)

;; Initialize the enabled engines map
(map-set enabled-engines .meme-engine-cha-rc1 true)

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

(define-public (set-minimum-burn-percentage (percentage uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set minimum-burn-percentage percentage))
  )
)

(define-public (set-minimum-experience-reward (amount uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set minimum-experience-reward amount))
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

(define-public (add-engine (engine principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set enabled-engines engine true))
  )
)

(define-public (remove-engine (engine principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-delete enabled-engines engine))
  )
)

(define-public (set-frozen-state (listings bool) (interactions bool) (unlistings bool))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (var-set listings-frozen listings)
    (var-set interactions-frozen interactions)
    (var-set unlistings-frozen unlistings)
    (ok true)
  )
)

(define-public (set-max-exp-mint (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-exp-mint new-max))
  )
)

(define-public (set-max-exp-burn (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-exp-burn new-max))
  )
)

(define-public (set-max-energy-mint (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-energy-mint new-max))
  )
)

(define-public (set-max-energy-burn (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-energy-burn new-max))
  )
)

(define-public (set-max-dmg-transfer (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-dmg-transfer new-max))
  )
)

;; Public functions for token operations

(define-public (mint-exp (recipient principal) (amount uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= amount (var-get max-exp-mint)) ERR_EXCEED_MAX_LIMIT)
    (contract-call? .experience mint amount recipient)
  )
)

(define-public (burn-exp (burner principal) (amount uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= amount (var-get max-exp-burn)) ERR_EXCEED_MAX_LIMIT)
    (contract-call? .experience burn amount burner)
  )
)

(define-public (mint-energy (recipient principal) (amount uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= amount (var-get max-energy-mint)) ERR_EXCEED_MAX_LIMIT)
    (contract-call? .energy mint amount recipient)
  )
)

(define-public (burn-energy (burner principal) (amount uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= amount (var-get max-energy-burn)) ERR_EXCEED_MAX_LIMIT)
    (contract-call? .energy burn amount burner)
  )
)

(define-public (transfer-dmg (sender principal) (recipient principal) (amount uint))
  (let
    ((reduced-amount (apply-raven-reduction amount sender)))
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= reduced-amount (var-get max-dmg-transfer)) ERR_EXCEED_MAX_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token transfer reduced-amount sender recipient none)
  )
)

;; Private functions

(define-private (apply-raven-reduction (amount uint) (user principal))
  (let
    ((reduction (contract-call? .raven-resistance get-burn-reduction user)))
    (- amount (/ (* amount reduction) FEE-SCALE))
  )
)

;; Read-only functions

(define-read-only (get-verified-interaction (interaction principal))
  (map-get? verified-interactions interaction)
)

(define-read-only (is-verified-interaction (interaction principal))
  (default-to false (map-get? verified-interactions interaction))
)

(define-read-only (is-enabled-engine (engine principal))
  (default-to false (map-get? enabled-engines engine))
)

(define-read-only (get-minimum-burn-percentage)
  (var-get minimum-burn-percentage)
)

(define-read-only (get-minimum-experience-reward)
  (var-get minimum-experience-reward)
)

(define-read-only (get-frozen-state)
  {
    listings-frozen: (var-get listings-frozen),
    interactions-frozen: (var-get interactions-frozen),
    unlistings-frozen: (var-get unlistings-frozen)
  }
)

(define-read-only (is-owner (address principal))
  (default-to false (map-get? contract-owners address))
)