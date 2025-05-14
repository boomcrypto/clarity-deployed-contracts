---
title: "Trait incentives-trait-v2-0"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)

(define-trait incentives-trait
  (
    ;; Transfer from the caller to a new principal
    (claim-rewards (<ft> <ft> principal) (response uint uint))
  )
)
```
