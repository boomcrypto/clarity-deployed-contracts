(define-fungible-token something)

(define-data-var total-supply uint u0)

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? something amount account))))


(define-public (transfer (to principal) (amount uint)) 
  (if 
    (> (ft-get-balance something tx-sender) u0)
    (ft-transfer? something amount tx-sender to)
    (err u0)))

(mint! 'SP343J7DNE122AVCSC4HEK4MF871PW470ZSXJ5K66 u100000000000000)