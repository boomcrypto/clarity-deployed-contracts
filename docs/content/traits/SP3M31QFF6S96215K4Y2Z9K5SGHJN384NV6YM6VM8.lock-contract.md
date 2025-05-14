---
title: "Trait lock-contract"
draft: true
---
```
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-principal (err u101))
(define-constant err-min-amount (err u102))

(define-data-var contract-owner principal tx-sender)
(define-data-var temp-contract-owner principal tx-sender)

(define-data-var min-amount uint u1000000000)

(define-data-var idx uint u0)

(define-data-var unlock-address principal tx-sender)
(define-data-var temp-unlock-address principal tx-sender)


(define-read-only (get-min-amount)
    (var-get min-amount))

(define-read-only (get-idx)
    (var-get idx))

(define-read-only (get-contract-owner)
    (var-get contract-owner))

(define-read-only (get-temp-contract-owner)
    (var-get temp-contract-owner))

(define-read-only (get-unlock-address)
    (var-get unlock-address))

(define-read-only (get-temp-unlock-address)
    (var-get temp-unlock-address))

;; token ops
(define-public (lock-tokens (amount uint) (recipient (string-utf8 256)))
    (let ((last-idx (increase-idx)))
        (asserts! (>= amount (var-get min-amount)) err-min-amount)
        (try! (contract-call? .satoshai transfer amount tx-sender (as-contract tx-sender) none))
        (print { type: "lock-tokens", payload: {
            key: tx-sender,
            data: { amount: amount, recipient: recipient, idx: last-idx }
        }})
        (ok { amount: amount, recipient: recipient, idx: last-idx })
    )
)

(define-public (unlock-tokens
    (amount uint)
    (recipient principal)
    (signature (string-utf8 512))
    )
    (begin
        (asserts! (is-eq tx-sender (var-get unlock-address)) err-unauthorized)
        (as-contract (try! (contract-call? .satoshai transfer amount tx-sender recipient none)))
        (print { type: "unlock-tokens", payload: {
            key: tx-sender,
            data: { amount: amount, recipient: recipient, signature: signature }
        }})
        (ok { amount: amount, recipient: recipient, signature: signature })
    )
)

(define-public (init-set-contract-owner (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (asserts! (is-standard new-owner) err-invalid-principal)
        (var-set temp-contract-owner new-owner)
        (ok true)
    )
)

;; admin ops
(define-public (confirm-set-contract-owner)
    (begin
        (asserts! (is-eq tx-sender (var-get temp-contract-owner)) err-unauthorized)
        (var-set contract-owner (var-get temp-contract-owner))
        (ok true)
    )
)

(define-public (init-set-unlock-address (new-unlock-address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (asserts! (is-standard new-unlock-address) err-invalid-principal)
        (var-set temp-unlock-address new-unlock-address)
        (ok true)
    )
)

(define-public (confirm-set-unlock-address)
    (begin
        (asserts! (is-eq tx-sender (var-get temp-unlock-address)) err-unauthorized)
        (var-set unlock-address (var-get temp-unlock-address))
        (ok true)
    )
)

(define-public (set-min-amount (new-min-amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized)
        (asserts! (> new-min-amount u0) err-min-amount)
        (var-set min-amount new-min-amount)
        (ok true)
    )
)

(define-private (increase-idx)
    (let ((last-idx (var-get idx)))
        (var-set idx (+ u1 last-idx))
        last-idx
    )
)

```
