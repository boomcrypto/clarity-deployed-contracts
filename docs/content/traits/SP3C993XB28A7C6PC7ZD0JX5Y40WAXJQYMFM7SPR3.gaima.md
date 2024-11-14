---
title: "Trait gaima"
draft: true
---
```
(define-public (pay (id uint) (price uint)) 
    (begin 
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP278DZ4KD1VTBYSTFAANA6C5ADDDV9QEV2T11Q6W))
        (ok true)
    )
)
```
