---
title: "Trait refer-reward-ft-v6"
draft: true
---
```
;; refer-reward-ft
;; this contract will offer SIP10 token rewards to referrer 
(impl-trait .ft-trait.ft-trait)

;; constants
(define-constant contract-owner tx-sender)

(define-constant token-reward u10)
(define-constant num-transactions-for-reward u1)

(define-constant err-invalid-caller (err u100))
(define-constant err-invalid-call (err u110))
(define-constant err-unauthorized-caller (err u99))

;; data maps and vars
(define-fungible-token refer-reward)
;; user's referrer map 
(define-map user-referrer
    principal { referrer: principal })
;; user transactions
(define-map user-transactions 
    principal { transactions: uint })

;; read-only functions 
(define-read-only (get-name) (ok "Refer rewards"))

(define-read-only (get-symbol) (ok "RR"))

(define-read-only (get-decimals) (ok u2))

(define-read-only (get-balance-of (account principal))
    (ok (ft-get-balance refer-reward account))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply refer-reward))
)

(define-read-only (get-token-uri)
    (ok (some u"https://www.tintash.com/"))
)

(define-read-only (get-referrer (user principal)) 
    (get referrer (map-get? user-referrer user))
)

(define-read-only (get-num-transactions (user principal))
    (get transactions (map-get? user-transactions user))
)

;; private functions
(define-private (remove-referrer (user principal)) 
    (begin 
        (map-delete user-referrer user)
        (map-delete user-transactions user)
    )
)

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-invalid-caller)
        (ft-transfer? refer-reward amount sender recipient)
    )
)

;; signup by referrer
(define-public (signup-by-referrer (user principal))
    (begin
        ;; !self refer  
        (asserts! (not (is-eq tx-sender user)) err-invalid-call)
        (map-set user-referrer user { referrer: tx-sender })
        (map-set user-transactions user { transactions: u0 })
        (ok true)
    )
)

;; new user completes transactions 
(define-public (complete-transaction) 
    (let
        ((transactions (+ u1 (unwrap! (get-num-transactions tx-sender) err-invalid-call)))
        (referrer (unwrap! (get-referrer tx-sender) err-invalid-call)))

        (map-set user-transactions tx-sender { transactions: transactions })
        ;; reward to referer if required number of transactions  
        (if (is-eq transactions num-transactions-for-reward) 
            (begin 
                (remove-referrer tx-sender)
                (ft-mint? refer-reward token-reward referrer)
            ) 
            (ok true)
        )
    )
)

;; mint 10 tokens to deployer
(ft-mint? refer-reward u10 tx-sender)
```
