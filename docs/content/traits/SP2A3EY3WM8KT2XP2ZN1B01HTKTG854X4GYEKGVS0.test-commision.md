---
title: "Trait test-commision"
draft: true
---
```
(define-public (pay (id uint) (price uint)) 
    (begin 
       
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP1EZ79F0Z3ED7AWKCB9KRKNPTMMY4PPK3N2AHQXV))
        (ok true)
    )
)
```
