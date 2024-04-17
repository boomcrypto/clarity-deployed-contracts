(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token DOGE)

(define-read-only (get-name)
    (ok "Doge"))

(define-read-only (get-symbol)
    (ok "DOGE"))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance DOGE address)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply DOGE)))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreihtdoq5kwg2k5k2hsswpjrat3erqros5b6i7rcfxnyhzsspwknlku")))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err u4))
        (print (default-to 0x memo))
        (ft-transfer? DOGE amount from to)))

(define-private (sm (receiver { to: principal, amount: uint }))
    (is-err (ft-transfer? DOGE (get amount receiver) tx-sender (get to receiver))))

(define-public (send-many (recipients (list 3000 { to: principal, amount: uint })))
    (begin
        (asserts! (is-eq (len (filter sm recipients)) u0) (err u5))
        (ok true)))

(ft-mint? DOGE u1000000000000000 tx-sender)