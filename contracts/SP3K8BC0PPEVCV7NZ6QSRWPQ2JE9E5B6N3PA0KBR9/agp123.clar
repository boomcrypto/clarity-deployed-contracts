(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .alex-vault add-approved-flash-loan-user .flash-loan-user-xusd-to-usda-v1-01))
        (ok true)
    )
)