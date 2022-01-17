(define-fungible-token Milky-Way)

(define-data-var total-supply uint u0)

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-private (mint! (account principal) (amount uint))
  (if (<= amount u0)
      (err u0)
      (begin
        (var-set total-supply (+ (var-get total-supply) amount))
        (ft-mint? Milky-Way amount account))))


(define-public (transfer (to principal) (amount uint)) 
  (if 
    (> (ft-get-balance Milky-Way tx-sender) u0)
    (ft-transfer? Milky-Way amount tx-sender to)
    (err u0)))

(mint! 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS u60000000000000)
(mint! 'SP13VH72MJJAZGWVH8XBR8SBZ00S81A3ZWBR9DPDA u60000000000000)

