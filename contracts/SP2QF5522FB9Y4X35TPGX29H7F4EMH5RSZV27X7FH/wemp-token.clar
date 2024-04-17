(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; WARNING: Extremely meme token!

(define-constant ERR-UNAUTHORIZED (err u401))
(define-fungible-token WelshMarioPizzaParty69Inu)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://bafybeihjkfasqpnvlyz3awlksesciabitrjmj5gby5ya2kq3tfrlvyrbqy.ipfs.dweb.link/QmXMhrrkaFJVtbqmjuHwEZLLnN8o6qqWYmDfVEnJVNkYJ2"))
(define-constant contract-creator tx-sender)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED)
        (ft-transfer? WelshMarioPizzaParty69Inu amount from to)
    )
)

(define-read-only (get-name)
    (ok "WelshMarioPizzaParty69Inu")
)

(define-read-only (get-symbol)
    (ok "WEMP")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance WelshMarioPizzaParty69Inu user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply WelshMarioPizzaParty69Inu)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender contract-creator) ERR-UNAUTHORIZED)
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (send-many (recipients (list 1000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(begin
  (try! (ft-mint? WelshMarioPizzaParty69Inu u42420000000000000 contract-creator))
)