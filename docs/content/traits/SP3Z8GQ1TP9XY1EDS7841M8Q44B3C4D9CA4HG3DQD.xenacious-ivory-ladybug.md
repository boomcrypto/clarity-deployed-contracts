---
title: "Trait xenacious-ivory-ladybug"
draft: true
---
```
(define-read-only (get-pools-batch (pool-ids (list 200 uint)))
  (let ((results (map get-pool-tuple pool-ids)))
    results))

(define-private (get-pool-tuple (pool-id uint))
  (let ((pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool pool-id)))
    pool))

```
