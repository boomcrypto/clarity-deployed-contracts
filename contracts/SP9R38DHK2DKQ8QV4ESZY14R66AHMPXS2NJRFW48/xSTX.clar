(define-fungible-token xSTX)

(define-data-var total-supply uint u0)

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? xSTX amount account))))


(define-public (transfer (to principal) (amount uint)) 
  (if 
    (> (ft-get-balance xSTX tx-sender) u0)
    (ft-transfer? xSTX amount tx-sender to)
    (err u0)))

(mint! 'SP9R38DHK2DKQ8QV4ESZY14R66AHMPXS2NJRFW48 u20000000000000)