
;; router-stableswap-xyk-v-1-3

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait xyk-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)

(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_QUOTE_A (err u6012))
(define-constant ERR_QUOTE_B (err u6013))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (xyk-qa amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (xyk-qa quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a xyk-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (xyk-sa amount-after-aggregator-fees xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (xyk-sa swap-a xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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

(define-private (is-xyk-path-reversed
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not (and (is-eq (contract-of token-in) (get x-token pool-data)) (is-eq (contract-of token-out) (get y-token pool-data))))
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
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dy
                 (get a pools)
                 (get a tokens) (get b tokens)
                 amount))
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dx
                 (get a pools)
                 (get b tokens) (get a tokens)
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (xyk-qa
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (pool-contract (get a pools))
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 pool-contract get-dy
                 amount))
                 (try! (contract-call?
                 pool-contract get-dx
                 amount))))
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
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (xyk-sa
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
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