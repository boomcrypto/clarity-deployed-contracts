;; router-ststxbtc-stx-ststx-bitflow-arkadiko-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ststx-ststxbtc-reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-constant BPS u1000000)

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (token-x principal) (token-y principal)
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 get-quote-a
            amount provider token-x token-y))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 get-quote-a
            quote-a provider token-x token-y))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (token-x principal) (token-y principal)
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (quote-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (quote-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 get-quote-b
            amount provider token-x token-y))
    ))
    (quote-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 get-quote-b
            quote-a provider token-x token-y))
      (try! (quote-ststx-ststxbtc quote-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 swap-helper-a
            amount min-received provider token-x-trait token-y-trait))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 swap-helper-a
            swap-a min-received provider token-x-trait token-y-trait))
      (try! (swap-ststx-ststxbtc swap-a ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
    ))
  )
    (ok swap-b)
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (ststx-ststxbtc-path-reversed bool) (ststx-ststxbtc-calls-reversed bool) (ststx-ststxbtc-reserve <ststx-ststxbtc-reserve-trait>)
  )
  (let (
    (swap-a (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (swap-ststx-ststxbtc amount ststx-ststxbtc-reserve ststx-ststxbtc-path-reversed))
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 swap-helper-b
            amount min-received provider token-x-trait token-y-trait))
    ))
    (swap-b (if (is-eq ststx-ststxbtc-calls-reversed false)
      (try! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.router-stx-ststx-bitflow-arkadiko-v-1-2 swap-helper-b
            swap-a min-received provider token-x-trait token-y-trait))
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