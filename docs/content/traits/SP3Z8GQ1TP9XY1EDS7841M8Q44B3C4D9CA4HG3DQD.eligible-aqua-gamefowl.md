---
title: "Trait eligible-aqua-gamefowl"
draft: true
---
```
(define-read-only (get-pools-batch (pool-ids (list 200 uint)))
  (let ((results (map get-pool-tuple pool-ids)))
    results))

(define-private (get-pool-tuple (pool-id uint))
  (let ((pool (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool pool-id)))
    pool))

```
