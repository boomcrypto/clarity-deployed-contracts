;; router-stableswap-v-1-4-v-1-2-xyk-v-1-1

(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait v-1-4-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait v-1-2-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)

(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_SWAP_C (err u6012))
(define-constant ERR_QUOTE_A (err u6013))
(define-constant ERR_QUOTE_B (err u6014))
(define-constant ERR_QUOTE_C (err u6015))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount-after-aggregator-fees v-1-4-tokens v-1-4-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-a quote-a v-1-2-tokens v-1-2-pools) ERR_QUOTE_B))
    (quote-c (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a quote-b xyk-tokens xyk-pools) ERR_QUOTE_C)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-b v-1-4-tokens v-1-4-pools) ERR_QUOTE_C)))
  )
    (ok quote-c)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount-after-aggregator-fees v-1-4-tokens v-1-4-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-a quote-a v-1-2-tokens v-1-2-pools) ERR_QUOTE_B))
    (quote-c (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b quote-b xyk-tokens xyk-pools) ERR_QUOTE_C)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-b v-1-4-tokens v-1-4-pools) ERR_QUOTE_C)))
  )
    (ok quote-c)
  )
)

(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount-after-aggregator-fees v-1-4-tokens v-1-4-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-a amount-after-aggregator-fees v-1-2-tokens v-1-2-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 get-quote-a quote-a v-1-2-tokens v-1-2-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-a v-1-4-tokens v-1-4-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-1-4-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount-after-aggregator-fees u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 v-1-2-tokens v-1-2-pools) ERR_SWAP_B))
    (swap-c (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a swap-b u0 xyk-tokens xyk-pools) ERR_SWAP_C)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-b u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_C)))
  )
    (begin
      (asserts! (>= swap-c min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-c,
          provider: provider,
          swaps-reversed: swaps-reversed,
          v-1-4-data: {
            v-1-4-tokens: v-1-4-tokens,
            v-1-4-pools: v-1-4-pools,
            v-1-4-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-c)
            }
          },
          v-1-2-data: {
            v-1-2-tokens: v-1-2-tokens,
            v-1-2-pools: v-1-2-pools,
            v-1-2-swaps: {
              a: swap-b
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-c swap-a)
            }
          }
        }
      })
      (ok swap-c)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-1-4-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount-after-aggregator-fees u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b amount-after-aggregator-fees u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 v-1-2-tokens v-1-2-pools) ERR_SWAP_B))
    (swap-c (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b swap-b u0 xyk-tokens xyk-pools) ERR_SWAP_C)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-b u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_C)))
  )
    (begin
      (asserts! (>= swap-c min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-c,
          provider: provider,
          swaps-reversed: swaps-reversed,
          v-1-4-data: {
            v-1-4-tokens: v-1-4-tokens,
            v-1-4-pools: v-1-4-pools,
            v-1-4-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-c)
            }
          },
          v-1-2-data: {
            v-1-2-tokens: v-1-2-tokens,
            v-1-2-pools: v-1-2-pools,
            v-1-2-swaps: {
              a: swap-b
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-c swap-a)
            }
          }
        }
      })
      (ok swap-c)
    )
  )
)

(define-public (swap-helper-c
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (v-1-4-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-4-pools (tuple (a <v-1-4-pool-trait>)))
    (v-1-2-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (v-1-2-pools (tuple (a <v-1-2-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a v-1-4-tokens) (get a v-1-2-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount-after-aggregator-fees u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-a amount-after-aggregator-fees u0 v-1-2-tokens v-1-2-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-2 swap-helper-a swap-a u0 v-1-2-tokens v-1-2-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-a u0 v-1-4-tokens v-1-4-pools) ERR_SWAP_B)))
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
          v-1-4-data: {
            v-1-4-tokens: v-1-4-tokens,
            v-1-4-pools: v-1-4-pools,
            v-1-4-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          v-1-2-data: {
            v-1-2-tokens: v-1-2-tokens,
            v-1-2-pools: v-1-2-pools,
            v-1-2-swaps: {
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