(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .auto-alex set-contract-owner 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9))
        (ok true)
    )
)