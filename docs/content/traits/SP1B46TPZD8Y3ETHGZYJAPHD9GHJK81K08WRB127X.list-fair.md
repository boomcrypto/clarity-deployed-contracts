---
title: "Trait list-fair"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u5)))
      )
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)

```
