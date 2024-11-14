---
title: "Trait fatigue-rc1"
draft: true
---
```
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
(impl-trait .dao-traits-v6.interaction-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant ERR_INSUFFICIENT_ENERGY (err u403))
(define-constant CONTRACT_OWNER tx-sender)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/explore/fatigue"))
(define-data-var energy-burn-amount uint u10000000) ;; Default to 10 energy (10,000,000 micro-energy)

;; Read-only functions

(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-actions)
  (ok (list "BURN"))
)

(define-read-only (get-energy-burn-amount)
  (ok (var-get energy-burn-amount))
)

;; Public functions

(define-public (execute (action (string-ascii 32)))
  (let ((sender tx-sender))
    (if (is-eq action "BURN")
      (burn-energy-action sender)
      ERR_INVALID_ACTION
    )
  )
)

;; Private functions

(define-private (burn-energy-action (sender principal))
  (let (
    (burn-amount (var-get energy-burn-amount))
    (user-energy (unwrap! (contract-call? .energy get-balance sender) (err u500)))
  )
    (asserts! (>= user-energy burn-amount) ERR_INSUFFICIENT_ENERGY)
    (contract-call? .dungeon-keeper-rc2 exhaust burn-amount sender)
  )
)

;; Admin functions

(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)

(define-public (set-energy-burn-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (var-set energy-burn-amount new-amount))
  )
)
```
