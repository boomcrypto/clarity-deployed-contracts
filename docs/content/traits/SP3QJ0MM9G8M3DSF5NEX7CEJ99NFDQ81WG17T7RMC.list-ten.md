---
title: "Trait list-ten"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u5)))
      )
      (print {event: "enable-listing", contract: "SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)

```
