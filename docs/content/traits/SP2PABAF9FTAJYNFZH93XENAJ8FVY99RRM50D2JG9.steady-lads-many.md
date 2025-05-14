---
title: "Trait steady-lads-many"
draft: true
---
```
(define-public (transfer-many (details (list 200 {id: uint, to: principal})))
    (ok (map transfer details)))

(define-private (transfer (detail {id: uint, to: principal}))
    (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads 
        transfer (get id detail) tx-sender (get to detail)))
```
