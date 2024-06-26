(define-public (register-user-many-strict (users (list 1000 principal)))
    (fold check-err (map register-user users) (ok true)))
(define-public (register-user-many (users (list 1000 principal)))
    (ok (map register-user users)))
(define-public (register-user (user principal))
    (match (contract-call? .cross-bridge-endpoint-v1-03 register-user user)
        ok-value (ok true)
        err-value (err err-value)))
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))