(define-constant shit-creator tx-sender)
(define-data-var token-uri (string-utf8 265) u"")
(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-YOU-POOR u2)
(define-fungible-token shit)
(define-data-var total-supply uint u0)

(define-private (is-creator) (is-eq tx-sender shit-creator))

(define-private (increase-supply (increment uint)) 
  (var-set total-supply (+ (var-get total-supply) increment)))

(define-private (mint-shit (amount uint) (recipient principal)) 
  (let ((amount-in-ushit (* amount u1000000))) 
    (if
      (is-ok (ft-mint? shit amount-in-ushit recipient)) 
        (begin 
          (ok (increase-supply amount-in-ushit)))
      (err ERR-YOU-POOR))))

;; taking a shit would cost 1/1000 STX
;; shit ain't free now is it
(define-private (burn (stx-to-burn uint)) 
  (is-ok (stx-burn? (* stx-to-burn u1000) tx-sender)))


(define-public (give-a-shit (shits-to-give uint) (shits-given-to principal)) 
  (if 
    (is-ok 
      (transfer shits-to-give tx-sender shits-given-to))
      (begin 
        (print tx-sender)
        (print "gives a shit about")
        (print shits-given-to)
        (ok true)
      )
    (err ERR-YOU-POOR)))

(define-public (take-a-shit (how-big-a-shit uint))
  (if (burn how-big-a-shit) (mint-shit how-big-a-shit tx-sender) (err ERR-YOU-POOR)))

(define-public (transfer (amount uint) (from principal) (to principal))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))

        (ft-transfer? shit amount from to)
    )
)

(define-public (set-token-uri (uri (string-utf8 265))) 
  (if (is-creator) 
    (ok (var-set token-uri uri))
    (err ERR-UNAUTHORIZED)))


(define-read-only (get-name)
    (ok "shit"))

(define-read-only (get-symbol)
    (ok "SHT"))

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-balance-of (user principal))
    (ok (ft-get-balance shit user)))

(define-read-only (get-total-supply)
    (ok (var-get total-supply)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

