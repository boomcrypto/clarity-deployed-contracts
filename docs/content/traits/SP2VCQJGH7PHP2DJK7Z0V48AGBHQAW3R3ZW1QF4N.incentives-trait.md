---
title: "Trait incentives-trait"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)

(define-trait incentives-trait
  (
    ;; Transfer from the caller to a new principal
    (claim-rewards (<ft> <ft> principal) (response bool uint))
  )
)
```
