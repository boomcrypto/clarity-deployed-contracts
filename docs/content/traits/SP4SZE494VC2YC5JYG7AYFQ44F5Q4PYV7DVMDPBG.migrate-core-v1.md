---
title: "Trait migrate-core-v1"
draft: true
---
```


(define-public (migrate)
  (let (
    (amount (unwrap-panic (contract-call? .ststx-token get-balance .stacking-dao-core-v3)))
  )
    (try! (contract-call? .ststx-token burn-for-protocol amount .stacking-dao-core-v3))
    (try! (contract-call? .ststx-token mint-for-protocol amount .stacking-dao-core-v4))
    (ok true)
  )
)
```
