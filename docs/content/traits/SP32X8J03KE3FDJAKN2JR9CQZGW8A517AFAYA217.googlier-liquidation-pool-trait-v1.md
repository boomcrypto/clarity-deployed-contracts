---
title: "Trait googlier-liquidation-pool-trait-v1"
draft: true
---
```
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-trait liquidation-pool-trait
  (
    (get-shares-at (principal uint) (response uint uint))

    (max-withdrawable-usd () (response uint uint))
    (withdraw (uint) (response uint uint))
  )
)

```
