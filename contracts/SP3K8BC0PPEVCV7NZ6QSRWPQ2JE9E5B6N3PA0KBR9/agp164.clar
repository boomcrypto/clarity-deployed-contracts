(impl-trait .proposal-trait.proposal-trait)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-public (execute (sender principal))
    (begin
        (try! (contract-call? .auto-alex set-start-block block-height))
        (try! (contract-call? .auto-alex set-end-cycle u142))
        (ok true)
    )
)