---
title: "Trait rose-0525-0418"
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
    (match (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer a0 sender tx-sender none)
      successValue (ok successValue)  
      errorValue (err errorValue)     
    )
  )
)
```
