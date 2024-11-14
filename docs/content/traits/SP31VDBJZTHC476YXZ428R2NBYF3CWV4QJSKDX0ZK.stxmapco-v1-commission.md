---
title: "Trait stxmapco-v1-commission"
draft: true
---
```
(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2N7V30GFEQAHMNMMTJ6VJBZEGQ3RKS1M2KCEDX7))
    (ok true)))
```
