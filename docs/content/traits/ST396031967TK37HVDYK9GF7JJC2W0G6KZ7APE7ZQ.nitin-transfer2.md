---
title: "Trait nitin-transfer2"
draft: true
---
```
(define-constant ERR-NOT-OWNER (err u403)) ;; Forbidden
;;bussiness logic
(define-public (transfer (sender principal) (recipient principal)) 
    (begin
;;validation
    ;; (as-contract tx-sender)
    (asserts! (is-eq tx-sender sender) ERR-NOT-OWNER)
        (stx-transfer? u1 tx-sender recipient)))
```
