(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)

(define-public (pay (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH))
                (ok true)
        )
        (ok true)
    )
)

(define-public (set-commission (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission amount)
        (ok true)
    )
)

(define-public (get-commission)
    (ok (var-get commission))
)