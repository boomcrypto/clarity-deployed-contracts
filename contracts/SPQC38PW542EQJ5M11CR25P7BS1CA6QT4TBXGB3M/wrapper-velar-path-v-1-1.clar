;; wrapper-velar-path-v-1-1

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait univ2v2-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait univ2v2-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait curve-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait curve-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)
(use-trait ststx-pool-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-trait_ststx.curve-pool-trait)
(use-trait ststx-proxy-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-trait_ststx.curve-proxy-trait)

(define-constant NUM_A u1000000)
(define-constant NUM_B u100)

(define-public (apply
    (path (list 4 {a: (string-ascii 1), b: principal, c: uint, d: principal, e: principal, f: bool}))
    (amt-in uint)
    (token1 (optional <ft-trait>)) (token2 (optional <ft-trait>)) (token3 (optional <ft-trait>))
    (token4 (optional <ft-trait>)) (token5 (optional <ft-trait>))
    (share-fee-to (optional <share-fee-to-trait>))
    (univ2v2-pool-1 (optional <univ2v2-pool-trait>)) (univ2v2-pool-2 (optional <univ2v2-pool-trait>))
    (univ2v2-pool-3 (optional <univ2v2-pool-trait>)) (univ2v2-pool-4 (optional <univ2v2-pool-trait>))
    (univ2v2-fees-1 (optional <univ2v2-fees-trait>)) (univ2v2-fees-2 (optional <univ2v2-fees-trait>))
    (univ2v2-fees-3 (optional <univ2v2-fees-trait>)) (univ2v2-fees-4 (optional <univ2v2-fees-trait>))
    (curve-pool-1 (optional <curve-pool-trait>)) (curve-pool-2 (optional <curve-pool-trait>))
    (curve-pool-3 (optional <curve-pool-trait>)) (curve-pool-4 (optional <curve-pool-trait>))
    (curve-fees-1 (optional <curve-fees-trait>)) (curve-fees-2 (optional <curve-fees-trait>))
    (curve-fees-3 (optional <curve-fees-trait>)) (curve-fees-4 (optional <curve-fees-trait>))
    (ststx-pool-1 (optional <ststx-pool-trait>)) (ststx-pool-2 (optional <ststx-pool-trait>))
    (ststx-pool-3 (optional <ststx-pool-trait>)) (ststx-pool-4 (optional <ststx-pool-trait>))
    (ststx-proxy-1 (optional <ststx-proxy-trait>)) (ststx-proxy-2 (optional <ststx-proxy-trait>))
    (ststx-proxy-3 (optional <ststx-proxy-trait>)) (ststx-proxy-4 (optional <ststx-proxy-trait>))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging apply
                  path amt-in
                  token1 token2 token3 token4 token5
                  share-fee-to
                  univ2v2-pool-1 univ2v2-pool-2 univ2v2-pool-3 univ2v2-pool-4
                  univ2v2-fees-1 univ2v2-fees-2 univ2v2-fees-3 univ2v2-fees-4
                  curve-pool-1 curve-pool-2 curve-pool-3 curve-pool-4
                  curve-fees-1 curve-fees-2 curve-fees-3 curve-fees-4
                  ststx-pool-1 ststx-pool-2 ststx-pool-3 ststx-pool-4
                  ststx-proxy-1 ststx-proxy-2 ststx-proxy-3 ststx-proxy-4)))
  )
    (ok (get amt-out (get swap4 swap-a)))
  )
)

