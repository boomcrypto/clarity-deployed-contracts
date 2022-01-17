(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u0)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
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