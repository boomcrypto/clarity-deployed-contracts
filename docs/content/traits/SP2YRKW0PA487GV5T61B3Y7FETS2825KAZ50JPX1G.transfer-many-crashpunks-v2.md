---
title: "Trait transfer-many-crashpunks-v2"
draft: true
---
```
(define-public (bulk-transfer (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks-v2 transfer id tx-sender receiver))
```