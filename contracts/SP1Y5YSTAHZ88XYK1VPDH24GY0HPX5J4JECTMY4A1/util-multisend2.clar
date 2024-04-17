(define-public
  (multisend
   (amt uint)
   (users (list 3000 principal)) )
  (ok (fold do-multisend users amt) ))

(define-private
  (do-multisend
   (user principal)
   (amt  uint))
  (begin
    (unwrap-panic (stx-transfer? amt tx-sender user))
    amt) )

(define-private (do-multisend-velar (entry { to: principal, amt: uint }))
  (is-err (contract-call? .velar-token transfer (get amt entry) tx-sender (get to entry) none)))

(define-public
  (multisend-velar
    (recipients (list 3000 { to: principal, amt: uint })))
  (ok (asserts! (is-eq (len (filter do-multisend-velar recipients)) u0)
                (err u101)) ))

;;; eof
