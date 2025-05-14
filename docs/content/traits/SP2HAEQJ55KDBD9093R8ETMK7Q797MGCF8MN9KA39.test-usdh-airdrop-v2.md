---
title: "Trait test-usdh-airdrop-v2"
draft: true
---
```
;; @contract USDh airdrop
;; @version 0.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_WHITELISTED (err u8001))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u8002))
(define-constant ERR_AMOUNT_IS_ZERO (err u8003))

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var next-airdrop-id uint u0)

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

(define-read-only (get-next-airdrop-id)
  (var-get next-airdrop-id)
)

;;-------------------------------------
;; Airdrop functions
;;-------------------------------------

(define-private (airdrop-processor (entry { recipient: principal, amount: uint, memo: (optional (buff 34)) }))
  (let (
    (recipient (get recipient entry))
    (amount (get amount entry)))
    (asserts! (> amount u0) ERR_AMOUNT_IS_ZERO)
    (asserts! (is-standard recipient) ERR_NOT_STANDARD_PRINCIPAL)
    (try! (contract-call? .test-usdh-token-final transfer amount this-contract recipient (get memo entry)))
    (ok true)

  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value 
    result
    err-value (err err-value)
    )
)

(define-public (send-airdrop 
  (entries (list 200 { recipient: principal, amount: uint, memo: (optional (buff 34)) })) 
  (purpose (optional (string-ascii 40))) 
  (total-amount uint))
  (let (
    (current-airdrop-id (var-get next-airdrop-id)))

    (asserts! (get active (get-whitelist contract-caller)) ERR_NOT_WHITELISTED)
    (var-set next-airdrop-id (+ current-airdrop-id u1))
    (print { airdrop-id: current-airdrop-id, purpose: purpose, total-amount: total-amount })
    (fold check-err (map airdrop-processor entries) (ok true))
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
