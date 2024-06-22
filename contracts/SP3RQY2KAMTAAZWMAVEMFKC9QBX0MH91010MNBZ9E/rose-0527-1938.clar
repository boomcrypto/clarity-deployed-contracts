;; test www
(define-constant owner tx-sender)




(define-public (tx-test)
  (let
   (
    (sender tx-sender)
   )
   (begin
    (print sender)
    (print tx-sender)
    (as-contract (print tx-sender))
    (ok true)
   )
  )
)