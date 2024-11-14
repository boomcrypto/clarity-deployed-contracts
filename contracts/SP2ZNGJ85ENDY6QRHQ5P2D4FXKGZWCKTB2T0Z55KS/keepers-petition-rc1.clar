;; Keeper's Petition Interaction
;;
;; A configurable mechanism for distributing DMG tokens to players from a designated source.
;; The source address of the tokens and reward amount can be dynamically updated by
;; contract Dungeon Keepers, allowing for flexible distribution strategies.
;;
;; This contract can serve multiple purposes depending on how it's configured:
;; - Distribution from a central treasury
;; - Redistribution from large token holders
;; - Strategic token distribution from specific addresses
;; - Player reward and punishment systems
;;
;; Technical Features:
;; - Configurable token source address
;; - Adjustable reward amounts
;; - Multiple administrator support
;; - Energy-gated claiming mechanism
;;
;; Cost: Fatigue
;; Reward: Variable DMG amount

(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))

;; Data Variables
(define-data-var token-amount uint u10000000)
(define-data-var token-principal principal tx-sender)
(define-data-var contract-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/interactions/keepers-petition"))

;; Data Maps
(define-map contract-owners principal bool)

;; Initialize contract owner
(map-set contract-owners tx-sender true)

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

(define-read-only (get-token-principal)
  (ok (var-get token-principal)))

(define-read-only (get-token-amount)
  (ok (var-get token-amount)))

(define-read-only (is-contract-owner (address principal))
  (default-to false (map-get? contract-owners address)))

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "PETITION") (petition-action sender)
    (err "INVALID_ACTION"))))

;; Action Handler

(define-private (petition-action (sender principal))
  (let ((fatigue-response (unwrap-panic (contract-call? .fatigue-rc3 execute "BURN"))))
    (if (is-eq fatigue-response "ENERGY_BURNED") (handle-petition-attempt sender)
    (if (is-eq fatigue-response "ENERGY_NOT_BURNED") (handle-insufficient-energy sender)
    (handle-unknown-error sender)))))

;; Response Handlers

(define-private (handle-petition-attempt (sender principal))
  (begin
    (match (contract-call? .dungeon-keeper-rc2 transfer (var-get token-amount) (var-get token-principal) sender)
      success (begin 
              (print "The Dungeon Keeper acknowledges your humble petition and grants you a small reward.")
              (ok "PETITION_SUCCEEDED"))
      error   (handle-unknown-error sender))))

(define-private (handle-insufficient-energy (sender principal))
  (begin
    (print "You lack the energy required to petition the Dungeon Keeper.")
    (ok "PETITION_FAILED")))

(define-private (handle-unknown-error (sender principal))
  (begin
    (print "The Dungeon Keeper is unable to process your petition.")
    (ok "PETITION_ERROR")))

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))

(define-public (set-token-principal (new-principal principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-principal new-principal))))

(define-public (set-token-amount (new-reward uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-amount new-reward))))

(define-public (add-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (map-set contract-owners new-owner true))))

(define-public (remove-contract-owner (owner principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (map-delete contract-owners owner))))