

(define-public (mint-many (addresses (list 1000 principal)))
    (begin
        (print (map mint addresses))
        (ok true)
    )
)

(define-private (mint (address principal))
    (contract-call? .bitcoin-monkeys-coupon-15pc mint address)
)