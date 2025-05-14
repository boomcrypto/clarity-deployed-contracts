---
title: "Trait router-stableswap-xyk-multihop-v-1-1"
draft: true
---
```

;; router-stableswap-xyk-multihop-v-1-1

(use-trait ft-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait xyk-pool-trait .xyk-pool-trait-v-1-2.xyk-pool-trait)

(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_QUOTE_A (err u6012))
(define-constant ERR_QUOTE_B (err u6013))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-e
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-f
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-g
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-h
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-i
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? .xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
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
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? .xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? .stableswap-swap-helper-v-1-2 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (get-aggregator-fees (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  .aggregator-core-v-1-1 get-aggregator-fees
                  (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)

(define-private (transfer-aggregator-fees (token <ft-trait>) (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  .aggregator-core-v-1-1 transfer-aggregator-fees
                  token (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)
```
