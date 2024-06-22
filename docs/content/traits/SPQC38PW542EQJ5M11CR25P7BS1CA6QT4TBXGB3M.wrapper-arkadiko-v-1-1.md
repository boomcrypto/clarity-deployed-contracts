---
title: "Trait wrapper-arkadiko-v-1-1"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (swap-x-for-y (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy uint))
  (let (
    (call (try! (contract-call?
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
          token-x-trait
          token-y-trait
          dx min-dy)))
  )
    (ok call)
  )
)

(define-public (swap-y-for-x (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dy uint) (min-dx uint))
  (let (
    (call (try! (contract-call?
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
          token-x-trait
          token-y-trait
          dy min-dx)))
  )
    (ok call)
  )
)
```
