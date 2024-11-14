---
title: "Trait staking-silo-v1"
draft: true
---
```
;; @contract Staking Silo
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_CLAIM_FOR_ID (err u4001))
(define-constant ERR_NOT_COOLED_DOWN (err u4002))
(define-constant ERR_ONLY_STAKING_CONTRACT (err u4003))
(define-constant ERR_ABOVE_MAX (err u4004))

(define-constant max-cooldown-window u4320)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var cooldown-window uint u1008)

(define-data-var current-claim-id uint u0)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map claims
  { 
    claim-id: uint
  }
  {
    recipient: principal,
    amount: uint,
    claim-block-height: uint,
  }
)


;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-cooldown-window)
  (var-get cooldown-window)
)

(define-read-only (get-current-claim-id)
  (var-get current-claim-id)
)

(define-read-only (get-claim (id uint))
  (ok (unwrap! (map-get? claims { claim-id: id }) ERR_NO_CLAIM_FOR_ID))
)

;;-------------------------------------
;; User
;;-------------------------------------

(define-public (claim-many (entries (list 1000 uint)))
  (ok (map claim entries)))

(define-public (claim (claim-id uint))
  (let (
    (current-claim (try! (get-claim claim-id)))
  )
    (asserts! (>= burn-block-height (+ (get claim-block-height current-claim) (get-cooldown-window))) ERR_NOT_COOLED_DOWN)
    (try! (contract-call? .usdh-token-v1 transfer (get amount current-claim) (as-contract tx-sender) (get recipient current-claim) none))
    (ok (map-delete claims { claim-id: claim-id }))
  )
)

;;-------------------------------------
;; Protocol
;;-------------------------------------

(define-public (create-claim (amount uint) (recipient principal))
  (let (
    (next-claim-id (+ (get-current-claim-id) u1))
  )
    (asserts! (is-eq contract-caller .staking-v1) ERR_ONLY_STAKING_CONTRACT)
    (map-set claims { claim-id: next-claim-id } 
      {
        recipient: recipient,
        amount: amount,
        claim-block-height: burn-block-height,
      }
    )
    (var-set current-claim-id next-claim-id)
    (print {claim-id: next-claim-id, recipient: recipient, claim-block-height: burn-block-height})
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-cooldown-window (new-window uint))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol tx-sender))
    (asserts! (<= new-window max-cooldown-window ) ERR_ABOVE_MAX)
    (ok (var-set cooldown-window new-window))
  )
)
```
