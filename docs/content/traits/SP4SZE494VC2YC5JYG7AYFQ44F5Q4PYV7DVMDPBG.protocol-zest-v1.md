---
title: "Trait protocol-zest-v1"
draft: true
---
```
;; @contract Supported Protocol - Zest
;; @version 1

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Arkadiko 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2 get-balance user)
)

```
