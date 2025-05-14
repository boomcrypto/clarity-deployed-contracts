---
title: "Trait curve-fees-dummy_v1_0_0"
draft: true
---
```
;; (use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(impl-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)

(define-public (receive (a bool) (b uint)) (ok false))
(define-public (init (a principal)) (ok false))

(define-constant FEES {
  swap-fee     : {num: u1, den: u1},
  protocol-fee : {num: u1, den: u1},
})

(define-read-only (calc-fees
  (amt-in uint))
  (ok {
    amt-in-adjusted : amt-in,
    amt-fee-lps     : u0,
    amt-fee-protocol: u0,
    }
  ))

(define-read-only (get-fees) (ok FEES))
(define-read-only (do-get-fees) FEES)

```
