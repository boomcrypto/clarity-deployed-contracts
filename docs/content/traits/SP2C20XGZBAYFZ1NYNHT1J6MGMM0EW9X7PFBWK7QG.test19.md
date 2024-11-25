---
title: "Trait test19"
draft: true
---
```
;; Hello World smart contract

;; Public function that returns "Hello World!"
(define-public (say-hello)
    (ok "Hello World!")
)

;; Read-only function that returns "Hello World!"
(define-read-only (get-hello)
    "Hello World!"
)
```
