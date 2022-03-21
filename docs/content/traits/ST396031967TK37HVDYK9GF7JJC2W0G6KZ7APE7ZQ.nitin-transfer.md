---
title: "Trait nitin-transfer"
draft: true
---
```
;;stx transfer
(define-constant ERR-NOT-OWNER (err u403)) ;; Forbidden
;;bussiness logic
(define-public (transfer (sender principal) (recipient principal)) 
    (begin
;;validation
    ;; (as-contract tx-sender)
    (asserts! (is-eq tx-sender sender) ERR-NOT-OWNER)
    (as-contract
        (stx-transfer? u60 tx-sender recipient))))
    
;;tx-sender details   
(define-public (details)   
    (ok (as-contract tx-sender)))
```
