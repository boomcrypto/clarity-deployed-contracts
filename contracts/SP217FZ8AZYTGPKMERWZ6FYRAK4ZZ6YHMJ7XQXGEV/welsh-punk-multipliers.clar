(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)

(define-data-var multipliers uint u10000)

(define-public (change-multipliers (new-multipliers uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-AUTHORIZED))
        (var-set multipliers new-multipliers)
        (ok new-multipliers)
    )
)

(define-read-only (lookup (uid uint))
    (ok (var-get multipliers))
)