---
title: "Trait router-velar-alex-v-1-3"
draft: true
---
```

;; router-velar-alex-v-1-3

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))
(define-constant ERR_SCALED_AMOUNT_A (err u6001))
(define-constant ERR_QUOTE_A (err u7001))
(define-constant ERR_QUOTE_B (err u7002))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qa amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qa scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qa amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qa scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qa amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qa scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qa amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qa scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-e
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qb amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qb scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-f
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qb amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qb scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-g
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qb amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qb scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-h
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qb amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qb scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-i
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qc amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qc scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-j
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qc amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qc scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-k
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qc amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qc scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-l
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qc amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qc scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-m
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qd amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qd scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-n
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qd amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qd scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-o
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qd amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qd scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-p
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qd amount-after-aggregator-fees v-tokens) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount-after-aggregator-fees a-tokens a-factors) ERR_QUOTE_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount quote-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount quote-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount a-tokens a-factors) ERR_QUOTE_B)
                 (unwrap! (velar-qd scaled-amount v-tokens) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-c
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-c",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-d
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get b v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-d",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-e
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-e",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-f
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-f",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-g
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-g",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-h
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get c v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-h",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-i
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-i",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-j
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-j",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-k
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-k",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-l
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get d v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-l",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-m
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get b a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-m",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-n
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get c a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-n",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-o
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get d a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-o",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-p
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-tokens) (get a a-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount-after-aggregator-fees v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount-after-aggregator-fees a-tokens a-factors) ERR_SWAP_A)))
    (scaled-amount (if (is-eq swaps-reversed false)
                       (unwrap! (scale-velar-amount swap-a (get e v-tokens) (get a a-tokens)) ERR_SCALED_AMOUNT_A)
                       (unwrap! (scale-alex-amount swap-a (get e a-tokens) (get a v-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd scaled-amount v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-p",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (velar-qa
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 amount-out
             amount
             (get a tokens) (get b tokens)))
  )
    (ok quote-a)
  )
)

(define-private (velar-qb
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-3
             amount
             (get a tokens) (get b tokens) (get c tokens)))
  )
    (ok (get c quote-a))
  )
)

(define-private (velar-qc
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-4
             amount
             (get a tokens) (get b tokens) (get c tokens) (get d tokens)
             (list u1 u2 u3 u4)))
  )
    (ok (get d quote-a))
  )
)

(define-private (velar-qd
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-5
             amount
             (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)))
  )
    (ok (get e quote-a))
  )
)

(define-private (alex-qa
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (contract-of a-token) (contract-of b-token)
                           (get a factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qb
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (get a factors) (get b factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qc
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (d-token (get d tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (contract-of d-token)
                           (get a factors) (get b factors) (get c factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qd
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (d-token (get d tokens))
    (e-token (get e tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (contract-of d-token) (contract-of e-token)
                           (get a factors) (get b factors) (get c factors) (get d factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (velar-sa
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap
                  amount
                  (get a tokens) (get b tokens)
                  share-fee-to)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-private (velar-sb
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get c swap-a)))
  )
)

(define-private (velar-sc
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get d swap-a)))
  )
)

(define-private (velar-sd
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get e swap-a)))
  )
)

(define-private (alex-sa
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  (get a tokens) (get b tokens)
                  (get a factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sb
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  (get a tokens) (get b tokens) (get c tokens)
                  (get a factors) (get b factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sc
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  (get a factors) (get b factors) (get c factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sd
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                  (get a factors) (get b factors) (get c factors) (get d factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (scale-velar-amount (amount uint) (v-token <v-ft-trait>) (a-token <a-ft-trait>))
  (let (
    (v-decimals (unwrap-panic (contract-call? v-token get-decimals)))
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (scaled-amount
      (if (is-eq v-decimals a-decimals)
        amount
        (if (> v-decimals a-decimals)
          (/ amount (pow u10 (- v-decimals a-decimals)))
          (* amount (pow u10 (- a-decimals v-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-alex-amount (amount uint) (a-token <a-ft-trait>) (v-token <v-ft-trait>))
  (let (
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (v-decimals (unwrap-panic (contract-call? v-token get-decimals)))
    (scaled-amount
      (if (is-eq a-decimals v-decimals)
        amount
        (if (> a-decimals v-decimals)
          (/ amount (pow u10 (- a-decimals v-decimals)))
          (* amount (pow u10 (- v-decimals a-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
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
