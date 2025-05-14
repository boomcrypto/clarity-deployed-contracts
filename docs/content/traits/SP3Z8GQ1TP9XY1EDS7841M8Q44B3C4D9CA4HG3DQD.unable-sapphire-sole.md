---
title: "Trait unable-sapphire-sole"
draft: true
---
```
(define-read-only (get-pools-batch
    (token-x-list (list 200 principal))
    (token-y-list (list 200 principal))
    (factors (list 200 uint)))
  (let ((results (map get-pool-tuple token-x-list token-y-list factors)))
    results))

(define-private (get-pool-tuple (token-x principal) (token-y principal) (factor uint))
  (let ((pool (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))
    pool))
```
