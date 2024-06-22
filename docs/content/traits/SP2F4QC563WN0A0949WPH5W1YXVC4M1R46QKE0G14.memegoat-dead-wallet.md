---
title: "Trait memegoat-dead-wallet"
draft: true
---
```
;; MEMEGOAT DEAD WALLET
;; ANY TOKEN SENT HERE IS IRRECOVERABLE

(define-data-var contract-name (string-utf8 256) u"MEMEGOAT DEAD WALLET")

(define-read-only (get-contract-name)
  (ok (var-get contract-name))
)
```
