
;; router-ststxbtc-stable-xyk-multi-v-1-2

(use-trait ft-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait xyk-pool-trait .xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait ststx-ststxbtc-reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-constant BPS u1000000)

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-a
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-a
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-b
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-b
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-c
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-c
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-d
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-d
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-e
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-e
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-f
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-f
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-g
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-g
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-h
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-h
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-i
            amount provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 get-quote-i
            quote-a provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
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
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-a
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-a
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-b
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-b
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-c
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-c
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-d
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-d
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-e
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-e
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-f
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-f
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-g
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-g
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-h
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-h
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
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-i
            amount min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? .router-stableswap-xyk-multihop-v-1-2 swap-helper-i
            swap-a min-received provider swaps-reversed stableswap-tokens stableswap-pools xyk-tokens xyk-pools))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
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