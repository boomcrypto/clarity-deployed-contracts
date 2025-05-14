
;; router-xyk-alex-v-1-4

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait x-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait x-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))
(define-constant ERR_SCALED_AMOUNT_A (err u6001))
(define-constant ERR_QUOTE_A (err u7001))
(define-constant ERR_QUOTE_B (err u7002))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (if (is-eq xyk-reversed false)
                 (unwrap! (contract-call? pool-trait get-dy amount-after-aggregator-fees) ERR_QUOTE_A)
                 (unwrap! (contract-call? pool-trait get-dx amount-after-aggregator-fees) ERR_QUOTE_A)))
    (xyk-token-out (if (is-eq xyk-reversed false) y-token-trait x-token-trait))
    (scaled-amount (unwrap! (scale-xyk-amount quote-a xyk-token-out token-x-trait) ERR_SCALED_AMOUNT_A))           
    (quote-b (unwrap! (contract-call?
                      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                      (contract-of token-x-trait) (contract-of token-y-trait)
                      factor
                      scaled-amount) ERR_QUOTE_B))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (unwrap! (contract-call?
                      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                      (contract-of token-x-trait) (contract-of token-y-trait)
                      factor
                      amount-after-aggregator-fees) ERR_QUOTE_A))
    (xyk-token-in (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (scaled-amount (unwrap! (scale-alex-amount quote-a token-y-trait xyk-token-in) ERR_SCALED_AMOUNT_A))
    (quote-b (if (is-eq xyk-reversed false)
                 (unwrap! (contract-call? pool-trait get-dy scaled-amount) ERR_QUOTE_B)
                 (unwrap! (contract-call? pool-trait get-dx scaled-amount) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (aggregator-fee-token (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (swap-a (if (is-eq xyk-reversed false)
                (unwrap! (xyk-sa amount pool-trait x-token-trait y-token-trait) ERR_SWAP_A)
                (unwrap! (xyk-sb amount pool-trait x-token-trait y-token-trait) ERR_SWAP_A)))
    (xyk-token-out (if (is-eq xyk-reversed false) y-token-trait x-token-trait))
    (scaled-amount (unwrap! (scale-xyk-amount swap-a xyk-token-out token-x-trait) ERR_SCALED_AMOUNT_A))
    (swap-b (unwrap! (alex-sa scaled-amount token-x-trait token-y-trait factor) ERR_SWAP_B))
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
          xyk-data: {
            x-pool: (contract-of pool-trait),
            x-tokens: {
              a: (contract-of x-token-trait),
              b: (contract-of y-token-trait)
            },
            x-reversed: xyk-reversed,
            x-swap: swap-a
          },
          alex-data: {
            a-tokens: {
              a: (contract-of token-x-trait),
              b: (contract-of token-y-trait)
            },
            a-factors: {
              a: factor
            },
            a-swap: swap-b
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider amount)))
    (swap-a (unwrap! (alex-sa amount-after-aggregator-fees token-x-trait token-y-trait factor) ERR_SWAP_A))
    (xyk-token-in (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (scaled-amount (unwrap! (scale-alex-amount swap-a token-y-trait xyk-token-in) ERR_SCALED_AMOUNT_A))
    (swap-b (if (is-eq xyk-reversed false)
                (unwrap! (xyk-sa scaled-amount pool-trait x-token-trait y-token-trait) ERR_SWAP_B)
                (unwrap! (xyk-sb scaled-amount pool-trait x-token-trait y-token-trait) ERR_SWAP_B)))
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
          xyk-data: {
            x-pool: (contract-of pool-trait),
            x-tokens: {
              a: (contract-of x-token-trait),
              b: (contract-of y-token-trait)
            },
            x-reversed: xyk-reversed,
            x-swap: swap-b
          },
          alex-data: {
            a-tokens: {
              a: (contract-of token-x-trait),
              b: (contract-of token-y-trait)
            },
            a-factors: {
              a: factor
            },
            a-swap: swap-a
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (xyk-sa
    (amount uint)
    (pool-trait <x-pool-trait>)
    (a-token <x-ft-trait>) (b-token <x-ft-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-x-for-y
                  pool-trait
                  a-token b-token
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (xyk-sb
    (amount uint)
    (pool-trait <x-pool-trait>)
    (a-token <x-ft-trait>) (b-token <x-ft-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                  pool-trait
                  a-token b-token
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (alex-sa
    (amount uint)
    (a-token <a-ft-trait>) (b-token <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  a-token b-token
                  factor
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (scale-xyk-amount (amount uint) (x-token <x-ft-trait>) (a-token <a-ft-trait>))
  (let (
    (x-decimals (unwrap-panic (contract-call? x-token get-decimals)))
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (scaled-amount
      (if (is-eq x-decimals a-decimals)
        amount
        (if (> x-decimals a-decimals)
          (/ amount (pow u10 (- x-decimals a-decimals)))
          (* amount (pow u10 (- a-decimals x-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-alex-amount (amount uint) (a-token <a-ft-trait>) (x-token <x-ft-trait>))
  (let (
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (x-decimals (unwrap-panic (contract-call? x-token get-decimals)))
    (scaled-amount
      (if (is-eq a-decimals x-decimals)
        amount
        (if (> a-decimals x-decimals)
          (/ amount (pow u10 (- a-decimals x-decimals)))
          (* amount (pow u10 (- x-decimals a-decimals)))
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