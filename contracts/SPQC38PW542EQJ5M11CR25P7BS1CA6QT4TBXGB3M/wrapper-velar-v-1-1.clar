(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-public (swap-helper-a (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in uint) (amt-out-min uint))
  (let (
    (call (try! (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
          id
          token0 token1
          token-in token-out
          share-fee-to
          amt-in amt-out-min)))
  )
    (ok call)
  )
)

(define-public (swap-helper-b (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in-max uint) (amt-out uint))
  (let (
    (call (try! (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens
          id
          token0 token1
          token-in token-out
          share-fee-to
          amt-in-max amt-out)))
  )
    (ok call)
  )
)