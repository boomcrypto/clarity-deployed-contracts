(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-NOT-ENOUGH u2)

(define-fungible-token stacks)

(define-data-var token-uri (optional (string-utf8 256)) none)
(define-constant contract-creator tx-sender)

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))

        (ft-transfer? stacks amount from to)
    )
)

(define-read-only (get-name)
    (ok "STX")
)

(define-read-only (get-symbol)
    (ok "STX")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance stacks user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply stacks)
    )
)

(define-read-only (get-token-uri)
    (ok none)
)

(begin
  (try! (ft-mint? stacks u50000000000000 contract-creator)) 
)