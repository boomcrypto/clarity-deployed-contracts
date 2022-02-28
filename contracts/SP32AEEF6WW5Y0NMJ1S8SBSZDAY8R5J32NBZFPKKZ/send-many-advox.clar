;; send-many
(define-public (send-stx-with-memo (ustx uint) (to principal) (memo (buff 68)))
 (let ((transfer-ok (try! (stx-transfer? ustx tx-sender to))))
   (print memo)
   (ok transfer-ok)))

(define-private (send-stx (recipient { to: principal, ustx: uint}))
  (let 
      ((ustx (get ustx recipient))
       (to (get to recipient))
       (transfer-ok (try! (stx-transfer? ustx tx-sender to))))
    (ok transfer-ok)))

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, ustx: uint })) (memo (buff 68)))
  (begin 
    (print memo)
    (fold check-err
      (map send-stx recipients)
      (ok true))))