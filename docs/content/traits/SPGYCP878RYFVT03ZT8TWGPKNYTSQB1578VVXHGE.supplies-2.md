---
title: "Trait supplies-2"
draft: true
---
```
(define-read-only (get-each-total-supply)
  (ok 
    (tuple
      (chdollar
        (unwrap-panic 
          (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.chdollar
                          get-total-supply)))
      (anonymous-welsh-cvlt
        (unwrap-panic 
          (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.anonymous-welsh-cvlt
                          get-total-supply)))
      (stx-hoot-lp-token
        (unwrap-panic 
          (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.stx-hoot-lp-token
                          get-total-supply)))
      (satoshis-private-key
        (unwrap-panic 
          (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.satoshis-private-key
                          get-total-supply)))
      (stdollar
        (unwrap-panic 
          (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.stdollar
                          get-total-supply)))
    )
  )
)
```
