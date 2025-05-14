---
title: "Trait test-usdh-airdrop-v1"
draft: true
---
```
;; @contract USDh airdrop
;; @version 0.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_WHITELISTED (err u7001))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u7002))

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var last-airdrop-id uint u0)
(define-data-var total-airdrops-amount uint u0)
(define-data-var airdrop-amount-helper uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map whitelist
  {
    address: principal
  }
  {
    active: bool
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-whitelist (address principal))
  (default-to 
    { active: false }
    (map-get? whitelist { address: address })
  )
)

(define-read-only (get-last-airdrop-id)
  (var-get last-airdrop-id)
)

(define-read-only (get-total-airdrops-amount)
  (var-get total-airdrops-amount)
)

;;-------------------------------------
;; Airdrop functions
;;-------------------------------------

(define-private (airdrop-processor (entry { recipient: principal, amount: uint, memo: (optional (buff 34)) }))
  (let (
    (recipient (get recipient entry))
    (amount (get amount entry))
    (memo (get memo entry)))

    (asserts! (is-standard recipient) ERR_NOT_STANDARD_PRINCIPAL)
    (var-set airdrop-amount-helper (+ (var-get airdrop-amount-helper) amount))
    (contract-call? .test-usdh-token-final transfer amount this-contract recipient memo)
    
  )
)

(define-public (send-airdrop (entries (list 1000 { recipient: principal, amount: uint, memo: (optional (buff 34)) })) (purpose (optional (string-ascii 40))))
  (let (
    (current-id (var-get last-airdrop-id))
    (current-airdrop-amount (var-get airdrop-amount-helper)))

    (asserts! (get active (get-whitelist contract-caller)) ERR_NOT_WHITELISTED)
    (map airdrop-processor entries)
    (print { airdrop-id: current-id, total-airdrop-amount: current-airdrop-amount, purpose: purpose })
    (var-set last-airdrop-id current-id u1)
    (var-set total-airdrops-amount (+ (var-get total-airdrops-amount) current-airdrop-amount))
    (ok (var-set airdrop-amount-helper u0))
  )
)


;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-whitelist (address principal) (active bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, old-value: (get-whitelist address),  new-value: { active: active } })
    (ok (map-set whitelist { address: address } { active: active }))
  )
)

```
