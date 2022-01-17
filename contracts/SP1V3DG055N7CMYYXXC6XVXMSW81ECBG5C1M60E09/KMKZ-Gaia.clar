(define-fungible-token Kamikaze)

(define-data-var total-supply uint u0)

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? Kamikaze amount account))))


(define-public (transfer (to principal) (amount uint)) 
  (if 
    (> (ft-get-balance Kamikaze tx-sender) u0)
    (ft-transfer? Kamikaze amount tx-sender to)
    (err u0)))

(mint! 'SP1V3DG055N7CMYYXXC6XVXMSW81ECBG5C1M60E09 u1997)
