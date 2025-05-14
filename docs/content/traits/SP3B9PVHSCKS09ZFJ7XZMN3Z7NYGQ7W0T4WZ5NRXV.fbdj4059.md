---
title: "Trait fbdj4059"
draft: true
---
```

  (define-trait ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-trait lp-trait
  (
    (transfer (uint uint principal principal) (response bool uint))
  )
)

(define-public (send-token-with-lp 
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <lp-trait>) (amount2 uint) (tokenid uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (contract-call? token2 transfer tokenid amount2 tx-sender recipient)
  )
)

(define-public (send-multiple-token-by-token 
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <ft-trait>) (amount2 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (contract-call? token2 transfer amount2 tx-sender recipient none)
  )
)

  
```
