---
title: "Trait boosted"
draft: true
---
```

(define-data-var contract-owner (optional principal) none)

(define-read-only (get-owner)
     (var-get contract-owner)
)

(define-map deposits principal {deadline:uint, amount: uint})


(define-public (set-owner )
(begin
    (asserts! (is-eq tx-sender contract-caller) (err "mismatch caller"))
    (asserts! (is-eq (var-get contract-owner) none) (err "owner already set"))
    (var-set contract-owner (some tx-sender))
    (ok true)
)
)

(define-public (deposit (amount uint) )
    (begin
        (map-set deposits tx-sender {deadline: u0, amount: amount})
        (stx-transfer? amount tx-sender (as-contract tx-sender))
    )
)

(define-read-only (get-user-deposit (user principal))
     (get amount (unwrap-panic (map-get? deposits user) ))
)

(define-read-only (get-new-deposit (user principal) (withdrawal uint))
     (- (get amount (unwrap-panic (map-get? deposits user) )) withdrawal )
)

(define-public (claim)
    (begin
        (asserts! (is-eq (some contract-caller) (var-get contract-owner)) (err u104))
        (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (unwrap-panic (var-get contract-owner))))
    )
)

(define-public (withdraw (amount uint) )
    (begin 
    (asserts! (> (get-new-deposit tx-sender amount) u0) (err u10))
    (map-set deposits tx-sender {deadline:u0, amount: (get-new-deposit tx-sender amount)})
    (stx-transfer? amount (as-contract tx-sender) tx-sender)
    )
)

(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)

;; to add the trait clarinet requirements add SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (deposit_sbt (amount uint) )
    (begin
        (map-set deposits tx-sender {deadline: u0, amount: amount})
        (transfer-ft sbtc-token amount tx-sender (as-contract tx-sender))
    )
)

(define-public (withdraw_sbtc (amount uint) )
    (begin 
    (asserts! (> (get-new-deposit tx-sender amount) u0) (err u10))
    (map-set deposits tx-sender {deadline:u0, amount: (get-new-deposit tx-sender amount)})
    (transfer-ft sbtc-token amount (as-contract tx-sender) tx-sender)
    )
)
```
