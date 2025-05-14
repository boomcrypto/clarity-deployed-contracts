---
title: "Trait hooter-farm"
draft: true
---
```
;; Hooter Farm Interaction
;; Burns .energy tokens and rewards with .hooter-the-owl tokens

;; Traits
(impl-trait .charisma-traits-v1.interaction-trait)
(use-trait rulebook-trait .charisma-traits-v1.rulebook-trait)

;; Constants
(define-constant CONTRACT (as-contract tx-sender))
(define-constant DEPLOYER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant BURN_AMOUNT u100000000) ;; Fixed burn amount

;; Storage
(define-data-var contract-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/api/v0/interactions/hooter-farm"))

;; Read-only functions
(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri)))

;; Public functions
(define-public (execute (rulebook <rulebook-trait>) (action (string-ascii 32)))
  (begin 
    (try! (contract-call? .charisma-rulebook-registry authorize rulebook))
    (if (is-eq action "CLAIM_TOKENS") 
        (burn-and-reward-action rulebook)
        (err "INVALID_ACTION"))))

;; Action handlers
(define-private (burn-and-reward-action (rulebook <rulebook-trait>))
  (let (
    (sender tx-sender)
  )
    ;; First burn the energy tokens
    (try! (match (contract-call? .energy burn BURN_AMOUNT sender) success (ok BURN_AMOUNT) error (err "BURN_FAILED")))
    
    ;; Then transfer the reward tokens
    (try! (match (as-contract (contract-call? .hooter-the-owl transfer BURN_AMOUNT CONTRACT sender none)) success (ok BURN_AMOUNT) error (err "NO_REWARDS_AVAILABLE")))
    
    ;; Return success
    (ok "CLAIM_TOKENS_SUCCESS")))

;; Admin functions
(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))))
```
