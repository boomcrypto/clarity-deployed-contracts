---
title: "Trait arkadiko-vaults-data-trait-v1-1"
draft: true
---
```
(define-trait vaults-data-trait
  (
    (get-vault (principal principal) (response (tuple 
      (status uint) 
      (collateral uint)
      (debt uint)
      (last-block uint)
    ) uint))

    (get-total-debt (principal) (response uint uint))

    (set-vault (principal principal uint uint uint) (response bool uint))
  )
)

```
