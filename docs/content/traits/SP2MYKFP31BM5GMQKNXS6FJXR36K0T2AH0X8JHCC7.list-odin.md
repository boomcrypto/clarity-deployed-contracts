---
title: "Trait list-odin"
draft: true
---
```
(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2PD6QAYP9MTG68PNW6T7JKX8WYJM9Q30EYJ55KS.lands set-whitelisted 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2PD6QAYP9MTG68PNW6T7JKX8WYJM9Q30EYJ55KS.lands get-or-create-land-id 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u4)))
      )
      (print {event: "enable-listing", contract: "SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2PD6QAYP9MTG68PNW6T7JKX8WYJM9Q30EYJ55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
```
