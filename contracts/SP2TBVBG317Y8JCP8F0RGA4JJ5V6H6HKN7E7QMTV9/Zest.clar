(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token Zest)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance Zest address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply Zest)))

(define-read-only (get-name)
  (ok "Zest"))

(define-read-only (get-symbol)
  (ok "ZEST"))

(define-read-only (get-decimals)
  (ok u6))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (ok (asserts! (and (is-eq from tx-sender) (is-eq memo (print memo)) (try! (ft-transfer? Zest amount from to))) (err u101))))

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmP9YLaiMtPBYJEPj8Hw51UPp4bTPQ8MxhvTs5d1mbuBbj")))

(define-public (burn (count uint))
    (ft-burn? Zest count tx-sender))

(define-private (send_to (receiver { to: principal, amount: uint }))
  (is-err (ft-transfer? Zest (get amount receiver) tx-sender (get to receiver))))

(define-public (multisend (recipients (list 5000 { to: principal, amount: uint })))
  (ok (asserts! (is-eq (len (filter send_to recipients)) u0) (err u102))))

(ft-mint? Zest u1000000000000000 tx-sender)