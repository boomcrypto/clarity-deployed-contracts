(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .alex-vault add-approved-token .token-susdt))
        (try! (contract-call? .amm-swap-pool set-max-in-ratio u50000000))
        (try! (contract-call? .amm-swap-pool set-max-out-ratio u50000000))
          
        (ok true)
    )
)