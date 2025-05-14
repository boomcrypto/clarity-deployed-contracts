
;; router-xyk-stx-ststx-v-1-2

;; Use all required traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait stx-ststx-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;; Error constants
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_NO_STX_STSTX_EXTERNAL_DATA (err u6010))

;; Get quote for swap-helper-a
(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (stx-ststx-tokens (tuple (a <stx-ststx-ft-trait>) (b <stx-ststx-ft-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount-after-aggregator-fees xyk-tokens xyk-pools)
                       (stx-ststx-quote-a amount-after-aggregator-fees stx-ststx-tokens))))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (stx-ststx-quote-a quote-a stx-ststx-tokens)
                       (xyk-quote-a quote-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Perform swap via XYK Core and Velar
(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (stx-ststx-tokens (tuple (a <stx-ststx-ft-trait>) (b <stx-ststx-ft-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a xyk-tokens) (get a stx-ststx-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount-after-aggregator-fees xyk-tokens xyk-pools))
                (try! (stx-ststx-swap-a amount-after-aggregator-fees stx-ststx-tokens))))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (stx-ststx-swap-a swap-a stx-ststx-tokens))
                (try! (xyk-swap-a swap-a xyk-tokens xyk-pools))))
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
          stx-ststx-data: {
            stx-ststx-tokens: stx-ststx-tokens,
            stx-ststx-swaps: {
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

;; Check if token path for swap via STX-stSTX Stableswap is reversed relative to the pool's tokens
(define-private (is-stx-ststx-path-reversed
    (token-in <stx-ststx-ft-trait>) (token-out <stx-ststx-ft-trait>)
  )
  (not
    (and
      (is-eq (contract-of token-in) 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2)
      (is-eq (contract-of token-out) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
    )
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

;; Get swap quote via STX-stSTX Stableswap using two tokens
(define-private (stx-ststx-quote-a
    (amount uint)
    (tokens (tuple (a <stx-ststx-ft-trait>) (b <stx-ststx-ft-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-stx-ststx-path-reversed (get a tokens) (get b tokens)))
    
    ;; Get quote based on path direction
    (quote-result (if (is-eq is-reversed false)
                      (unwrap! (contract-call?
                               'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                               'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                               'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                               amount) ERR_NO_STX_STSTX_EXTERNAL_DATA)
                      (unwrap! (contract-call?
                               'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                               'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                               'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                               amount) ERR_NO_STX_STSTX_EXTERNAL_DATA)))
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

;; Perform swap via STX-stSTX Stableswap using two tokens
(define-private (stx-ststx-swap-a
    (amount uint)
    (tokens (tuple (a <stx-ststx-ft-trait>) (b <stx-ststx-ft-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-stx-ststx-path-reversed (get a tokens) (get b tokens)))

    ;; Perform swap based on path direction
    (swap-result (if (is-eq is-reversed false)
                     (unwrap! (contract-call?
                              'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
                              'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                              'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                              amount u1) ERR_NO_STX_STSTX_EXTERNAL_DATA)
                     (unwrap! (contract-call?
                              'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
                              'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                              'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                              amount u1) ERR_NO_STX_STSTX_EXTERNAL_DATA)))
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