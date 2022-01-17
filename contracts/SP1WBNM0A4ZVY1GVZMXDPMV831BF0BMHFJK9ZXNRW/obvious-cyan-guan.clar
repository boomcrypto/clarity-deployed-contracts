(define-public (join-pool (ustx uint) (to principal) (memo (buff 34)))
 (let ((transfer-ok (try! (stx-transfer? ustx tx-sender to))))
   (print memo)
   (ok transfer-ok)))