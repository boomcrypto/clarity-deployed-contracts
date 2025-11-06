;; wrapper-ststxbtc-v-1-3

(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-constant ERR_MINIMUM_RECEIVED (err u6009))

(define-constant BPS u1000000)

(define-public (quote-ststx-for-ststxbtc
    (amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                     reserve)))
    (stx-amount (/ (* amount-after-aggregator-fees stx-ststx) BPS))
  )
    (ok stx-amount)
  )
)

(define-public (quote-ststxbtc-for-ststx
    (amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                     reserve)))
    (ststx-amount (/ (* amount-after-aggregator-fees BPS) stx-ststx))
  )
    (ok ststx-amount)
  )
)

(define-public (swap-ststx-for-ststxbtc
    (amount uint) (min-received uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token provider amount)))
    (swap-a (try! (contract-call?
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststx-for-ststxbtc
                  amount-after-aggregator-fees reserve)))
  )
    (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)
    (print {
      action: "swap-ststx-for-ststxbtc",
      caller: tx-sender,
      data: {
        amount: amount,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: min-received,
        received: swap-a,
        provider: provider,
        reserve: reserve
      }
    })
    (ok swap-a)
  )
)

(define-public (swap-ststxbtc-for-ststx
    (amount uint) (min-received uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token provider amount)))
    (swap-a (try! (contract-call?
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststxbtc-for-ststx
                  amount-after-aggregator-fees reserve)))
  )
    (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)
    (print {
      action: "swap-ststxbtc-for-ststx",
      caller: tx-sender,
      data: {
        amount: amount,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: min-received,
        received: swap-a,
        provider: provider,
        reserve: reserve
      }
    })
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
