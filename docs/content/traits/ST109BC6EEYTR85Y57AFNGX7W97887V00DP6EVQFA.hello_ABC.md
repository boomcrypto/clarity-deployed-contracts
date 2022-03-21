---
title: "Trait hello_ABC"
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

(define-public (emit-sender)
    (begin
        (print (as-contract tx-sender))
        (print tx-sender)
        (ok true)
    )
)

(define-public (emit-check)
    (begin 
        (print {user: tx-sender, sss: "abc"}) 
        (ok true)
    )
)

(define-public (emit)
    (begin 
        (print {
            user: tx-sender,
            temp: (as-contract tx-sender),
            sss: "abc"
        })
        (ok true)
    )
)

(define-read-only (echo-number (val int)) (ok val))

```
