;; router-ststxbtc-stableswap-xyk-multihop-v-1-2

(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait ststx-ststxbtc-reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-a
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-a
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-b
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-b
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-c
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-c
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-c
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-d
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-d
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-d
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-e
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-e
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-e
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-f
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-f
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-f
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-g
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-g
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-g
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-h
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-h
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-h
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-i
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-i
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stableswap-xyk-multihop-v-1-2 swap-helper-i
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-private (swap-ststx-ststxbtc (amount uint) (reserve <ststx-ststxbtc-reserve-trait>) (reversed bool))
  (ok (if (is-eq reversed false)
      (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststx-for-ststxbtc amount reserve))
      (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststxbtc-for-ststx amount reserve))
  ))
)