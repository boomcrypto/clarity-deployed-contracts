;; send-many
(define-public (send-stx-with-memo (ustx uint) (to principal) (memo (buff 34)))
 (let ((transfer-ok (try! (stx-transfer? ustx tx-sender to))))
   (print memo)
   (ok transfer-ok)))

(define-private (send-stx (recipient { to: principal, ustx: uint, memo: (buff 34) }))
  (send-stx-with-memo
     (get ustx recipient)
     (get to recipient)
     (get memo recipient)))

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, ustx: uint, memo: (buff 34) })))
  (fold check-err
    (map send-stx recipients)
    (ok true)))