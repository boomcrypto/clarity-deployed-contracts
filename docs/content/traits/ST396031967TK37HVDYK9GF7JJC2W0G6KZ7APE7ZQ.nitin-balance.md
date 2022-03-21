---
title: "Trait nitin-balance"
draft: true
---
```
;;balance

(define-read-only (test) 
    (ok (stx-get-balance (as-contract tx-sender)))
)
```