(define-public (swap-univ2v2
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (univ2v2-pool <univ2v2-pool-trait>) (univ2v2-fees <univ2v2-fees-trait>)
  )
  (let (
    (edge {a: "v", b: (contract-of univ2v2-pool), c: u0, d: (contract-of token-in), e: (contract-of token-out), f: false})
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-univ2v2
                  edge amt-in
                  token-in token-out
                  univ2v2-pool univ2v2-fees)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-public (swap-curve
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (curve-pool <curve-pool-trait>) (curve-fees <curve-fees-trait>)
  )
  (let (
    (edge {a: "c", b: (contract-of curve-pool), c: u0, d: (contract-of token-in), e: (contract-of token-out), f: false})
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-curve
                  edge amt-in
                  token-in token-out
                  curve-pool curve-fees)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-public (swap-usdh
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (usdh-pool <curve-pool-trait>) (usdh-fees <curve-fees-trait>)
  )
  (let (
    (edge {a: "h", b: (contract-of usdh-pool), c: u0, d: (contract-of token-in), e: (contract-of token-out), f: false})
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-curve
                  edge amt-in
                  token-in token-out
                  usdh-pool usdh-fees)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-public (swap-ststx
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (ststx-pool <ststx-pool-trait>) (curve-fees <curve-fees-trait>)
    (ststx-proxy <ststx-proxy-trait>)
  )
  (let (
    (edge {a: "s", b: (contract-of ststx-pool), c: u0, d: (contract-of token-in), e: (contract-of token-out), f: false})
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-ststx
                  edge amt-in
                  token-in token-out
                  ststx-pool curve-fees ststx-proxy)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-public (quote-univ2v2
    (amount uint)
    (token-in principal) (token-out principal)
    (univ2v2-pool <univ2v2-pool-trait>)
    (swap-fee {num: uint, den: uint})
  )
  (let (
    (pool-data (try! (contract-call? univ2v2-pool get-pool)))
    (swaps-reversed (and (is-eq token-in (get token1 pool-data)) (is-eq token-out (get token0 pool-data))))
    (reserves {in: (if swaps-reversed (get reserve1 pool-data) (get reserve0 pool-data)), out: (if swaps-reversed (get reserve0 pool-data) (get reserve1 pool-data))})
    (amount-adjusted (/ (* amount (get num swap-fee)) (get den swap-fee)))
    (quote-a (try! (contract-call?
                   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx
                   (get out reserves) (get in reserves)
                   amount-adjusted)))
  )
    (ok quote-a)
  )
)

(define-public (quote-curve
    (amount uint)
    (token-in principal) (token-out principal)
    (curve-pool <curve-pool-trait>)
    (swap-fee {num: uint, den: uint})
  )
  (let (
    (pool-data (try! (contract-call? curve-pool get-pool)))
    (swaps-reversed (and (is-eq token-in (get token1 pool-data)) (is-eq token-out (get token0 pool-data))))
    (reserves {in: (if swaps-reversed (get reserve1 pool-data) (get reserve0 pool-data)), out: (if swaps-reversed (get reserve0 pool-data) (get reserve1 pool-data))})
    (amount-adjusted (/ (* amount (get num swap-fee)) (get den swap-fee)))
    (quote-a (try! (contract-call?
                   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
                   (get out reserves) (get in reserves)
                   amount-adjusted u0 (get A pool-data))))
  )
    (ok quote-a)
  )
)

(define-public (quote-usdh
    (amount uint)
    (token-in principal) (token-out principal)
    (usdh-pool <curve-pool-trait>)
    (swap-fee {num: uint, den: uint})
    (usdh-in bool)
  )
  (let (
    (pool-data (try! (contract-call? usdh-pool get-pool)))
    (swaps-reversed (and (is-eq token-in (get token1 pool-data)) (is-eq token-out (get token0 pool-data))))
    (reserves {in: (if swaps-reversed (get reserve1 pool-data) (get reserve0 pool-data)), out: (if swaps-reversed (get reserve0 pool-data) (get reserve1 pool-data))})
    (reserves-lifted {in: (if usdh-in (lift-amount (get in reserves)) (get in reserves)), out: (if usdh-in (get out reserves) (lift-amount (get out reserves)))})
    (amount-adjusted (/ (* amount (get num swap-fee)) (get den swap-fee)))
    (amount-lifted (if usdh-in (lift-amount amount-adjusted) amount-adjusted))
    (quote-a (try! (contract-call? 
                   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
                   (get out reserves-lifted) (get in reserves-lifted)
                   amount-lifted u0 (get A pool-data))))
  )
    (ok (if usdh-in quote-a (lower-amount quote-a)))
  )
)

(define-public (quote-ststx
    (amount uint)
    (token-in principal) (token-out principal)
    (ststx-pool <ststx-pool-trait>) (ststx-proxy <ststx-proxy-trait>)
    (swap-fee {num: uint, den: uint})
    (stx-in bool)
  )
  (let (
    (pool-data (try! (contract-call? ststx-pool get-pool)))
    (pool-ratio (try! (contract-call? ststx-proxy get-ratio)))
    (swaps-reversed (and (is-eq token-in (get token1 pool-data)) (is-eq token-out (get token0 pool-data))))
    (reserves {in: (if swaps-reversed (get reserve1 pool-data) (get reserve0 pool-data)), out: (if swaps-reversed (get reserve0 pool-data) (get reserve1 pool-data))})
    (amount-adjusted (/ (* amount (get num swap-fee)) (get den swap-fee)))
    (amount-adjusted-ratio (if stx-in (divide-ratio amount-adjusted pool-ratio) (multiply-ratio amount-adjusted pool-ratio)))
    (quote-a (try! (contract-call?
                   'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
                   (get out reserves) (get in reserves)
                   amount-adjusted-ratio u0 (get A pool-data))))
  )
    (ok quote-a)
  )
)

(define-private (multiply-ratio (amount uint) (ratio uint))
  (/ (* amount ratio) NUM_A)
)

(define-private (divide-ratio (amount uint) (ratio uint))
 (/ (* amount NUM_A) ratio)
)

(define-private (lift-amount (amount uint))
  (/ amount NUM_B)
)

(define-private (lower-amount (amount uint))
  (* amount NUM_B)
)