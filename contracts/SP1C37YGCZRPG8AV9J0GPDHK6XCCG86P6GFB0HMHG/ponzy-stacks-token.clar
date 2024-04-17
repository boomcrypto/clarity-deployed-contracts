(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token PONZY)

(define-read-only (get-name)
    (ok "PonzyStacks"))

(define-read-only (get-symbol)
    (ok "PONZY"))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance PONZY address)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply PONZY)))

(define-read-only (get-token-uri)
    (ok (some u"https://ipfs.io/ipfs/QmNY58GUng9euaEmZJtBo9hK7rYzgXzp7muAFwiearYvRF")))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err u4))
        (print (default-to 0x memo))
        (ft-transfer? PONZY amount from to)))

(define-private (sm (receiver { to: principal, amount: uint }))
    (is-err (ft-transfer? PONZY (get amount receiver) tx-sender (get to receiver))))

(define-public (send-many (recipients (list 3000 { to: principal, amount: uint })))
    (begin
        (asserts! (is-eq (len (filter sm recipients)) u0) (err u5))
        (ok true)))

(ft-mint? PONZY u1000000000000000 tx-sender)