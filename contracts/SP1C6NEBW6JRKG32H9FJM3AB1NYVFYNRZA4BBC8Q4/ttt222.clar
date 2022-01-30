
(define-public (send-test (amount uint)) 
    (begin
        (unwrap-panic (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (ok true)
    )
)