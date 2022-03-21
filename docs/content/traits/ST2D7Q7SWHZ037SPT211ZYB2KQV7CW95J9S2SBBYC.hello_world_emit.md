---
title: "Trait hello_world_emit"
draft: true
---
```
(define-public (say-hi) (ok "hello world!"))
(define-public (emit-hi)
    (begin
        (print "hello world!")
        (ok true)
    )
)
(define-read-only (echo-number (val int)) (ok val))

```
