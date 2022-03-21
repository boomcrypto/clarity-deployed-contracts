---
title: "Trait mint-many-4"
draft: true
---
```


(define-public (mint-many (addresses (list 1000 principal)))
    (begin
        (print (map mint addresses))
        (ok true)
    )
)

(define-private (mint (address principal))
    (contract-call? .bitcoin-monkeys-coupon-custom mint address)
)
```
