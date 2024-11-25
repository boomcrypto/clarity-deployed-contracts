---
title: "Trait arb-protection"
draft: true
---
```
(define-map claimed principal bool)

(define-data-var last-id uint u0)

(define-read-only (get-last-claim-id)
  (var-get last-id)
)

(define-read-only (has-claimed (address principal))
  (default-to false (map-get? claimed address))
)

(define-public (check)
  (let ((already-claimed (has-claimed tx-sender)))
    (if already-claimed
      (let ((exp-balance (unwrap-panic (contract-call? .experience get-balance tx-sender))))
        (if (>= exp-balance u1000000)
          (ok (get-last-claim-id))
          (begin
            (try! (stx-transfer? u100000000 tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ))
            (ok (get-last-claim-id))
          )
        )
      )
      (begin 
        (unwrap-panic (contract-call? .experience mint u1000000 tx-sender))
        (map-set claimed tx-sender true)
        (var-set last-id (+ (var-get last-id) u1))
        (ok (get-last-claim-id))
      )
    )
  )
)
```
