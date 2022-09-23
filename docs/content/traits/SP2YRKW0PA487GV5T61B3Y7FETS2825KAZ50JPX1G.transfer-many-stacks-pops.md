---
title: "Trait transfer-many-stacks-pops"
draft: true
---
```
(define-public (bulk-transfer (ids (list 1000 uint)) (receivers (list 1000 principal))) (begin (print (map transfer ids receivers)) (ok true)))
(define-private (transfer (id uint) (receiver principal)) (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops transfer id tx-sender receiver))
```