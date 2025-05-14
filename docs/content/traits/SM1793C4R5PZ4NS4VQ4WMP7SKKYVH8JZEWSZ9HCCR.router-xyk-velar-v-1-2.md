---
title: "Trait router-xyk-velar-v-1-2"
draft: true
---
```

;; router-xyk-velar-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (pool-trait <xyk-pool-trait>)
    (xyk-reversed bool)
    (id uint)
    (swap-fee (tuple (num uint) (den uint)))
    (velar-reversed bool)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq xyk-reversed false)
                 (try! (contract-call? pool-trait get-dy amount-after-aggregator-fees))
                 (try! (contract-call? pool-trait get-dx amount-after-aggregator-fees))))
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq velar-reversed false)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (r1 (if (is-eq velar-reversed false)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (quote-b (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   quote-a
                   r0 r1
                   swap-fee)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (pool-trait <xyk-pool-trait>)
    (xyk-reversed bool)
    (id uint)
    (swap-fee (tuple (num uint) (den uint)))
    (velar-reversed bool)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq velar-reversed false)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (r1 (if (is-eq velar-reversed false)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (quote-a (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   amount-after-aggregator-fees
                   r0 r1
                   swap-fee)))
    (quote-b (if (is-eq xyk-reversed false)
                 (try! (contract-call? pool-trait get-dy quote-a))
                 (try! (contract-call? pool-trait get-dx quote-a))))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <ft-trait>) (y-token-trait <ft-trait>)
    (xyk-reversed bool)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (aggregator-fee-token (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq xyk-reversed false)
                (unwrap! (xyk-a pool-trait x-token-trait y-token-trait amount-after-aggregator-fees) ERR_SWAP_A)
                (unwrap! (xyk-b pool-trait x-token-trait y-token-trait amount-after-aggregator-fees) ERR_SWAP_A)))
    (swap-b (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: caller, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          pool-trait: (contract-of pool-trait),
          x-token-trait: (contract-of x-token-trait),
          y-token-trait: (contract-of y-token-trait),
          xyk-reversed: xyk-reversed,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <ft-trait>) (y-token-trait <ft-trait>)
    (xyk-reversed bool)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-in provider amount)))
    (swap-a (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to amount-after-aggregator-fees) ERR_SWAP_A))
    (swap-b (if (is-eq xyk-reversed false)
                (unwrap! (xyk-a pool-trait x-token-trait y-token-trait swap-a) ERR_SWAP_B)
                (unwrap! (xyk-b pool-trait x-token-trait y-token-trait swap-a) ERR_SWAP_B)))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: caller, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          pool-trait: (contract-of pool-trait),
          x-token-trait: (contract-of x-token-trait),
          y-token-trait: (contract-of y-token-trait),
          xyk-reversed: xyk-reversed,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (xyk-a
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <ft-trait>) (y-token-trait <ft-trait>)
    (x-amount uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-x-for-y
                  pool-trait
                  x-token-trait y-token-trait
                  x-amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (xyk-b
    (pool-trait <xyk-pool-trait>)
    (x-token-trait <ft-trait>) (y-token-trait <ft-trait>)
    (y-amount uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                  pool-trait
                  x-token-trait y-token-trait
                  y-amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (velar-a
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (amt-in uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
                  id 
                  token0 token1
                  token-in token-out
                  share-fee-to
                  amt-in u1)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-private (get-aggregator-fees (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.aggregator-core-v-1-1 get-aggregator-fees
                  (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)

(define-private (transfer-aggregator-fees (token <ft-trait>) (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.aggregator-core-v-1-1 transfer-aggregator-fees
                  token (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)
```
