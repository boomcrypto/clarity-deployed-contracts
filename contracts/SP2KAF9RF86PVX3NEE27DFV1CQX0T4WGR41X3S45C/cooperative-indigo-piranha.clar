
(define-public (unstack (ids (list 500 uint))) 
    (begin 
        (try! (flip false))
        (print (map do-contract-call ids))
        (try! (flip true))
        (ok true)
    )
)

(define-private (flip (switch bool))
    (contract-call? .bitcoin-monkeys-staking shutoff-switch switch)
)

(define-private (do-contract-call (id uint))
    (contract-call? .bitcoin-monkeys-staking admin-unstake .bitcoin-monkeys .bitcoin-monkeys id)
)