---
title: "Trait sponsored-transfer"
draft: true
---
```
(define-constant err-invalid-payload (err u500))

(define-public (call (payload (buff 2048)))
    (let ((details (unwrap! (from-consensus-buff? {amount: uint, to: principal, fees: uint} payload) err-invalid-payload)))
        (try! (stx-transfer? (get amount details) tx-sender (get to details)))
        (match tx-sponsor?
            spnsr (try! (stx-transfer? (get fees details) tx-sender spnsr))
            true
        )
        (ok true)
    ))
```
