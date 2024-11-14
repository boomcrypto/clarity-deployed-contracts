---
title: "Trait charisma-left-index"
draft: true
---
```
(define-public (calculate-total-balance (address principal) (block uint))
  (let
    (
      (block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
      (good-karma-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.good-karma get-balance address)) (err u500)))
      (iron-ingots-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.iron-ingots get-balance address)) (err u500)))
      (leo-unchained-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.leo-unchained-v1 get-balance address)) (err u500)))
      (fuji-apples-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.fuji-apples get-balance address)) (err u500)))
      (magic-mojo-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.magic-mojo get-balance address)) (err u500)))
      (mr-president-pepe-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.mr-president-pepe get-balance address)) (err u500)))
      (outback-stakehouse-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.outback-stakehouse get-balance address)) (err u500)))
      (quiet-confidence-balance (unwrap! (at-block block-hash (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.quiet-confidence get-balance address)) (err u500)))
    )
    (ok (+ 
      good-karma-balance
      iron-ingots-balance
      leo-unchained-balance
      (/ fuji-apples-balance u1000000)
      magic-mojo-balance
      mr-president-pepe-balance
      outback-stakehouse-balance
      (* quiet-confidence-balance u10)
    ))
  )
)
```
