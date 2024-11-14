;; Charisma Interaction Client
;;
;; Purpose:
;; This contract serves as a key component in the Charisma protocol, implementing the core
;; energy generation and interaction mechanisms described in the Charisma white paper.
;;
;; Key Features:
;; 1. Energy Generation: Calculates and mints energy based on users' token balance history.
;; 2. Dynamic Multipliers: Applies quality scores and incentive scores to adjust energy output.
;; 3. Burn Fee Reduction: Implements a fee reduction system based on Raven NFT ownership.
;; 4. Interaction Capabilities: Allows for bonus actions using generated energy.
;; 5. Unused Energy Management: Burns unused energy, with exceptions for Memobot NFT holders.
;; 6. Energy Generator Whitelist: Maintains a list of approved energy generator contracts.
;;
;; This contract embodies the Charisma protocol's innovative approach to token staking,
;; offering a secure, efficient, and fair method for users to participate in the ecosystem.
;; It eliminates the need for traditional staking pools, allowing users to retain control
;; of their tokens while earning protocol rewards through energy generation.
;;
;; The energy calculation mechanism uses integral calculus to compute staking output
;; retroactively, ensuring a time-weighted representation of users' token holdings.
;; This approach incentivizes long-term holding and provides a flexible foundation
;; for various applications in DeFi, GameFi, and beyond.

;; Traits
(use-trait sip10-trait .dao-traits-v4.sip010-ft-trait)
(define-trait interaction-trait
  (
    (get-interaction-uri () (response (optional (string-utf8 256)) uint))
    (take-action ((string-ascii 32)) (response bool uint))
  )
)
(define-trait generator-trait
  (
    (tap (<sip10-trait>) (response uint uint))
  )
)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_DMG (err u101))
(define-constant ERR_INVALID_GENERATOR (err u102))

(define-constant FEE-SCALE u1000000) ;; 1 DMG (with 6 decimal places)

;; Data Variables
(define-data-var dmg-burn-fee uint u1000000) ;; 1 DMG initially

;; Maps
(define-map enabled-generators principal bool)

;; Authorization checks
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; Public functions
(define-public (main-action (generator <generator-trait>) (sip10 <sip10-trait>) (interaction <interaction-trait>) (action (string-ascii 32)))
    (let
        (
            (generator-contract (contract-of generator))
            (initial-energy (unwrap! (contract-call? generator tap sip10) ERR_UNAUTHORIZED))
            (burn-fee (calculate-burn-fee tx-sender))
        )
        (asserts! (is-enabled-generator generator-contract) ERR_INVALID_GENERATOR)
        (try! (burn-dmg burn-fee))
        (try! (mint-energy initial-energy))
        (try! (bonus-action interaction action))
        (try! (burn-unused-energy initial-energy))
        (ok true)
    )
)

(define-public (bonus-action (interaction <interaction-trait>) (action (string-ascii 32)))
    (contract-call? interaction take-action action)
)

(define-public (set-burn-fee (new-fee uint))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (var-set dmg-burn-fee new-fee))
    )
)

(define-public (add-generator (generator principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-set enabled-generators generator true))
    )
)

(define-public (remove-generator (generator principal))
    (begin
        (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
        (ok (map-delete enabled-generators generator))
    )
)

;; Read-only functions
(define-read-only (get-burn-fee)
    (var-get dmg-burn-fee)
)

(define-read-only (is-enabled-generator (generator principal))
    (default-to false (map-get? enabled-generators generator))
)

;; Private functions
(define-private (calculate-burn-fee (user principal))
  (let
    (
      (base-fee (var-get dmg-burn-fee))
      (burn-reduction (contract-call? .raven-reduction get-burn-reduction user))
    )
    (- base-fee (/ (* base-fee burn-reduction) FEE-SCALE))
  )
)

(define-private (burn-dmg (amount uint))
  (if (> amount u0)
      (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-burn amount tx-sender)
      (ok true)
  )
)

(define-private (mint-energy (amount uint))
  (if (> amount u0)
      (contract-call? .energy mint amount tx-sender)
      (ok true)
  )
)

(define-private (burn-unused-energy (initial-energy uint))
    (let
        (
            (has-memobot (> (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse get-balance tx-sender)) u0))
            (initial-balance (- (unwrap-panic (contract-call? .energy get-balance tx-sender)) initial-energy))
            (final-balance (unwrap-panic (contract-call? .energy get-balance tx-sender)))
            (energy-used (- (+ initial-balance initial-energy) final-balance))
            (unused-energy (- initial-energy energy-used))
        )
        (if (and (not has-memobot) (> unused-energy u0))
            (contract-call? .energy burn unused-energy tx-sender)
            (ok true)
        )
    )
)