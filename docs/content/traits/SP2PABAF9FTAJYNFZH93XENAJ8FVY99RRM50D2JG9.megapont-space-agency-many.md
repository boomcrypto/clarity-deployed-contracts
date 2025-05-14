---
title: "Trait megapont-space-agency-many"
draft: true
---
```
(define-public (transfer-many (details (list 200 {id: uint, to: principal})))
    (ok (map transfer details)))

(define-private (transfer (detail {id: uint, to: principal}))
    (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.megapont-space-agency 
        transfer (get id detail) tx-sender (get to detail)))
```
