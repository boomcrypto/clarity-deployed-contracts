;; Dungeon Keeper Contract
;;
;; This contract serves as the central authority and security hub for the Charisma protocol.
;; It controls critical parameters, authorizes interactions, and manages token operations
;; across both GameFi and DeFi aspects of the ecosystem. The Dungeon Keeper acts as a
;; gatekeeper, ensuring the integrity and security of all protocol operations.
;;
;; Key Responsibilities:
;; 1. Authorization Management: Controls contract ownership and verified interaction list
;; 2. Token Operations: Manages all protocol token operations with strict limits:
;;    - Experience: Mint (max 1000) and burn (max 100)
;;    - Energy: Mint and burn (max 10000 each)
;;    - Governance: Transfer, burn, lock, and unlock (max 100 each)
;; 3. Security Controls: Applies Raven Resistance burn reductions and energy capacity limits
;; 4. Multi-owner Architecture: Distributes control for enhanced security
;;
;; Core Functions:
;; Experience Operations:
;; - reward: Mint Experience tokens (max 1000)
;; - punish: Burn Experience tokens (max 100)
;;
;; Energy Operations:
;; - energize: Mint Energy tokens with capacity limit (max 10000)
;; - exhaust: Burn Energy tokens (max 10000)
;;
;; Governance Token Operations:
;; - transfer: Move DMG with Raven Resistance reduction (max 100)
;; - burn: Burn DMG with Raven Resistance reduction (max 100)
;; - lock: Lock DMG tokens (max 100)
;; - unlock: Unlock DMG tokens (max 100)
;;
;; Administrative Functions:
;; - Contract Owner Management: Add/remove owners
;; - Interaction Verification: Add/remove verified interactions
;; - Limit Configuration: Set maximum amounts for all operations
;;
;; Security Features:
;; - Multi-owner structure prevents single points of failure
;; - Verified interaction whitelist
;; - Maximum limits on all token operations
;; - Raven Resistance integration for burn reduction
;; - Energy capacity limit application
;;
;; Integration Points:
;; - Experience Token (.experience)
;; - Energy Token (.energy)
;; - Governance Token (.dme000-governance-token)
;; - Raven Resistance (.raven-resistance)
;; - Energy Capacity (.energy-capacity)
;;
;; This contract is essential for maintaining the balance between dynamic GameFi mechanics
;; and secure DeFi operations. By centralizing and limiting all token operations, it ensures
;; that gameplay features can safely interact with valuable token systems while maintaining
;; strict security controls and economic stability.

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_UNVERIFIED (err u403))
(define-constant ERR_EXCEEDS_LIMIT (err u405))

;; Maximum limits for token operations
(define-data-var max-reward uint u1000000000)  ;; 1000 Experience
(define-data-var max-punish uint u100000000)  ;; 100 Experience
(define-data-var max-energize uint u10000000000)  ;; 10000 Energy
(define-data-var max-exhaust uint u10000000000)  ;; 10000 Energy
(define-data-var max-transfer uint u100000000)  ;; 100 DMG
(define-data-var max-burn uint u100000000)  ;; 100 DMG
(define-data-var max-lock uint u100000000)  ;; 100 DMG
(define-data-var max-unlock uint u100000000)  ;; 100 DMG

;; Maps
(define-map contract-owners principal bool)
(define-map verified-interactions principal bool)

;; Authorization checks
(define-read-only (is-contract-owner)
  (default-to false (map-get? contract-owners contract-caller))
)

;; Initialize the contract with the deployer as the first owner
(map-set contract-owners tx-sender true)

;; Initialize verified interactions
(map-set verified-interactions .meme-engine-cha-rc5 true)
(map-set verified-interactions .meme-engine-iou-welsh-rc1 true)
(map-set verified-interactions .meme-engine-iou-roo-rc1 true)
(map-set verified-interactions .fatigue-rc4 true)
(map-set verified-interactions .charisma-mine-rc4 true)
(map-set verified-interactions .the-troll-toll-rc2 true)
(map-set verified-interactions .charismatic-corgi-rc4 true)
(map-set verified-interactions .keepers-petition-rc2 true)
(map-set verified-interactions .keepers-challenge-rc1 true)

;; Admin functions

(define-public (add-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set contract-owners new-owner true))))

(define-public (remove-contract-owner (owner principal))
  (begin
    (asserts! (and (is-contract-owner) (not (is-eq tx-sender owner))) ERR_UNAUTHORIZED)
    (ok (map-delete contract-owners owner))))

(define-public (add-verified-interaction (interaction principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-set verified-interactions interaction true))))

(define-public (remove-verified-interaction (interaction principal))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (map-delete verified-interactions interaction))))

(define-public (set-max-reward (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-reward new-max))))

(define-public (set-max-punish (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-punish new-max))))

(define-public (set-max-energize (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-energize new-max))))

(define-public (set-max-exhaust (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-exhaust new-max))))

(define-public (set-max-transfer (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-transfer new-max))))

(define-public (set-max-burn (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-burn new-max))))

(define-public (set-max-lock (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-lock new-max))))

(define-public (set-max-unlock (new-max uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set max-unlock new-max))))

;; Public functions for token operations

(define-public (reward (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-reward)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience mint amount target)))

(define-public (punish (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-punish)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience burn amount target)))

(define-public (energize (amount uint) (target principal))
  (let ((capped-amount (apply-max-capacity amount)))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= capped-amount (var-get max-energize)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy mint capped-amount target)))

(define-public (exhaust (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-exhaust)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy burn amount target)))

(define-public (transfer (amount uint) (sender principal) (target principal))
  (let ((reduced-amount (apply-raven-reduction amount sender)))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= reduced-amount (var-get max-transfer)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-transfer reduced-amount sender target)))

(define-public (burn (amount uint) (sender principal) (target principal))
  (let ((reduced-amount (apply-raven-reduction amount sender)))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= reduced-amount (var-get max-burn)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-burn reduced-amount target)))

(define-public (lock (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-lock)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-lock amount target)))

(define-public (unlock (amount uint) (target principal))
  (begin
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= amount (var-get max-unlock)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-unlock amount target)))

;; Private functions

(define-private (apply-raven-reduction (amount uint) (user principal))
  (let ((reduction (contract-call? .raven-resistance get-burn-reduction user)))
    (- amount (/ (* amount reduction) u1000000))))

(define-private (apply-max-capacity (energy uint))
  (contract-call? .energy-capacity apply-max-capacity energy))

;; Read-only functions

(define-read-only (is-verified-interaction (interaction principal))
  (default-to false (map-get? verified-interactions interaction)))

(define-read-only (is-owner (address principal))
  (default-to false (map-get? contract-owners address)))