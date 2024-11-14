;; Hot Potato Interaction Contract
;;
;; This contract implements an interaction that transfers 1,000,000 DMG to the last person
;; who used the contract. It has a single action: "PASS".
;;
;; Key Features:
;; 1. Single Action: Implements one action to transfer DMG tokens.
;; 2. Last User Tracking: Keeps track of the last user who interacted with the contract.
;; 3. Fixed Transfer Amount: Transfers a fixed amount of 1,000,000 DMG tokens.
;; 4. Dungeon Keeper Integration: Uses the Dungeon Keeper's transfer function for DMG transfers.
;;
;; Integration with Charisma Ecosystem:
;; - Implements the interaction-trait for compatibility with the exploration system.
;; - Interacts with the Dungeon Keeper contract for transfer operations.
;;
;; Usage:
;; When executed, this contract will transfer 1,000,000 DMG tokens to the last user
;; who interacted with it, updating the last user to the current sender.

;; Implement the interaction-trait
(impl-trait .dao-traits-v6.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant CONTRACT_OWNER tx-sender)
(define-constant TRANSFER_AMOUNT u1000000)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/explore/hot-potato"))
(define-data-var last-user principal tx-sender)

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-actions)
  (ok (list "PASS"))
)

(define-read-only (get-last-user)
  (ok (var-get last-user))
)

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "PASS")
      (transfer-dmg-action sender)
      ERR_INVALID_ACTION
    )
  )
)

;; Private functions

(define-private (transfer-dmg-action (sender principal))
  (let (
    (last-user-principal (var-get last-user))
  )
    ;; Update last user before transfer
    (var-set last-user sender)
    ;; Perform transfer to the previous last user using Dungeon Keeper's transfer function
    (contract-call? .dungeon-keeper-rc2 transfer TRANSFER_AMOUNT sender last-user-principal)
  )
)

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)