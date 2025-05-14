---
title: "Trait gl-api"
draft: true
---
```

(use-trait ft-trait       'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)

(define-constant err-lock (err u701))

(define-private (call-get-decimals (token <ft-trait>))
  (unwrap-panic (contract-call? token get-decimals)))

(define-private
  (CONTEXT
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (desired      uint)
    (slippage     uint)
    (ctx          { ;; dia
                  symbol: (string-ascii 32),
                  }))
  (let ((base-decimals  (call-get-decimals base-token))
        (quote-decimals (call-get-decimals quote-token))
        (price          (try! (contract-call? .gl-oracle price quote-decimals desired slippage ctx))))

  (ok {
      price         : price,
      base-decimals : base-decimals,
      quote-decimals: quote-decimals,
      })))

(define-map LOCK principal uint)

(define-private (check-unlocked)
  (if (is-eq
        (default-to u0 (map-get? LOCK tx-sender))
        stacks-block-height)
    err-lock
    (ok true)
  ))

(define-private (lock)
  (begin
    (try! (check-unlocked))
    (ok (map-set LOCK  tx-sender stacks-block-height))))

(define-public
  (mint
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (lp-token     <lp-token-trait>)
    (base-amt     uint)
    (quote-amt    uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { symbol: (string-ascii 32) }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core mint u1 base-token quote-token lp-token base-amt quote-amt ctx)
    ))

(define-public
  (burn
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (lp-token    <lp-token-trait>)
    (lp-amt       uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { symbol: (string-ascii 32) }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core burn u1 base-token quote-token lp-token lp-amt ctx)
    ))

(define-public
  (open
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (long         bool)
    (collateral   uint)
    (leverage     uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { symbol: (string-ascii 32) }))

  (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
    (try! (lock))
     (contract-call? .gl-core open u1 base-token quote-token long collateral leverage ctx)
  ))

(define-public
  (close
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (position-id  uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { symbol: (string-ascii 32) }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core close u1 base-token quote-token position-id ctx)
    ))

(define-public
  (liquidate
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (position-id  uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { symbol: (string-ascii 32) }))

  (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
    (contract-call? .gl-core liquidate u1 base-token quote-token position-id ctx)
  ))

```
