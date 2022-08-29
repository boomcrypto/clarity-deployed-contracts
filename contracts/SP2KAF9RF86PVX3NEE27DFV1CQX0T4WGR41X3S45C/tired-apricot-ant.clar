(define-private (unstake (item uint))
    (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-staking admin-unstake item)
)

(define-public (unstake-all (items (list 2500 uint)))
    (begin
        (print (map unstake items))
        (ok true)
    )
)