---
title: "Trait rose-0530-11"
draft: true
---
```
;; test www
(define-constant owner tx-sender)
(define-constant ERR-MIN-FAILED u101)
(define-constant ERR-NOT-OWNER u200)



(define-public (wl-v-a (in uint))
  (begin
    (let
      (
        (aa (stx-get-balance tx-sender)) 

        (b1 (try! (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
        u27
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
        in u1)))

        (b2 (try! (contract-call?
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
        (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
        u1 )))

        (ab (stx-get-balance tx-sender)) 
      )
      (asserts! (>= ab aa) (err (- aa ab)))
      (asserts! (is-eq tx-sender owner) (err u0))
      (ok (- ab aa))
    )
  )
)

(define-public (wl-a-v (in uint))
  (begin
    (let
      (
        (aa (stx-get-balance tx-sender)) 

        (b1 (try! (contract-call?
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
        in u1)))

        (b2 (try! (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
        u27
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
        (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) 
        u1 )))

        (ab (stx-get-balance tx-sender)) 
      )
      (asserts! (>= ab aa) (err (- aa ab)))
      (asserts! (is-eq tx-sender owner) (err u0))
      (ok (- ab aa))
    )
  )
)


















```
