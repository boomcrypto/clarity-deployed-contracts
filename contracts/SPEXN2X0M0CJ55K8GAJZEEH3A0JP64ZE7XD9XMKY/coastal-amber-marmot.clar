;; router-ststxbtc-stableswap-v-1-2

(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait ststx-ststxbtc-reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-constant ERR_MINIMUM_RECEIVED (err u6009))

(define-constant BPS u1000000)

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-a
            amount provider stableswap-tokens stableswap-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-a
            quote-a provider stableswap-tokens stableswap-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-b
            amount provider stableswap-tokens stableswap-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-b
            quote-a provider stableswap-tokens stableswap-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-c
            amount provider stableswap-tokens stableswap-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-c
            quote-a provider stableswap-tokens stableswap-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-d
            amount provider stableswap-tokens stableswap-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-d
            quote-a provider stableswap-tokens stableswap-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-e
    (amount uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>) (i <stableswap-ft-trait>) (j <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>) (e <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-e
            amount provider stableswap-tokens stableswap-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 get-quote-e
            quote-a provider stableswap-tokens stableswap-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-a
            amount u0 provider stableswap-tokens stableswap-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-a
            amount u0 provider stableswap-tokens stableswap-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender,
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          ststx-ststxbtc-data: {
            ststx-ststxbtc-path-reversed: ststx-ststxbtc-path-reversed,
            ststx-ststxbtc-calls-reversed: ststx-ststxbtc-calls-reversed,
            ststx-ststxbtc-reserve: ststx-ststxbtc-reserve,
            ststx-ststxbtc-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-a swap-b)
            }
          },
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-b
            amount u0 provider stableswap-tokens stableswap-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-b
            amount u0 provider stableswap-tokens stableswap-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: tx-sender,
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          ststx-ststxbtc-data: {
            ststx-ststxbtc-path-reversed: ststx-ststxbtc-path-reversed,
            ststx-ststxbtc-calls-reversed: ststx-ststxbtc-calls-reversed,
            ststx-ststxbtc-reserve: ststx-ststxbtc-reserve,
            ststx-ststxbtc-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-a swap-b)
            }
          },
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-c
            amount u0 provider stableswap-tokens stableswap-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-c
            amount u0 provider stableswap-tokens stableswap-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-c",
        caller: tx-sender,
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          ststx-ststxbtc-data: {
            ststx-ststxbtc-path-reversed: ststx-ststxbtc-path-reversed,
            ststx-ststxbtc-calls-reversed: ststx-ststxbtc-calls-reversed,
            ststx-ststxbtc-reserve: ststx-ststxbtc-reserve,
            ststx-ststxbtc-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-a swap-b)
            }
          },
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-d
            amount u0 provider stableswap-tokens stableswap-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-d
            amount u0 provider stableswap-tokens stableswap-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-d",
        caller: tx-sender,
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          ststx-ststxbtc-data: {
            ststx-ststxbtc-path-reversed: ststx-ststxbtc-path-reversed,
            ststx-ststxbtc-calls-reversed: ststx-ststxbtc-calls-reversed,
            ststx-ststxbtc-reserve: ststx-ststxbtc-reserve,
            ststx-ststxbtc-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-a swap-b)
            }
          },
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>) (i <stableswap-ft-trait>) (j <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>) (e <stableswap-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-e
            amount u0 provider stableswap-tokens stableswap-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-5 swap-helper-e
            amount u0 provider stableswap-tokens stableswap-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-e",
        caller: tx-sender,
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          ststx-ststxbtc-data: {
            ststx-ststxbtc-path-reversed: ststx-ststxbtc-path-reversed,
            ststx-ststxbtc-calls-reversed: ststx-ststxbtc-calls-reversed,
            ststx-ststxbtc-reserve: ststx-ststxbtc-reserve,
            ststx-ststxbtc-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-a swap-b)
            }
          },
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq ststx-ststxbtc-calls-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (quote-ststx-ststxbtc (amount uint) (reserve <ststx-ststxbtc-reserve-trait>) (reversed bool))
  (let (
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                     reserve)))
    (quote-a (if (is-eq reversed false)
                 (/ (* amount stx-ststx) BPS)
                 (/ (* amount BPS) stx-ststx)))
  )
    (ok quote-a)
  )
)

(define-private (swap-ststx-ststxbtc (amount uint) (reserve <ststx-ststxbtc-reserve-trait>) (reversed bool))
  (ok (if (is-eq reversed false)
      (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststx-for-ststxbtc amount reserve))
      (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststxbtc-for-ststx amount reserve))
  ))
)