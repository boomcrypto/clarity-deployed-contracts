---
title: "Trait initialize-energy"
draft: true
---
```
(define-map initialized principal bool)

(define-data-var last-id uint u0)

(define-read-only (get-last-id)
  (var-get last-id)
)

(define-read-only (is-initialized (address principal))
  (default-to false (map-get? initialized address))
)

(define-public (initialize)
  (let ((already-initialized (is-initialized tx-sender)))
    (if already-initialized
      (ok (get-last-id))
      (begin 
        (unwrap-panic (contract-call? .energy mint u100000000 tx-sender))
        (map-set initialized tx-sender true)
        (var-set last-id (+ (var-get last-id) u1))
        (ok (get-last-id))
      )
    )
  )
)
```
