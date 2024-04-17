(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token BULL)

(define-read-only (get-name)
    (ok "Bull"))

(define-read-only (get-symbol)
    (ok "BULL"))

(define-read-only (get-decimals)
    (ok u0))

(define-read-only (get-balance (address principal))
    (ok (ft-get-balance BULL address)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply BULL)))

(define-read-only (get-token-uri)
    (ok (some u"ipfs://ipfs/bafkreiarvuvr23476z652gijncpns7kvpo7tyuu73reukxhkoywurs2rjq")))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err u4))
        (print (default-to 0x memo))
        (ft-transfer? BULL amount from to)))

(define-private (sm (receiver { to: principal, amount: uint }))
    (is-err (ft-transfer? BULL (get amount receiver) tx-sender (get to receiver))))

(define-public (send-many (recipients (list 5000 { to: principal, amount: uint })))
    (begin
        (asserts! (is-eq (len (filter sm recipients)) u0) (err u5))
        (ok true)))

(ft-mint? BULL u100000000 tx-sender)

(print "If u are bullish for Bitcoin, u should be bullish for Stacks.")
