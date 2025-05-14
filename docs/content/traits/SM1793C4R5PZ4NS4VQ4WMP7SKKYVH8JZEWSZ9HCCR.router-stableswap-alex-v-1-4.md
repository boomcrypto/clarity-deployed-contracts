---
title: "Trait router-stableswap-alex-v-1-4"
draft: true
---
```

;; router-stableswap-alex-v-1-4

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-3.stableswap-pool-trait)
(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_SCALED_AMOUNT_A (err u6012))
(define-constant ERR_QUOTE_A (err u6013))
(define-constant ERR_QUOTE_B (err u6014))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount-after-aggregator-fees alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get b alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount-after-aggregator-fees alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get c alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount-after-aggregator-fees alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get d alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount-after-aggregator-fees alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get e alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sa amount-after-aggregator-fees alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get b alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swaps: {
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
    (stableswap-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sb amount-after-aggregator-fees alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get c alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swaps: {
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
    (stableswap-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sc amount-after-aggregator-fees alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get d alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swaps: {
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
    (stableswap-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sd amount-after-aggregator-fees alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get e alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (is-stableswap-path-reversed
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool-contract <stableswap-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not (and (is-eq (contract-of token-in) (get x-token pool-data)) (is-eq (contract-of token-out) (get y-token pool-data))))
  )
)

(define-private (scale-up-stableswap-amount
    (amount uint)
    (stableswap-token <stableswap-ft-trait>)
    (alex-token <alex-ft-trait>)
  )
  (let (
    (stableswap-decimals (unwrap-panic (contract-call? stableswap-token get-decimals)))
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))
    (scaled-amount
      (if (is-eq stableswap-decimals alex-decimals)
        amount
        (if (> stableswap-decimals alex-decimals)
          (/ amount (pow u10 (- stableswap-decimals alex-decimals)))
          (* amount (pow u10 (- alex-decimals stableswap-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-down-alex-amount
    (amount uint)
    (alex-token <alex-ft-trait>)
    (stableswap-token <stableswap-ft-trait>)
  )
  (let (
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))
    (stableswap-decimals (unwrap-panic (contract-call? stableswap-token get-decimals)))
    (scaled-amount
      (if (is-eq alex-decimals stableswap-decimals)
        amount
        (if (> alex-decimals stableswap-decimals)
          (/ amount (pow u10 (- alex-decimals stableswap-decimals)))
          (* amount (pow u10 (- stableswap-decimals alex-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (stableswap-qa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 get-dy
                 (get a pools)
                 (get a tokens) (get b tokens)
                 amount))
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 get-dx
                 (get a pools)
                 (get b tokens) (get a tokens)
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (alex-qa
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
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

(define-private (stableswap-sa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-3 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sa
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
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
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
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
