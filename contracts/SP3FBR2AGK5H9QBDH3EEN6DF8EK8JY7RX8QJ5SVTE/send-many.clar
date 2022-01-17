;; send-many
(define-private (send-stx (recipient { to: principal, ustx: uint }))
  (stx-transfer? (get ustx recipient) tx-sender (get to recipient)))
(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))
(define-public (send-many (recipients (list 200 { to: principal, ustx: uint })))
  (fold check-err
    (map send-stx recipients)
    (ok true)))