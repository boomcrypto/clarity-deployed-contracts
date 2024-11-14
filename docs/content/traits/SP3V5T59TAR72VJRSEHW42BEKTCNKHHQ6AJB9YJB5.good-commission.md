---
title: "Trait good-commission"
draft: true
---
```
(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP3V5T59TAR72VJRSEHW42BEKTCNKHHQ6AJB9YJB5))
    (ok true)))
```
