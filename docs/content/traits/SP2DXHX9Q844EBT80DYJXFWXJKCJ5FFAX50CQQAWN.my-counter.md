---
title: "Trait my-counter"
draft: true
---
```
(define-map counter principal uint)

(define-read-only (get-counter) (default-to u0 (map-get? counter contract-caller)))

(define-public (increment) 
    (let
        (
            (curr (default-to u0 (map-get? counter contract-caller)))
        ) 
        (map-set counter contract-caller (+ curr u1))
        (ok u1)
    )
)

(define-public (decrement) 
    (let
        (
            (curr (default-to u0 (map-get? counter contract-caller)))
        ) 
        (asserts! (>= curr u0) (err 406))
        (map-set counter contract-caller (- curr u1))
        (ok u1)
    )
)
```
