---
title: "Trait ordrich-dexterity"
draft: true
---
```
(define-constant ERR_FAILED (err u500))
(define-public (swap)
    (begin
        (try! (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.ordrich-dexterity set-swap-fee u1000))
        (try! (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.ordrich-dexterity swap true u1000000000))
        (try! (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.ordrich-dexterity set-swap-fee u10000000))
        (ok true)))
```
