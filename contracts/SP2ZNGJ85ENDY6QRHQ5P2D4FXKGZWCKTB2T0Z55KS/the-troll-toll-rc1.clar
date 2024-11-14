;; The Troll Toll Interaction Contract
;;
;; This contract implements a critical utility interaction for the Charisma protocol's
;; exploration system. It serves two key purposes:
;; 1. Ensures consistent post-condition setup for token transfers, which is necessary
;;    whenever exploring has a chance of sending or receiving tokens.
;; 2. Prevents consecutive exploration attempts through an ever-increasing toll system
;;    managed by the dungeon's resident troll.
;;
;; Background:
;; During exploration, many interaction sets include a chance of token transfers - either
;; sending tokens to the protocol or receiving them as rewards. While these transfer
;; events may only trigger a small percentage of the time, the post-conditions must be 
;; set for every exploration attempt to handle potential outcomes. The Troll Toll ensures
;; these post-conditions are consistently present by enforcing a toll payment that
;; increases with each passing adventurer.
;;
;; Key Features:
;; 1. Increasing Toll: Starts at 1 DMG and increases by 0.1 DMG with each explorer
;;    who passes through, reflecting the troll's growing appetite.
;; 2. Anti-Spam Mechanism: By requiring payment to the previous explorer, prevents 
;;    the same user from executing consecutive explorations.
;; 3. Predecessor Payment: Each toll is paid to the previous explorer, creating
;;    an incentive for early exploration.
;; 4. Dungeon Keeper Integration: Uses the protocol's secure transfer functions.
;;
;; Actions:
;; - PAY: Pays the current toll to the previous explorer, satisfying the troll's
;;   demands and gaining passage for exploration.
;;
;; Integration with the protocol:
;; - Required Component: Included in exploration interaction sets to ensure proper
;;   post-condition setup for any potential token operations.
;; - Spam Prevention: Natural gatekeeping mechanism as explorers must pay an
;;   ever-increasing toll to pass.
;; 
;; Usage:
;; This contract is typically called as part of an exploration interaction set.
;; When executed, it:
;; 1. Records the current explorer as the new toll recipient
;; 2. Transfers the current toll amount to the previous explorer
;; 3. Increases the toll for the next explorer
;;
;; The combination of increasing tolls and explorer rotation helps maintain
;; the protocol's security and fairness while ensuring proper technical setup for
;; all possible token operations during exploration.

;; Implement the interaction-trait
(impl-trait .dao-traits-v7.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant CONTRACT_OWNER tx-sender)
(define-constant INITIAL_AMOUNT u1000000)    ;; 1 DMG initial cost
(define-constant AMOUNT_INCREMENT u100000)    ;; 0.1 DMG increase per use

;; Data Variables
(define-data-var last-user principal tx-sender)
(define-data-var current-amount uint INITIAL_AMOUNT)
(define-data-var contract-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/interactions/the-troll-toll"))

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

(define-read-only (get-last-user)
  (ok (var-get last-user)))

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "PAY") (transfer-dmg-action sender)
    (err "INVALID_ACTION"))))

;; Action Handler
(define-private (transfer-dmg-action (sender principal))
  (let ((last-sender (var-get last-user))
    (amount (var-get current-amount)))
    (var-set last-user sender)
    (var-set current-amount (+ amount AMOUNT_INCREMENT))
    (match (contract-call? .dungeon-keeper-rc2 transfer amount sender last-sender)
      success (handle-entry-success sender amount)
      error   (handle-transfer-error error))))

;; Response Handlers

(define-private (handle-entry-success (sender principal) (amount uint))
  (begin
    (print "You gotta pay the troll toll, if you wanna get into that boy's soul.")
    (ok "TOLL_PAID")))

(define-private (handle-transfer-error (error uint))
  (if (is-eq error u1) (handle-insufficient-balance)
  (if (is-eq error u2) (handle-self-exploration)
  (if (is-eq error u3) (handle-invalid-amount)
  (if (is-eq error u405) (handle-limit-exceeded)
  (if (is-eq error u403) (handle-unverified)
  (handle-unknown-error)))))))

(define-private (handle-insufficient-balance)
  (begin
    (print "No coin, no crossing! The troll's demands exceed your means.")
    (ok "TOLL_UNPAID")))

(define-private (handle-self-exploration)
  (begin
    (print "The troll grumbles: Can't pay yourself! Wait for another to cross first.")
    (ok "TOLL_UNPAID")))

(define-private (handle-invalid-amount)
  (begin
    (print "Price goes up with every crossing! The troll's greed grows stronger.")
    (ok "TOLL_UNPAID")))

(define-private (handle-limit-exceeded)
  (begin
    (print "The troll is busy counting coins. Best wait a moment.")
    (ok "TOLL_UNPAID")))

(define-private (handle-unverified)
  (begin
    (print "You're not on the list! The troll doesn't recognize your right to pay.")
    (ok "TOLL_UNPAID")))

(define-private (handle-unknown-error)
  (begin
    (print "The troll seems distracted by something in the shadows.")
    (ok "TOLL_UNPAID")))

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))

(define-public (reset-amount)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set current-amount INITIAL_AMOUNT))))