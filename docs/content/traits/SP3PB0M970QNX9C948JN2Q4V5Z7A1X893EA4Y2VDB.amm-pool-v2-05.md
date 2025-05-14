---
title: "Trait amm-pool-v2-05"
draft: true
---
```
(use-trait nmb 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait) (use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait) (define-public (swap-helper-v1 (id0 uint) (idh uint) (id1 uint) (t00 <nmb>) (t0h <nmb>) (t0in <nmb>) (t0out <nmb>) (th0 <nmb>) (thh <nmb>) (thin <nmb>) (thout <nmb>) (t10 <nmb>) (t1h <nmb>) (t1in <nmb>) (t1out <nmb>) (li uint) (share-fee-to <share-fee-to-trait>) ) (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id1 t10 t1h t1in t1out share-fee-to (get amt-out (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens idh th0 thh thin thout share-fee-to (get amt-out (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id0 t00 t0h t0in t0out share-fee-to li u1))) u1))) li) )
```
