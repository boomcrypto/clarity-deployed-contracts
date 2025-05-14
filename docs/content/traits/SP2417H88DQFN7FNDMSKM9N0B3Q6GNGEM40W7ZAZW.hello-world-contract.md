---
title: "Trait hello-world-contract"
draft: true
---
```

;; A read-only function that returns a message
(define-read-only (say-hi)
  (ok "Hello World")
)

;; A read-only function that returns an input number
(define-read-only (echo-number (val int))
  (ok val)
)
```
