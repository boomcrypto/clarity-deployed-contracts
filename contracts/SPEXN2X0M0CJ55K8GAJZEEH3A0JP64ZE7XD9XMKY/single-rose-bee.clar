;; xyk-quote-helper-v-1-1

(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)

(define-public (get-dy (pool-trait <xyk-pool-trait>) (x-amount uint))
  (let (
    (call-a (contract-call? pool-trait get-dy x-amount))
  )
    (ok call-a)
  )
)

(define-public (get-dx (pool-trait <xyk-pool-trait>) (y-amount uint))
  (let (
    (call-a (contract-call? pool-trait get-dx y-amount))
  )
    (ok call-a)
  )
)

(define-public (get-dlp (pool-trait <xyk-pool-trait>) (x-amount uint))
  (let (
    (call-a (contract-call? pool-trait get-dlp x-amount))
  )
    (ok call-a)
  )
)