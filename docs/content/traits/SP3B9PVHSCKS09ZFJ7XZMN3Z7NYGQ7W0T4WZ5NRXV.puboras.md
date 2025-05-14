---
title: "Trait puboras"
draft: true
---
```

  (define-trait ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-trait sft-trait
  (
    (transfer (uint uint principal principal) (response bool uint))
  )
)

(define-public (send-token-with-lp 
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <sft-trait>) (amount2 uint) (tokenid uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer tokenid amount2 tx-sender recipient))
    (ok true)
  )
)

(define-public (send-multiple-token-by-token 
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <ft-trait>) (amount2 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer amount2 tx-sender recipient none))
    (ok true)
  )
)

(define-public (send-multiple-three-tokens
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <ft-trait>) (amount2 uint)
                (token3 <ft-trait>) (amount3 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer amount2 tx-sender recipient none))
    (try! (contract-call? token3 transfer amount3 tx-sender recipient none))
    (ok true)
  )
)

(define-public (send-multiple-four-tokens
                (token1 <ft-trait>) (amount1 uint) 
                (token2 <ft-trait>) (amount2 uint)
                (token3 <ft-trait>) (amount3 uint)
                (token4 <ft-trait>) (amount4 uint)
                (recipient principal))
  (begin
    (try! (contract-call? token1 transfer amount1 tx-sender recipient none))
    (try! (contract-call? token2 transfer amount2 tx-sender recipient none))
    (try! (contract-call? token3 transfer amount3 tx-sender recipient none))
    (try! (contract-call? token4 transfer amount4 tx-sender recipient none))
    (ok true)
  )
)
  
```
