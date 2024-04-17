;; Transfer tokens to a single recipient
(define-private (transfer-token (recipient { to: principal, uamount: uint }))
  (let ((to (get to recipient))
        (uamount (get uamount recipient)))
    (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr transfer uamount tx-sender to none)
  )
)

;; Helper function to check for errors
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior
    ok-value result
    err-value (err err-value)
  )
)

;; Public function to send tokens to multiple recipients
(define-public (send-many (recipients (list 200 { to: principal, uamount: uint })))
  (fold check-err
        (map transfer-token recipients)
        (ok true)
  )
)