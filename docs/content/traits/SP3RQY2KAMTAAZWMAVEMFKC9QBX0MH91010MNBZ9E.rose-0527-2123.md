---
title: "Trait rose-0527-2123"
draft: true
---
```
;; test www
(define-constant owner tx-sender)


(define-public (swap-x-for-y (dx uint)) 
  (begin
    (asserts! (is-eq tx-sender owner) (err u0))

    (as-contract
      (let
        (
          (a1 (unwrap-panic (contract-call?
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
                dx 
                u0
          )))

          (b1 (unwrap-panic (element-at a1 u1)))

        )

        (ok b1)
      )
    )

  )
)

```
