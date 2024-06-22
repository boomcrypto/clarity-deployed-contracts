---
title: "Trait rose-0524-9"
draft: true
---
```
;; test www
(define-constant sender 'SP3RQY2KAMTAAZWMAVEMFKC9QBX0MH91010MNBZ9E)


(define-public (test-hello-world)
  (begin
    (print "Event! Hello world")
    (ok u1)
  )
)


(begin (test-hello-world))


(define-public (test2)
  (begin
    (stx-get-balance tx-sender)
    (ok u1)
  )
)

(begin (test2))

```
