---
title: "Trait swap-helper"
draft: true
---
```
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-public (swap
  (amount-in uint)
  (maybe-amount-out-min (optional uint))
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (maybe-factor (optional uint))
  (maybe-velar-data (
    optional {
      id: uint,
      token-in: <ft-trait>,
      token-out: <ft-trait>,
      share-fee-to: <share-fee-to-trait>
    }
  ))
)
  (match maybe-velar-data velar-data
    (match maybe-amount-out-min amount-out-min
      (ok (try! (swap-with-velar
        (get id velar-data)
        token0
        token1
        (get token-in velar-data)
        (get token-out velar-data)
        (get share-fee-to velar-data)
        amount-in
        amount-out-min
      )))
      (err u2)
    )
    (match maybe-factor factor
      (ok (try! (swap-with-alex
        token0
        token1
        factor
        amount-in
        maybe-amount-out-min
      )))
      (err u1)
    )
  )
)

(define-private (swap-with-velar
  (id uint)
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (token-in <ft-trait>)
  (token-out <ft-trait>)
  (share-fee-to <share-fee-to-trait>)
  (amt-in uint)
  (amt-out-min uint)
)
  (let
    (
      (result
        (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
          id
          token0
          token1
          token-in
          token-out
          share-fee-to
          amt-in
          amt-out-min
        )))
      )
    )
    (ok (get amt-out result))
  )
)

(define-private (swap-with-alex
    (token-x-trait <ft-trait>)
    (token-y-trait <ft-trait>)
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
