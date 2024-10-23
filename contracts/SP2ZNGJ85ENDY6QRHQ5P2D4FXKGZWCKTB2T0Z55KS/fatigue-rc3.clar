;; Fatigue Interaction Contract
;;
;; This contract implements an interaction that burns a variable amount of energy from the user.
;; It has a single action: "BURN".
;;
;; Key Features:
;; 1. Single Action: Implements one action to burn energy.
;; 2. Variable Burn Amount: The amount of energy burned can be set by the contract owner.
;; 3. Default Burn Amount: Defaults to 10 energy (10,000,000 micro-energy).
;; 4. Dungeon Keeper Integration: Uses the Dungeon Keeper's exhaust function for energy burning.
;;
;; Integration with Charisma Ecosystem:
;; - Implements the interaction-trait for compatibility with the exploration system.
;; - Interacts with the Dungeon Keeper contract for energy management.
;;
;; Usage:
;; When executed, this contract will burn the set amount of energy from the user who interacts with it.

;; Implement the interaction-trait
(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant CONTRACT_OWNER tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/api/v0/interactions/fatigue"))
(define-data-var energy-burn-amount uint u10000000) ;; Default to 10 energy (10,000,000)

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

(define-read-only (get-energy-burn-amount)
  (ok (var-get energy-burn-amount)))

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "BURN") (burn-energy-action sender)
        (err "INVALID_ACTION"))))

;; Fatigue Action Handler

(define-private (burn-energy-action (sender principal))
  (let ((amount (var-get energy-burn-amount)))
    (match (contract-call? .dungeon-keeper-rc2 exhaust amount sender)
      success (handle-fatigue-success sender amount)
      error   (if (is-eq error u1) (handle-insufficient-energy sender amount)
              (if (is-eq error u405) (handle-fatigue-limit-exceeded sender amount)
              (if (is-eq error u403) (handle-fatigue-unverified sender amount)
              (handle-fatigue-unknown-error sender amount)))))))

;; Fatigue Contract Response Handlers

(define-private (handle-fatigue-success (sender principal) (amount uint))
  (begin
    (print "A wave of exhaustion washes over the adventurer.")
    (ok "ENERGY_BURNED")))

(define-private (handle-insufficient-energy (sender principal) (amount uint))
  (begin
    (print "The weary adventurer doesn't have enough energy left.")
    (ok "ENERGY_NOT_BURNED")))

(define-private (handle-fatigue-limit-exceeded (sender principal) (amount uint))
  (begin
    (print "The dungeon's appetite for energy has been exceeded for now.")
    (ok "ENERGY_NOT_BURNED")))

(define-private (handle-fatigue-unverified (sender principal) (amount uint))
  (begin
    (print "The dungeon does not recognize this interaction.")
    (ok "ENERGY_NOT_BURNED")))

(define-private (handle-fatigue-unknown-error (sender principal) (amount uint))
  (begin
    (print "The dungeon's energy drain mechanism malfunctions in an unexpected way.")
    (ok "ENERGY_NOT_BURNED")))

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))

(define-public (set-energy-burn-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set energy-burn-amount new-amount))))