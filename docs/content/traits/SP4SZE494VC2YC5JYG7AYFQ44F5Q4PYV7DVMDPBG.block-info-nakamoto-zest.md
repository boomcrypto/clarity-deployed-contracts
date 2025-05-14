---
title: "Trait block-info-nakamoto-zest"
draft: true
---
```
;;-------------------------------------
;; Zest
;;-------------------------------------

(define-read-only (get-user-zest (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u140111)
      (ok u0)
      (if (< block u143343)
        (at-block block-hash (get-user-zest-helper-1 account))
        (if (< block u149387)
          (at-block block-hash (get-user-zest-helper-2 account))
          (if (< block u343280)
            (at-block block-hash (get-user-zest-helper-3 account))
            (at-block block-hash (get-user-zest-helper-4 account))
          )
        )
      )
    )
  )
)

(define-read-only (get-user-zest-helper-1 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx get-balance account)
)

(define-read-only (get-user-zest-helper-2 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-0 get-balance account)
)

(define-read-only (get-user-zest-helper-3 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2 get-balance account)
)

(define-read-only (get-user-zest-helper-4 (account principal))
  (ok (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-token get-balance account))
)

```
