
;; wrapper-velar-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-read-only (amount-out
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amt-in)))
    (call-a (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 amount-out
            amount-after-aggregator-fees token-in token-out))
  )
    (ok call-a)
  )
)

(define-public (swap-helper-a 
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (amt-in uint) (amt-out-min uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-in provider amt-in)))
    (call (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
          id
          token0 token1
          token-in token-out
          share-fee-to
          amount-after-aggregator-fees amt-out-min))
  )
    (print {
      action: "swap-helper-a",
      caller: tx-sender,
      data: {
        amount: amt-in,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: amt-out-min,
        received: call,
        provider: provider,
        id: id,
        token0: token0,
        token1: token1,
        token-in: token-in,
        token-out: token-out,
        share-fee-to: share-fee-to
      }
    })
    (ok call)
  )
)

(define-public (swap-helper-b
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
    (amt-in-max uint) (amt-out uint)
    (provider (optional principal))
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-in provider amt-in-max)))
    (call (try! (contract-call?
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens
                id
                token0 token1
                token-in token-out
                share-fee-to
                amount-after-aggregator-fees amt-out)))
  )
    (print {
      action: "swap-helper-b",
      caller: tx-sender,
      data: {
        amount: amt-in-max,
        amount-after-aggregator-fees: amount-after-aggregator-fees,
        min-received: amt-out,
        received: call,
        provider: provider,
        id: id,
        token0: token0,
        token1: token1,
        token-in: token-in,
        token-out: token-out,
        share-fee-to: share-fee-to
      }
    })
    (ok call)
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