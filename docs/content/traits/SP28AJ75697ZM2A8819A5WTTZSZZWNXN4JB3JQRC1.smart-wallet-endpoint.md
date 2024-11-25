---
title: "Trait smart-wallet-endpoint"
draft: true
---
```
(define-constant err-invalid-payload (err u5000))

(define-public (stx-transfer-sponsored (details {amount: uint, to: principal, fees: uint}))
    (contract-call? .smart-wallet extension-call .sponsored-transfer (unwrap! (to-consensus-buff? details) err-invalid-payload)))


(define-public (stx-transfer (details {amount: uint, to: principal}))
    (contract-call? .smart-wallet stx-transfer (get amount details) (get to details) none))

```
