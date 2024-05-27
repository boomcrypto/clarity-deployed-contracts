;; test www

(define-public (test-emit-event)
  (begin
    (print "Event! Hello world")
    (ok u1)
  )
)

(begin (test-emit-event))