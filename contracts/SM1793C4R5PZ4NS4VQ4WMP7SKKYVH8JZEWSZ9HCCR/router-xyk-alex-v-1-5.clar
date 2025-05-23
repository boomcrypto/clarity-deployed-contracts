
;; router-xyk-alex-v-1-5

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; Error constants
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SCALED_AMOUNT_A (err u6010))

;; Get quote for swap-helper-a
(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap and calculate scaled amounts
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools)
                       (alex-quote-a amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount quote-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get b alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (alex-quote-a scaled-amount-a alex-tokens alex-factors)
                       (xyk-quote-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-b
(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap and calculate scaled amounts
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools)
                       (alex-quote-b amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount quote-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get c alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (alex-quote-b scaled-amount-a alex-tokens alex-factors)
                       (xyk-quote-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-c
(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap and calculate scaled amounts
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools)
                       (alex-quote-c amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount quote-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get d alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (alex-quote-c scaled-amount-a alex-tokens alex-factors)
                       (xyk-quote-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-d
(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap and calculate scaled amounts
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools)
                       (alex-quote-d amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount quote-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get e alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (alex-quote-d scaled-amount-a alex-tokens alex-factors)
                       (xyk-quote-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Perform swap via XYK Core and ALEX
(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    ;; Transfer aggregator fees
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a xyk-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap and calculate scaled amounts
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount-after-aggregator-fees xyk-tokens xyk-pools))
                (try! (alex-swap-a amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount swap-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get b alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (alex-swap-a scaled-amount-a alex-tokens alex-factors))
                (try! (xyk-swap-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
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
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
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

;; Perform swap via XYK Core and ALEX
(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    ;; Transfer aggregator fees
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a xyk-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap and calculate scaled amounts
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount-after-aggregator-fees xyk-tokens xyk-pools))
                (try! (alex-swap-b amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount swap-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get c alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (alex-swap-b scaled-amount-a alex-tokens alex-factors))
                (try! (xyk-swap-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
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
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
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

;; Perform swap via XYK Core and ALEX
(define-public (swap-helper-c
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    ;; Transfer aggregator fees
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a xyk-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap and calculate scaled amounts
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount-after-aggregator-fees xyk-tokens xyk-pools))
                (try! (alex-swap-c amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount swap-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get d alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (alex-swap-c scaled-amount-a alex-tokens alex-factors))
                (try! (xyk-swap-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
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
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
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

;; Perform swap via XYK Core and ALEX
(define-public (swap-helper-d
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    ;; Transfer aggregator fees
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a xyk-tokens) (get a alex-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    
    ;; Perform each swap and calculate scaled amounts
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount-after-aggregator-fees xyk-tokens xyk-pools))
                (try! (alex-swap-d amount-after-aggregator-fees alex-tokens alex-factors))))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-xyk-amount swap-a (get b xyk-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get e alex-tokens) (get a xyk-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (alex-swap-d scaled-amount-a alex-tokens alex-factors))
                (try! (xyk-swap-a scaled-amount-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
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
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
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

;; Check if token path for swap via XYK Core is reversed relative to the pool's tokens
(define-private (is-xyk-path-reversed
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not
      (and
        (is-eq (contract-of token-in) (get x-token pool-data))
        (is-eq (contract-of token-out) (get y-token pool-data))
      )
    )
  )
)

;; Scale up XYK Core token amount
(define-private (scale-up-xyk-amount
    (amount uint)
    (xyk-token <xyk-ft-trait>)
    (alex-token <alex-ft-trait>)
  )
  (let (
    ;; Get decimals for tokens
    (xyk-decimals (unwrap-panic (contract-call? xyk-token get-decimals)))
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))

    ;; Calculate scaled amount
    (scaled-amount
      (if (is-eq xyk-decimals alex-decimals)
        amount
        (if (> xyk-decimals alex-decimals)
          (/ amount (pow u10 (- xyk-decimals alex-decimals)))
          (* amount (pow u10 (- alex-decimals xyk-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

;; Scale down ALEX token amount
(define-private (scale-down-alex-amount
    (amount uint)
    (alex-token <alex-ft-trait>)
    (xyk-token <xyk-ft-trait>)
  )
  (let (
    ;; Get decimals for tokens
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))
    (xyk-decimals (unwrap-panic (contract-call? xyk-token get-decimals)))

    ;; Calculate scaled amount
    (scaled-amount
      (if (is-eq alex-decimals xyk-decimals)
        amount
        (if (> alex-decimals xyk-decimals)
          (/ amount (pow u10 (- alex-decimals xyk-decimals)))
          (* amount (pow u10 (- xyk-decimals alex-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

;; Get swap quote via XYK Core using two tokens
(define-private (xyk-quote-a
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))

    ;; Get quote based on path direction
    (quote-result (if (is-eq is-reversed false)
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                            (get a pools)
                            (get a tokens) (get b tokens)
                            amount))
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx
                            (get a pools)
                            (get b tokens) (get a tokens)
                            amount))))
  )
    (ok quote-result)
  )
)

;; Get swap quote via ALEX using two tokens
(define-private (alex-quote-a
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (quote-result (unwrap-panic (contract-call?
                                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                                (contract-of a-token) (contract-of b-token)
                                (get a factors)
                                amount)))
  )
    (ok quote-result)
  )
)

;; Get swap quote via ALEX using three tokens
(define-private (alex-quote-b
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (quote-result (unwrap-panic (contract-call?
                                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                                (contract-of a-token) (contract-of b-token) (contract-of c-token)
                                (get a factors) (get b factors)
                                amount)))
  )
    (ok quote-result)
  )
)

;; Get swap quote via ALEX using four tokens
(define-private (alex-quote-c
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (d-token (get d tokens))
    (quote-result (unwrap-panic (contract-call?
                                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b
                                (contract-of a-token) (contract-of b-token) (contract-of c-token)
                                (contract-of d-token)
                                (get a factors) (get b factors) (get c factors)
                                amount)))
  )
    (ok quote-result)
  )
)

;; Get swap quote via ALEX using five tokens
(define-private (alex-quote-d
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
    (quote-result (unwrap-panic (contract-call?
                                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c
                                (contract-of a-token) (contract-of b-token) (contract-of c-token)
                                (contract-of d-token) (contract-of e-token)
                                (get a factors) (get b factors) (get c factors) (get d factors)
                                amount)))
  )
    (ok quote-result)
  )
)

;; Perform swap via XYK Core using two tokens
(define-private (xyk-swap-a
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))

    ;; Perform swap based on path direction
    (swap-result (if (is-eq is-reversed false)
                     (try! (contract-call?
                           'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                           (get a pools)
                           (get a tokens) (get b tokens)
                           amount u1))
                     (try! (contract-call?
                           'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
                           (get a pools)
                           (get b tokens) (get a tokens)
                           amount u1))))
  )
    (ok swap-result)
  )
)

;; Perform swap via ALEX using two tokens
(define-private (alex-swap-a
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                       (get a tokens) (get b tokens)
                       (get a factors)
                       amount (some u1))))
  )
    (ok swap-result)
  )
)

;; Perform swap via ALEX using three tokens
(define-private (alex-swap-b
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                       (get a tokens) (get b tokens) (get c tokens)
                       (get a factors) (get b factors)
                       amount (some u1))))
  )
    (ok swap-result)
  )
)

;; Perform swap via ALEX using four tokens
(define-private (alex-swap-c
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                       (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                       (get a factors) (get b factors) (get c factors)
                       amount (some u1))))
  )
    (ok swap-result)
  )
)

;; Perform swap via ALEX using five tokens
(define-private (alex-swap-d
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                       (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                       (get a factors) (get b factors) (get c factors) (get d factors)
                       amount (some u1))))
  )
    (ok swap-result)
  )
)

;; Get aggregator fees
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

;; Transfer aggregator fees
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