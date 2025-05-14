---
title: "Trait screenfriends-gamma-commission"
draft: true
---
```
(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; Team (2.5%)
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SPSSETN3G8A1V7PB0M6A8Q27WFG5J9EMWTDE1WZA))

        ;; Gamma (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))

        (ok true)
    )
)
```
