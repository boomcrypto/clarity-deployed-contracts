(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Emo)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance Emo address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply Emo)))

(define-read-only (get-name)
  (ok "Emote"))

(define-read-only (get-symbol)
  (ok "Emo"))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (ok (asserts! (and (is-eq from tx-sender) (is-eq memo (print memo)) (try! (ft-transfer? Emo amount from to))) (err u101))))

(define-read-only (get-token-uri)
  (ok (some u"ipfs://ipfs/QmRAgPKoX2vE9CAZeCgZoEqeU5pFKca4oRgCtbivLCNUFF")))

(define-public (burn (count uint))
    (ft-burn? Emo count tx-sender))

(define-private (sd (receiver { to: principal, amount: uint }))
  (is-err (ft-transfer? Emo (get amount receiver) tx-sender (get to receiver))))

(define-public (send_many (recipients (list 5000 { to: principal, amount: uint })))
  (ok (asserts! (is-eq (len (filter sd recipients)) u0) (err u102))))

(ft-mint? Emo u21000000000000 tx-sender)