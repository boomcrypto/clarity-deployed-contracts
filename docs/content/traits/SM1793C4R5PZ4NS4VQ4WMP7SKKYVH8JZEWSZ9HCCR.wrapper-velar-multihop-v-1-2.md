---
title: "Trait wrapper-velar-multihop-v-1-2"
draft: true
---
```

;; wrapper-velar-multihop-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-read-only (get-amount-out-3
    (amt-in uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amt-in)))
    (call-a (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-3
            amount-after-aggregator-fees
            token-a token-b token-c))
  )
    (ok call-a)
  )
)

(define-read-only (get-amount-out-4
    (amt-in uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (ids (list 4 uint))
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amt-in)))
    (call-a (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-4
            amount-after-aggregator-fees
            token-a token-b token-c token-d ids))
  )
    (ok call-a)
  )
)

(define-read-only (get-amount-out-5
    (amt-in uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (token-e <ft-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amt-in)))
    (call-a (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-5
            amount-after-aggregator-fees
            token-a token-b token-c token-d token-e))
  )
    (ok call-a)
  )
)

(define-public (swap-3
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-a provider amt-in)))
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3
                  amount-after-aggregator-fees amt-out-min
                  token-a token-b
                  token-c
                  share-fee-to)))
  )
    (print {
      action: "swap-3",
      caller: tx-sender,
      data: {
        amount: amt-in,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: amt-out-min,
        received: swap-a,
        provider: provider,
        token-a: token-a,
        token-b: token-b,
        token-c: token-c,
        share-fee-to: share-fee-to
      }
    })
    (ok swap-a)
  )
)

(define-public (swap-4
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-a provider amt-in)))
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4
                  amount-after-aggregator-fees amt-out-min
                  token-a token-b
                  token-c token-d
                  share-fee-to)))
  )
    (print {
      action: "swap-4",
      caller: tx-sender,
      data: {
        amount: amt-in,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: amt-out-min,
        received: swap-a,
        provider: provider,
        token-a: token-a,
        token-b: token-b,
        token-c: token-c,
        token-d: token-d,
        share-fee-to: share-fee-to
      }
    })
    (ok swap-a)
  )
)

(define-public (swap-5
    (amt-in uint) (amt-out-min uint)
    (token-a <ft-trait>) (token-b <ft-trait>)
    (token-c <ft-trait>) (token-d <ft-trait>)
    (token-e <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-a provider amt-in)))
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5
                  amount-after-aggregator-fees amt-out-min
                  token-a token-b
                  token-c token-d
                  token-e
                  share-fee-to)))
  )
    (print {
      action: "swap-5",
      caller: tx-sender,
      data: {
        amount: amt-in,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: amt-out-min,
        received: swap-a,
        provider: provider,
        token-a: token-a,
        token-b: token-b,
        token-c: token-c,
        token-d: token-d,
        token-e: token-e,
        share-fee-to: share-fee-to
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
```
