---
title: "Trait swap-aggregator-v1-1"
draft: true
---
```
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait velar-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-VELAR-PARAMS (err u10))
(define-constant ERR-ALEX-PARAMS (err u11))

(define-public (swap
  (amount-in uint)
  (maybe-amount-out-min (optional uint))
  ;; (deadline uint)
  (maybe-alex-data (
    optional {
      token0: <alex-ft-trait>,
      token1: <alex-ft-trait>,
      factor: uint
    }
  ))
  (maybe-velar-data (
    optional {
      id: uint,
      token0: <velar-ft-trait>,
      token1: <velar-ft-trait>,
      token-in: <velar-ft-trait>,
      token-out: <velar-ft-trait>,
      share-fee-to: <share-fee-to-trait>
    }
  ))
)
  (match maybe-velar-data velar-data
    (match maybe-amount-out-min amount-out-min
      (ok (try! (swap-with-velar
        (get id velar-data)
        (get token0 velar-data)
        (get token1 velar-data)
        (get token-in velar-data)
        (get token-out velar-data)
        (get share-fee-to velar-data)
        amount-in
        amount-out-min
      )))
      ERR-VELAR-PARAMS
    )
    (match maybe-alex-data alex-data
      (ok (try! (swap-with-alex
        (get token0 alex-data)
        (get token1 alex-data)
        (get factor alex-data)
        amount-in
        maybe-amount-out-min
      )))
      ERR-ALEX-PARAMS
    )
  )
)

(define-private (swap-with-velar
  (id uint)
  (token0 <velar-ft-trait>)
  (token1 <velar-ft-trait>)
  (token-in <velar-ft-trait>)
  (token-out <velar-ft-trait>)
  (share-fee-to <share-fee-to-trait>)
  (amt-in uint)
  (amt-out-min uint)
)
  (let
    (
      (result
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
          id
          token0
          token1
          token-in
          token-out
          share-fee-to
          amt-in
          amt-out-min
        ))
      )
    )
    (ok (get amt-out result))
  )
)

(define-private (swap-with-alex
    (token-x-trait <alex-ft-trait>)
    (token-y-trait <alex-ft-trait>)
    (factor uint)
    (dx uint)
    (min-dy (optional uint))
  )
  (ok (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
    token-x-trait
    token-y-trait
    factor
    dx
    min-dy
  )))
)

```
