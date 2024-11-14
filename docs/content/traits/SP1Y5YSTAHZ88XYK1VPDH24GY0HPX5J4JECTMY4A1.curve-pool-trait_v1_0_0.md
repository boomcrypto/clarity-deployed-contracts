---
title: "Trait curve-pool-trait_v1_0_0"
draft: true
---
```
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait .curve-lp-token-trait_v1_0_0.curve-lp-token-trait)
(use-trait fees-trait     .curve-fees-trait_v1_0_0.curve-fees-trait)

(define-trait curve-pool-trait
  (
    (mint     (<ft-trait> <ft-trait> <lp-token-trait> uint uint)
      (response
          {op:   (string-ascii 32),
            user:  principal,
            pool:
              {;;id:  uint,
              symbol:       (string-ascii 32),
              token0:       principal,
              token1:       principal,
              lp-token:     principal,
              fees:         principal,
              A:            uint,
              reserve0:     uint,
              reserve1:     uint,
              block-height: uint,
              burn-block-height: uint,
              },
          amt0: uint,
          amt1: uint,
          liquidity: uint,
          total-supply: uint,
          }
        uint)
    )
    (burn     (<ft-trait> <ft-trait> <lp-token-trait> uint)
      (response
          {op:   (string-ascii 32),
            user:  principal,
            pool: {
              symbol:       (string-ascii 32),
              token0:       principal,
              token1:       principal,
              lp-token:     principal,
              fees:         principal,
              A:            uint,
              reserve0:     uint,
              reserve1:     uint,
              block-height: uint,
              burn-block-height: uint,
              },
          amt0: uint,
          amt1: uint,
          liquidity: uint,
          total-supply: uint,
          }
        uint)
    )
    (swap     (<ft-trait> <ft-trait> <fees-trait> uint uint)
      (response
       {op:   (string-ascii 32),
       user:  principal,
       pool: {
       symbol:       (string-ascii 32),
       token0:       principal,
       token1:       principal,
       lp-token:     principal,
       fees:         principal,
       A:            uint,
       reserve0:     uint,
       reserve1:     uint,
       block-height: uint,
       burn-block-height: uint,
       },
       amt-in          : uint,
       amt-out-desired : uint,
       amt-out         : uint,
       amt-in-adjusted : uint,
       amt-fee-lps     : uint,
       amt-fee-protocol: uint,
       }
        uint)
    )
    (get-pool ()
      (response
          {symbol:      (string-ascii 32),
          token0:       principal,
          token1:       principal,
          lp-token:     principal,
          fees:         principal,
          A:            uint,
          reserve0:     uint,
          reserve1:     uint,
          block-height: uint,
          burn-block-height: uint,
          }
        uint)
    )
    (init  (<ft-trait> <ft-trait> <lp-token-trait> <fees-trait> uint (string-ascii 32))
      (response
          {symbol:      (string-ascii 32),
          token0:       principal,
          token1:       principal,
          lp-token:     principal,
          fees:         principal,
          A:            uint,
          reserve0:     uint,
          reserve1:     uint,
          block-height: uint,
          burn-block-height: uint,
          }
        uint)
    )
  ))

;;; eof

```
