---
title: "Trait bond-values-trait-v1-1"
draft: true
---
```
;; @contract Bond Values Trait
;; @version 1

(define-trait bond-values-trait
  (

    ;; valuation of token
    (get-valuation (principal) (response uint uint))

    ;; USDA value of token
    (get-usda-value (principal) (response uint uint))

  )
)

```
