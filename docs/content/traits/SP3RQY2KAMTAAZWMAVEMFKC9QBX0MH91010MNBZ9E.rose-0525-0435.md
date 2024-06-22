---
title: "Trait rose-0525-0435"
draft: true
---
```
;; test www
(use-trait sip-trait .sip-010-trait-ft-standard.sip-010-trait)
(define-constant owner tx-sender)


(define-public (transfer-usda (a0 uint))
  (let
    (
      (sender tx-sender)
    )
    (match (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer a0 sender owner none)
      successValue (ok successValue)  
      errorValue (err errorValue)     
    )
  )
)



(define-read-only (getdy)
  (let
    (
        (pair (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 get-pair-data 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2) (err "no-pair-data")))
        (current-balance-x (get balance-x pair))
        (current-balance-y (get balance-y pair))
        (x-decimals (get x-decimals pair))
        (y-decimals (get y-decimals pair))
    )
    (ok pair)
  )

)

```
