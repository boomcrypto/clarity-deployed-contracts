---
title: "Trait apple-orchard"
draft: true
---
```
(define-constant farmers u1)

(define-public (harvest (creature-id uint))
    (let
        (
            (energy-amount (try! (contract-call? .creatures tap creature-id)))
            ;; farmers do twice as much work as other creature types in the apple orchard
            (token-amount (if (is-eq creature-id farmers) (* energy-amount u2) energy-amount))
			      (original-sender tx-sender)
        )
        (as-contract (contract-call? .fuji-apples transfer token-amount tx-sender original-sender none))
    )
)
```
