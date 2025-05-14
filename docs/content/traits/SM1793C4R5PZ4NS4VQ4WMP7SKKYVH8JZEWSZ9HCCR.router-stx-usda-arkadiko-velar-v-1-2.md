---
title: "Trait router-stx-usda-arkadiko-velar-v-1-2"
draft: true
---
```

;; router-stx-usda-arkadiko-velar-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))

(define-read-only (get-quote-a
    (amount uint) (provider (optional principal))
    (id uint) (reversed bool)
    (swap-fee (tuple (num uint) (den uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   amount-after-aggregator-fees
                   r0 r1
                   swap-fee)))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dy
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                           quote-a)))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-b
    (amount uint) (provider (optional principal))
    (id uint) (reversed bool)
    (swap-fee (tuple (num uint) (den uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dx
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                           'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                           amount-after-aggregator-fees)))
    (quote-b (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library get-amount-out
                   quote-a
                   r0 r1
                   swap-fee)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-in provider amount)))
    (swap-a (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to amount-after-aggregator-fees) ERR_SWAP_A))
    (swap-b (unwrap! (arkadiko-a swap-a) ERR_SWAP_B))
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
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token provider amount)))
    (swap-a (unwrap! (arkadiko-b amount-after-aggregator-fees) ERR_SWAP_A))
    (swap-b (unwrap! (velar-a id token0 token1 token-in token-out share-fee-to swap-a) ERR_SWAP_B))
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

(define-private (arkadiko-a (dx uint))
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                  dx u1)))
  )
    (ok (default-to u0 (element-at? swap-a u1)))
  )
)

(define-private (arkadiko-b (dy uint))
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                  dy u1)))
  )
    (ok (default-to u0 (element-at? swap-a u0)))
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
