---
title: "Trait trait-granite-liquidator"
draft: true
---
```
(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-trait granite-liquidator-trait
  (
    (liquidate-collateral ((optional (buff 8192)) <ft-trait> principal uint uint) (response bool uint))

    (batch-liquidate ((optional (buff 8192)) <ft-trait> (list 20 (optional {user: principal, liquidator-repay-amount: uint, min-collateral-expected: uint }))) (response bool uint))
  )
)

```
