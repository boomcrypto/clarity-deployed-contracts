---
title: "Trait list-rozar"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP28FHT7VGBJ3B0584V1EVHED3MKTE1M8VQJDNB6R.rozar-stxcity true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP28FHT7VGBJ3B0584V1EVHED3MKTE1M8VQJDNB6R.rozar-stxcity)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP28FHT7VGBJ3B0584V1EVHED3MKTE1M8VQJDNB6R.rozar-stxcity get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u4)))
      )
      (print {event: "enable-listing", contract: "SP28FHT7VGBJ3B0584V1EVHED3MKTE1M8VQJDNB6R.rozar-stxcity", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)

```
