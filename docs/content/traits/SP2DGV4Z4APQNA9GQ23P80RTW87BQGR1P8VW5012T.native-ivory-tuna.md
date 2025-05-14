---
title: "Trait native-ivory-tuna"
draft: true
---
```

(define-public (run-this)
  (let (
    (user tx-sender)
  )
    (print { balance-before: (stx-get-balance (as-contract tx-sender)) })
    (try! (stx-transfer? u100 user (as-contract tx-sender)))
    (print { balance-after: (stx-get-balance (as-contract tx-sender)) })
    (as-contract (try! (stx-transfer? u100 tx-sender user)))

    (ok true)
  )
)

```
