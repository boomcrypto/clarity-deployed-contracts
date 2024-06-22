---
title: "Trait rose-0529-011"
draft: true
---
```
;; test www
(define-constant owner tx-sender)
(define-constant ERR-MIN-FAILED u101)
(define-constant ERR-NOT-OWNER u200)




(define-public (swap-stx-welsh-velar (dx uint))
  (let ((r (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router 
                                  swap-exact-tokens-for-tokens 
                                  u27 
                                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                                  'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
                                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
                                  'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
                                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
                                  dx 
                                  u0))))
    (ok (get amt-out r))
  )
)
```
