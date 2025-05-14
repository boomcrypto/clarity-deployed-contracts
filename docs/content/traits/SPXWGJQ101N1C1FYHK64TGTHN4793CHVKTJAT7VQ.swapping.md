---
title: "Trait swapping"
draft: true
---
```
(define-constant ERR-SWAP-FAILED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))

;;swap stx-stone 

(define-public (swap-stx-for-sbtc (stx-amount uint))
  (begin 
    
    (asserts! (>= (stx-get-balance tx-sender) stx-amount) ERR-INSUFFICIENT-FUNDS)
    (let ((swap-result
           (contract-call? 
             'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
             swap
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
             'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
             'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070
             stx-amount
             u1
           )))
      (asserts! (is-ok swap-result) ERR-SWAP-FAILED)
      (let ((swap-event (unwrap! swap-result ERR-SWAP-FAILED)))
        (ok  swap-event)
      )
    )
  )
)
```
