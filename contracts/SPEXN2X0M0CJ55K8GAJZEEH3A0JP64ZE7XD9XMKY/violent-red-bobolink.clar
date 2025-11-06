;; wrapper-ststxbtc-v-1-1

(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait reserve-trait 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-trait-v1.reserve-trait)

(define-constant BPS u1000000)

(define-public (quote-ststx-for-ststxbtc
    (ststx-amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider ststx-amount)))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                     reserve)))
    (stx-amount (/ (* amount-after-aggregator-fees stx-ststx) BPS))
  )
    (ok stx-amount)
  )
)

(define-public (quote-ststxbtc-for-ststx
    (ststxbtc-amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider ststxbtc-amount)))
    (stx-ststx (try! (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx
                     reserve)))
    (ststx-amount (/ (* amount-after-aggregator-fees BPS) stx-ststx))
  )
    (ok ststx-amount)
  )
)

(define-public (swap-ststx-for-ststxbtc
    (ststx-amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token provider ststx-amount)))
    (swap-a (try! (contract-call?
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststx-for-ststxbtc
                  ststx-amount reserve)))
  )
    (print {
      action: "swap-ststx-for-ststxbtc",
      caller: tx-sender,
      data: {
        amount: ststx-amount,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        received: swap-a,
        provider: provider,
        reserve: reserve
      }
    })
    (ok swap-a)
  )
)

(define-public (swap-ststxbtc-for-ststx
    (ststxbtc-amount uint) (reserve <reserve-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token provider ststxbtc-amount)))
    (swap-a (try! (contract-call?
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1 swap-ststxbtc-for-ststx
                  ststxbtc-amount reserve)))
  )
    (print {
      action: "swap-ststxbtc-for-ststx",
      caller: tx-sender,
      data: {
        amount: ststxbtc-amount,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
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
