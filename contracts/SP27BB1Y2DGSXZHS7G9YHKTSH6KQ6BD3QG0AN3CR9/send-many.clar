;; send-many-token
(define-private (send-vibes (recipient { to: principal, ustx: uint, memo: (optional (buff 34)) }))
      (contract-call? 
        'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token 
        transfer 
        (get ustx recipient) 
        tx-sender 
        (get to recipient) 
        (get memo recipient)
      )
)

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))
(define-public (send-many (recipients (list 200 { to: principal, ustx: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-vibes recipients)
    (ok true)))