---
title: "Trait historical-reserve-state"
draft: true
---
```
(define-read-only (get-reserve-state-at (asset principal) (height uint))
  (at-block (unwrap-panic (get-block-info? id-header-hash height))
    (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read asset)
  )
)
```
