---
title: "Trait wispy-maroon-jay"
draft: true
---
```
;; wrapper-velar-multihop-v-1-1

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-public (swap-3
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3
                  amt-in amt-out-min
                  token-a token-b
                  token-c
                  share-fee-to)))
  )
    (ok swap-a)
  )
)

(define-public (swap-4
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4
                  amt-in amt-out-min
                  token-a token-b
                  token-c token-d
                  share-fee-to)))
  )
    (ok swap-a)
  )
)

(define-public (swap-5
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (token-e <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5
                  amt-in amt-out-min
                  token-a token-b
                  token-c token-d
                  token-e
                  share-fee-to)))
  )
    (ok swap-a)
  )
)
```
