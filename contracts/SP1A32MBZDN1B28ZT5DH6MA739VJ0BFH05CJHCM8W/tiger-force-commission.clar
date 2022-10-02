(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u0)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin
                (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP1YN8WZ50C237MBJZ6GQD339NNZSKA55RJ9YZ9YQ))
                (ok true)
        )
        (ok true)
    )
)