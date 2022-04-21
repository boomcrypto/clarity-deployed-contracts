;; send-many
(define-public (send-stsw-with-memo (ustsw uint) (to principal) (memo (buff 34)))
 (let ((transfer-ok (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer ustsw tx-sender to (some memo)))))
   (ok transfer-ok)))

(define-private (send-stsw (recipient { to: principal, ustsw: uint, memo: (buff 34) }))
  (send-stsw-with-memo
     (get ustsw recipient)
     (get to recipient)
     (get memo recipient)))

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))

(define-public (send-many (recipients (list 200 { to: principal, ustsw: uint, memo: (buff 34) })))
  (fold check-err
    (map send-stsw recipients)
    (ok true)))