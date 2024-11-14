---
title: "Trait list-earlycrows"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY.earlycrows-bonding-curve true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY.earlycrows-bonding-curve)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY.earlycrows-bonding-curve get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u5)))
      )
      (print {event: "enable-listing", contract: "SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY.earlycrows-bonding-curve", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)

```
