---
title: "Trait rose-0527-2339"
draft: true
---
```
;; test www
(define-constant owner tx-sender)
(define-constant ERR-ONE u101)
(define-constant ERR-TWO u102)
(define-constant ERR-NOT-OWNER u200)


(define-public (swap-x-for-y (dx uint)) 
  (begin
    (asserts! (is-eq tx-sender owner) (err ERR-NOT-OWNER)) ;; ok

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

            (a2 (unwrap-panic (contract-call?
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-x-for-y
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
                b1
                u0
            )))

          )
          (ok a2)
        )
      
      
    )
  )
)

```
