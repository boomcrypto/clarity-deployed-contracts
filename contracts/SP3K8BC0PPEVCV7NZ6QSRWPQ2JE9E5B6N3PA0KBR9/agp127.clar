(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .alex-vault add-approved-token .token-wdiko))
        (ok true)
    )
)