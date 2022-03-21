---
title: "Trait commission-fixed"
draft: true
---
```
(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u50) tx-sender 'STCNPGEJHX5553KXMVY46R3RZQP8V5NS14JMK95S))
        (ok true)))
```
