---
title: "Trait aimkt-base-bootstrap-initialization"
draft: true
---
```
(impl-trait 'SPTWD9SPRQVD3P733V89SV0P8RZRZNQADJHHPME1.aibtcdev-dao-traits-v1.proposal)

(define-constant DAO_MANIFEST "This is where the dao manifest would go")

(define-public (execute (sender principal))
  (begin  
    ;; set initial extensions
    (try! (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-base-dao set-extensions
      (list
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-action-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-bank-account, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-core-proposals, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-onchain-messaging, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-payments-invoices, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-token-owner, enabled: true}
        {extension: 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.aimkt-treasury, enabled: true}
      )
    ))
    ;; print manifest
    (print DAO_MANIFEST)
    (ok true)
  )
)

(define-read-only (get-dao-manifest)
  DAO_MANIFEST
)

```
