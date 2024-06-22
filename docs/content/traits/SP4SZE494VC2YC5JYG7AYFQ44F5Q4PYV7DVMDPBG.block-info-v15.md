---
title: "Trait block-info-v15"
draft: true
---
```
(define-read-only (get-user-zest (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))

    (zest-1 (at-block block-hash (get-user-zest-helper-1 account block)))
    (zest-2 (at-block block-hash (get-user-zest-helper-2 account block)))
    (zest-3 (at-block block-hash (get-user-zest-helper-3 account block)))
  )

    (ok (+ zest-1 zest-2 zest-3))
  )
)


(define-read-only (get-user-zest-helper-1 (account principal) (block uint))
  (if (< block u140112)
    u0
    (let (
      (user-wallet (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx get-balance account)))
    )
      user-wallet
    )
  )
)

(define-read-only (get-user-zest-helper-2 (account principal) (block uint))
  (if (< block u143344)
    u0
    (let (
      (user-wallet (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-0 get-balance account)))
    )
      user-wallet
    )
  )
)

(define-read-only (get-user-zest-helper-3 (account principal) (block uint))
  (if (< block u149388)
    u0
    (let (
      (user-wallet (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2 get-balance account)))
    )
      user-wallet
    )
  )
)

```
