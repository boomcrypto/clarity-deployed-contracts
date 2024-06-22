---
title: "Trait rose-0528-0304"
draft: true
---
```
;; test www
(define-constant owner tx-sender)
(define-constant ERR-MIN-FAILED u101)
(define-constant ERR-NOT-OWNER u200)





(define-read-only (bitflow-get-dy (dx uint))
  (ok (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 get-dy 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 dx))
)



```
