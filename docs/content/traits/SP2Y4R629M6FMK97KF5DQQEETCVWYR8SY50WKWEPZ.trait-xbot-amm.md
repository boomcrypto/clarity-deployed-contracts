---
title: "Trait trait-xbot-amm"
draft: true
---
```
(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

;; amm-swap-pool-v1-1-trait
(define-trait amm-swap-pool-v1-1-trait
    (
        (swap-helper (<ft-trait> <ft-trait> uint uint (optional uint)) (response uint uint))

        (swap-helper-a (<ft-trait> <ft-trait> <ft-trait> uint uint uint (optional uint)) (response uint uint))

        (swap-helper-b (<ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint (optional uint)) (response uint uint))

        (swap-helper-c (<ft-trait> <ft-trait> <ft-trait> <ft-trait> <ft-trait> uint uint uint uint uint (optional uint)) (response uint uint))

        (swap-x-for-y (<ft-trait> <ft-trait> uint uint (optional uint)) (response (tuple (dx uint) (dy uint)) uint))

        (swap-y-for-x (<ft-trait> <ft-trait> uint uint (optional uint)) (response (tuple (dx uint) (dy uint)) uint))
    )
)
```
