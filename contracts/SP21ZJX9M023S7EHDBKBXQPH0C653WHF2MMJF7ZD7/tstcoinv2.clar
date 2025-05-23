(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-UNTHRZD u1)
(define-constant ERR-INSFNT u2)

(define-fungible-token tstcoinv2)
(define-constant contract-creator tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNTHRZD))

        (ft-transfer? tstcoinv2 amount from to)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (if 
        (is-eq tx-sender contract-creator) 
            (ok (var-set token-uri (some value))) 
        (err ERR-UNTHRZD)
    )
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(define-read-only (get-name)
    (ok "tstcoinv2")
)

(define-read-only (get-symbol)
    (ok "TSTV2")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance tstcoinv2 user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply tstcoinv2)
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(begin
  (try! (ft-mint? tstcoinv2 u10000000000000 contract-creator)) 
)