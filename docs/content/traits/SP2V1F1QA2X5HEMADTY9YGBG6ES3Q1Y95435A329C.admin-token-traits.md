---
title: "Trait admin-token-traits"
draft: true
---
```
(define-trait admin-token-trait
  (
    ;; Mint - Used
    (mint (uint principal) (response bool uint))

    ;; Burn 
    (burn (uint principal) (response bool uint))
  )
)
```
