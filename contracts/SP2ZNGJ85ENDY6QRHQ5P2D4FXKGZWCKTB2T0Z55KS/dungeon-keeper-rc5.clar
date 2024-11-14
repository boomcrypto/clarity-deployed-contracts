;; Dungeon Keeper Contract
;;
;; The Dungeon Keeper is the central security and orchestration hub of the Charisma protocol,
;; managing all token operations through a system of verified interactions, multi-owner
;; authorization, and dynamic modifications via status effects. It ensures that all token
;; operations follow protocol rules while enabling complex GameFi mechanics.
;;
;; Core Functions:
;; 
;; 1. Token Operations
;;    Experience Token (.experience):
;;    - reward: Mint up to 1000 XP tokens
;;    - punish: Burn up to 100 XP tokens
;;
;;    Energy Token (.energy):
;;    - energize: Mint up to 10000 energy
;;    - exhaust: Burn up to 10000 energy
;;
;;    Governance Token (.dme000-governance-token):
;;    - transfer: Move up to 100 DMG
;;    - burn: Destroy up to 100 DMG
;;    - lock/unlock: Lock/unlock up to 100 DMG
;;
;; Operation Flow:
;; 1. Verified interaction calls token operation
;; 2. Status effects modify operation parameters
;; 3. Operation limits are enforced
;; 4. Token contract executes final operation
;;
;; Security Architecture:
;; 1. Multi-Owner System
;;    - Distributed control through contract-owners map
;;    - Owner consensus for critical changes
;;    - Protection against single point of failure
;;
;; 2. Interaction Verification
;;    - Whitelist of approved interaction contracts
;;    - Only verified contracts can execute operations
;;    - Owner-controlled interaction management
;;
;; 3. Operation Limits
;;    - Hard caps on all token operations
;;    - Configurable maximums per operation type
;;    - Owner-adjustable limit settings
;;
;; 4. Status Effect System
;;    - Dynamic operation modifications
;;    - Protocol-wide effect application
;;    - Extensible modification system
;;
;; Default Verified Interactions:
;; - Meme Engines: .meme-engine-cha, .meme-engine-iou-welsh, .meme-engine-iou-roo
;; - Core Systems: .fatigue, .charisma-mine
;; - Gameplay: .the-troll-toll, .charismatic-corgi, .keepers-petition
;;
;; Integration Points:
;; - Status Effects (.status-effects): Operation modifications
;; - Experience Token (.experience): XP management
;; - Energy Token (.energy): Energy management
;; - Governance Token (.dme000-governance-token): DMG operations
;;
;; This contract ensures that while gameplay mechanics can be dynamic and complex,
;; the underlying token operations remain secure and controlled. It acts as the
;; primary interface between the protocol's DeFi foundation and its GameFi features.

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
(map-set verified-interactions .meme-engine-iou-welsh-rc3 true)
(map-set verified-interactions .meme-engine-iou-roo-rc2 true)
(map-set verified-interactions .meme-engine-cha-iou-welsh-rc1 true)
(map-set verified-interactions .meme-engine-welsh-iou-welsh-rc1 true)
(map-set verified-interactions .fatigue-rc5 true)
(map-set verified-interactions .charisma-mine-rc4 true)
(map-set verified-interactions .the-troll-toll-rc2 true)
(map-set verified-interactions .charismatic-corgi-rc4 true)
(map-set verified-interactions .keepers-petition-rc4 true)
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
  (let ((modified (modify-reward {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-reward)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience mint (get amount modified) (get target modified))))

(define-public (punish (amount uint) (target principal))
  (let ((modified (modify-punish {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-punish)) ERR_EXCEEDS_LIMIT)
    (contract-call? .experience burn (get amount modified) (get target modified))))

(define-public (energize (amount uint) (target principal))
  (let ((modified (modify-energize {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-energize)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy mint (get amount modified) (get target modified))))

(define-public (exhaust (amount uint) (target principal))
  (let ((modified (modify-exhaust {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-exhaust)) ERR_EXCEEDS_LIMIT)
    (contract-call? .energy burn (get amount modified) (get target modified))))

(define-public (transfer (amount uint) (sender principal) (target principal))
  (let ((modified (modify-transfer {amount: amount, sender: sender, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-transfer)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-transfer (get amount modified) (get sender modified) (get target modified))))

(define-public (burn (amount uint) (target principal))
  (let ((modified (modify-burn {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-burn)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-burn (get amount modified) (get target modified))))

(define-public (lock (amount uint) (target principal))
  (let ((modified (modify-lock {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-lock)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-lock (get amount modified) (get target modified))))

(define-public (unlock (amount uint) (target principal))
  (let ((modified (modify-unlock {amount: amount, target: target, caller: contract-caller})))
    (asserts! (is-verified-interaction contract-caller) ERR_UNVERIFIED)
    (asserts! (<= (get amount modified) (var-get max-unlock)) ERR_EXCEEDS_LIMIT)
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-unlock (get amount modified) (get target modified))))

;; Private functions

(define-private (modify-reward (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-reward ctx))

(define-private (modify-punish (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-punish ctx))

(define-private (modify-energize (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-energize ctx))

(define-private (modify-exhaust (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-exhaust ctx))

(define-private (modify-transfer (ctx {amount: uint, sender: principal, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-transfer ctx))

(define-private (modify-burn (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-burn ctx))

(define-private (modify-lock (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-lock ctx))

(define-private (modify-unlock (ctx {amount: uint, target: principal, caller: principal})) 
  (contract-call? .status-effects-rc2 modify-unlock ctx))

;; Read-only functions

(define-read-only (is-verified-interaction (interaction principal))
  (default-to false (map-get? verified-interactions interaction)))

(define-read-only (is-owner (address principal))
  (default-to false (map-get? contract-owners address)))