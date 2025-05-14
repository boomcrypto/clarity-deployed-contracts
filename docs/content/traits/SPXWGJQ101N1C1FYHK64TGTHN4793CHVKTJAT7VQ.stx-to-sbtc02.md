---
title: "Trait stx-to-sbtc02"
draft: true
---
```
(define-constant ERR-SWAP-FAILED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))

;;swap stx-stone 

(define-public (swap-stx-sbtc (stx-amount uint))
  (begin 
  (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)

  (let 
    (
      ;; Define the swap path
      (swap-path 
        (list
          (tuple 
            (a "v") 
            (b 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070) 
            (c u21000070) 
            (d 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) 
            (e 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token) 
            (f true)
          )
        )
      )    
    )
 
    
    ;; Swap STX to STONE using the specified path
    (let 
      (
        (swapped-event
          (asserts! 
          (is-ok  (contract-call? 
             'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging
              apply 
              swap-path 
              stx-amount 
              (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) 
              (some 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token) 
              none 
              none
              none 
              (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 
              (some 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070) 
              none
              none
              none
 
              (some 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070)
              none
              none
              none 

               none
               none
               none 
               none 

               none
               none 
               none 
               none 

              none 
              none 
              none 
              none 

               none
               none 
               none 
               none 
              
            ) )
            ERR-SWAP-FAILED
          )
        )
      )
      
      ;; Return the swapped token amount
      (ok swapped-event)
    )
  )
  )
)

```
