(define-fungible-token test)

(define-public (test-emit-event)
  (begin
    (print "ok, going fuck fight!")
    (ok u1)
  )
)

;; Adding three methods with empty bodies
(define-public (method-one)
  (begin
    ;; Empty body
    (ok u1)
  )
)

(define-public (method-two)
  (begin
    ;; Empty body
    (ok u1)
  )
)

(define-public (method-three)
  (begin
    ;; Empty body
    (ok u1)
  )
)
