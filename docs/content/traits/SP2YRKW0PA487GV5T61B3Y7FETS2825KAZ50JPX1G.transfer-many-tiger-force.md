---
title: "Trait transfer-many-tiger-force"
draft: true
---
```
(define-public (bulk-transfer (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.tiger-force transfer id tx-sender receiver))
```