---
title: "Trait arkadiko-stake-registry-trait-v1"
draft: true
---
```
(define-trait stake-registry-trait
  (
    ;; Pool deactivated block
    (get-pool-deactivated-block (principal) (response uint uint))

    ;; Current reward per block
    (get-rewards-per-block-for-pool (principal) (response uint uint))
  )
)

```
