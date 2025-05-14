---
title: "Trait route"
draft: true
---
```

(use-trait sip-010 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-route-create-pool (err u8001))
(define-constant err-route-swap-token (err u8002))
(define-constant err-exceed-max-slippage (err u8003))

(define-public (create-pool-and-buy-first (token-contract <sip-010>) (recipient principal) (amount uint))
    (begin
        (unwrap! (contract-call? .pool create-pool token-contract) err-route-create-pool) 
        (if (> amount u0)

            (let ((out-token (unwrap! (contract-call? .pool swap-token token-contract amount) err-route-swap-token)))
                (try! (contract-call? token-contract transfer out-token tx-sender recipient none))
                (ok out-token))

            (ok u0)) 
    )
)

(define-public (swap-token-with-slippage (token-contract <sip-010>) (in-stx uint) (out-token-min uint))
    (let ((out-token (unwrap! (contract-call? .pool swap-token token-contract in-stx) err-route-swap-token)))
        (asserts! (>= out-token out-token-min) err-exceed-max-slippage)
        (ok out-token)
    )
)

(define-public (swap-stx-with-slippage (token-contract <sip-010>) (in-token uint) (out-stx-real-min uint))
    (let ((out-stx-real (unwrap! (contract-call? .pool swap-stx token-contract in-token) err-route-swap-token)))
        (asserts! (>= out-stx-real out-stx-real-min) err-exceed-max-slippage)
        (ok out-stx-real)
    )
)

(define-public (swap-exact-token-with-slippage (token-contract <sip-010>) (out-token uint) (in-stx-max uint))
    (let ((in-stx (unwrap! (contract-call? .pool swap-exact-token token-contract out-token) err-route-swap-token)))
        (asserts! (<= in-stx in-stx-max) err-exceed-max-slippage)
        (ok in-stx)
    )
)

(define-public (swap-exact-stx-with-slippage (token-contract <sip-010>) (out-stx-real uint) (in-token-max uint))
    (let ((in-token (unwrap! (contract-call? .pool swap-exact-stx token-contract out-stx-real) err-route-swap-token)))
        (asserts! (<= in-token in-token-max) err-exceed-max-slippage)
        (ok in-token)
    )
)
    
```
