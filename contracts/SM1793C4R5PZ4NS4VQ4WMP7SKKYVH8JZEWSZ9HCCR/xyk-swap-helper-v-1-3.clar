
;; xyk-swap-helper-v-1-3

;; Use XYK ft trait and XYK pool trait
(use-trait xyk-ft-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait xyk-pool-trait .xyk-pool-trait-v-1-2.xyk-pool-trait)

;; Error constants
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))

;; Get quote for swap-helper-a
(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (xyk-qa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
  )
    ;; Return number of b tokens the caller would receive
    (ok quote-a)
  )
)

;; Get quote for swap-helper-b
(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (xyk-qa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (quote-b (try! (xyk-qa quote-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
  )
    ;; Return number of d tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-c
(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (xyk-qa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (quote-b (try! (xyk-qa quote-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (quote-c (try! (xyk-qa quote-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
  )
    ;; Return number of f tokens the caller would receive
    (ok quote-c)
  )
)

;; Get quote for swap-helper-d
(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>) (g <xyk-ft-trait>) (h <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>) (d <xyk-pool-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (xyk-qa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (quote-b (try! (xyk-qa quote-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (quote-c (try! (xyk-qa quote-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
    (quote-d (try! (xyk-qa quote-c (get g xyk-tokens) (get h xyk-tokens) (get d xyk-pools))))
  )
    ;; Return number of h tokens the caller would receive
    (ok quote-d)
  )
)

;; Get quote for swap-helper-e
(define-public (get-quote-e
    (amount uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>) (g <xyk-ft-trait>) (h <xyk-ft-trait>) (i <xyk-ft-trait>) (j <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>) (d <xyk-pool-trait>) (e <xyk-pool-trait>)))
  )
  (let (
    ;; Get aggregator fees
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (xyk-qa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (quote-b (try! (xyk-qa quote-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (quote-c (try! (xyk-qa quote-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
    (quote-d (try! (xyk-qa quote-c (get g xyk-tokens) (get h xyk-tokens) (get d xyk-pools))))
    (quote-e (try! (xyk-qa quote-d (get i xyk-tokens) (get j xyk-tokens) (get e xyk-pools))))
  )
    ;; Return number of j tokens the caller would receive
    (ok quote-e)
  )
)

;; Swap via 1 XYK pool
(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees (get a xyk-tokens) provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (xyk-sa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
  )
    (begin
      ;; Assert that swap-a is greater than or equal to min-received
      (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of b tokens the caller received
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-a,
          provider: provider,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: swap-a
            }
          }
        }
      })
      (ok swap-a)
    )
  )
)

;; Swap via 2 XYK pools
(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees (get a xyk-tokens) provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (xyk-sa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (swap-b (try! (xyk-sa swap-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of d tokens the caller received
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
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: swap-a,
              b: swap-b
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Swap via 3 XYK pools
(define-public (swap-helper-c
    (amount uint) (min-received uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees (get a xyk-tokens) provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (xyk-sa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (swap-b (try! (xyk-sa swap-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (swap-c (try! (xyk-sa swap-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
  )
    (begin
      ;; Assert that swap-c is greater than or equal to min-received
      (asserts! (>= swap-c min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of f tokens the caller received
      (print {
        action: "swap-helper-c",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-c,
          provider: provider,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c
            }
          }
        }
      })
      (ok swap-c)
    )
  )
)

;; Swap via 4 XYK pools
(define-public (swap-helper-d
    (amount uint) (min-received uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>) (g <xyk-ft-trait>) (h <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>) (d <xyk-pool-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees (get a xyk-tokens) provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (xyk-sa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (swap-b (try! (xyk-sa swap-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (swap-c (try! (xyk-sa swap-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
    (swap-d (try! (xyk-sa swap-c (get g xyk-tokens) (get h xyk-tokens) (get d xyk-pools))))
  )
    (begin
      ;; Assert that swap-d is greater than or equal to min-received
      (asserts! (>= swap-d min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of h tokens the caller received
      (print {
        action: "swap-helper-d",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-d,
          provider: provider,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c,
              d: swap-d
            }
          }
        }
      })
      (ok swap-d)
    )
  )
)

;; Swap via 5 XYK pools
(define-public (swap-helper-e
    (amount uint) (min-received uint) (provider (optional principal))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>) (c <xyk-ft-trait>) (d <xyk-ft-trait>) (e <xyk-ft-trait>) (f <xyk-ft-trait>) (g <xyk-ft-trait>) (h <xyk-ft-trait>) (i <xyk-ft-trait>) (j <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>) (d <xyk-pool-trait>) (e <xyk-pool-trait>)))
  )
  (let (
    ;; Transfer aggregator fees
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees (get a xyk-tokens) provider amount)))

    ;; Assert that amount-after-aggregator-fees is greater than 0
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (xyk-sa amount-after-aggregator-fees (get a xyk-tokens) (get b xyk-tokens) (get a xyk-pools))))
    (swap-b (try! (xyk-sa swap-a (get c xyk-tokens) (get d xyk-tokens) (get b xyk-pools))))
    (swap-c (try! (xyk-sa swap-b (get e xyk-tokens) (get f xyk-tokens) (get c xyk-pools))))
    (swap-d (try! (xyk-sa swap-c (get g xyk-tokens) (get h xyk-tokens) (get d xyk-pools))))
    (swap-e (try! (xyk-sa swap-d (get i xyk-tokens) (get j xyk-tokens) (get e xyk-pools))))
  )
    (begin
      ;; Assert that swap-e is greater than or equal to min-received
      (asserts! (>= swap-e min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of j tokens the caller received
      (print {
        action: "swap-helper-e",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-e,
          provider: provider,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c,
              d: swap-d,
              e: swap-e
            }
          }
        }
      })
      (ok swap-e)
    )
  )
)

;; Check if input and output tokens are swapped relative to the pool's x and y tokens
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

;; Get XYK quote using get-dy or get-dx based on token path
(define-private (xyk-qa
    (amount uint)
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    
    ;; Get quote based on path
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 .xyk-core-v-1-2 get-dy
                 pool
                 token-in token-out
                 amount))
                 (try! (contract-call?
                 .xyk-core-v-1-2 get-dx
                 pool
                 token-out token-in
                 amount))))
  )
    (ok quote-a)
  )
)

;; Perform XYK swap using swap-x-for-y or swap-y-for-x based on token path
(define-private (xyk-sa
    (amount uint)
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool <xyk-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-xyk-path-reversed token-in token-out pool))
    
    ;; Perform swap based on path
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      .xyk-core-v-1-2 swap-x-for-y
                      pool
                      token-in token-out
                      amount u1))
                (try! (contract-call?
                      .xyk-core-v-1-2 swap-y-for-x
                      pool
                      token-out token-in
                      amount u1))))
  )
    (ok swap-a)
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
(define-private (transfer-aggregator-fees (token <xyk-ft-trait>) (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.aggregator-core-v-1-1 transfer-aggregator-fees
                  token (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)