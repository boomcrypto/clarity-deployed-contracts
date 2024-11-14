---
title: "Trait protocol-arkadiko-v1"
draft: true
---
```
;; @contract Supported Protocol - Arkadiko
;; @version 1

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Arkadiko 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (let (
    (vault (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1 get-vault user .ststx-token)))
  )
    ;; Check status
    (if (is-eq (get status vault) u101)
      (ok (get collateral vault))
      (ok u0)
    )
  )
)

```
