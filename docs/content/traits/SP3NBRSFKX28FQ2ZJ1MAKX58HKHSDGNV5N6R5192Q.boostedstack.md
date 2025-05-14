---
title: "Trait boostedstack"
draft: true
---
```

(define-data-var contract-owner (optional principal) none)

(define-read-only (get-owner)
     (var-get contract-owner)
)

(define-map deposits principal {deadline:int, amount: uint})


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
        (map-set deposits tx-sender {deadline:0, amount: amount})
        (stx-transfer? amount tx-sender (as-contract tx-sender))
    )
)

(define-read-only (get-user-deposit (user principal))
     (get amount (unwrap-panic (map-get? deposits user) ))
)

(define-read-only (get-new-deposit (user principal) (withdrawal uint))
     (- (get amount (unwrap-panic (map-get? deposits user) )) withdrawal )
)



(define-public (withdraw (amount uint) )
    (begin 
    (asserts! (> (get-new-deposit tx-sender amount) u0) (err u10))
    (map-set deposits tx-sender {deadline:0, amount: (get-new-deposit tx-sender amount)})
    (stx-transfer? amount tx-sender (as-contract tx-sender))
    )
)




```
