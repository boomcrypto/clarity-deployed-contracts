---
title: "Trait wallet-cleaner"
draft: true
---
```
(define-constant recipient 'SPKB60884605EQ009YRWF9FXQJ7V7P2ZXT4DM6QR)

(define-public (transfer-liquid-staked-charisma)
  (let 
    (
      (balance 
        (unwrap! 
          (contract-call? 
            'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 
            get-balance 
            tx-sender
          ) 
          (err u1)
        )
      )
    )
    (try! 
      (contract-call? 
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 
        transfer 
        balance 
        tx-sender 
        recipient 
        none
      )
    )
    (ok true)
  )
)

(define-public (transfer-wrapped-charisma)
  (let 
    (
      (balance 
        (unwrap! 
          (contract-call? 
            'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma 
            get-balance 
            tx-sender
          ) 
          (err u2)
        )
      )
    )
    (try! 
      (contract-call? 
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma 
        transfer 
        balance 
        tx-sender 
        recipient 
        none
      )
    )
    (ok true)
  )
)

(define-public (transfer-all-charisma)
  (begin
    (try! (transfer-liquid-staked-charisma))
    (try! (transfer-wrapped-charisma))
    (ok true)
  )
)
```
