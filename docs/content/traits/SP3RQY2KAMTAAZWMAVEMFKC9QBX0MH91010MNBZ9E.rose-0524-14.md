---
title: "Trait rose-0524-14"
draft: true
---
```
;; test www



(define-public (test-hello-world)
  (begin
    (print "Event! Hello world")
    (ok u1)
  )
)


(begin (test-hello-world))


(define-public (stxgetbalance)
  (begin
    (stx-get-balance tx-sender)
    (ok u1)
  )
)

(begin (stxgetbalance))







```
