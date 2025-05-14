---
title: "Trait outstanding-aqua-hawk"
draft: true
---
```
;; wrapper-velar-path-v-1-1

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait univ2v2-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait univ2v2-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)
(use-trait curve-pool-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait curve-fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)
(use-trait ststx-pool-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-trait_ststx.curve-pool-trait)
(use-trait ststx-proxy-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-trait_ststx.curve-proxy-trait)

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
    (ok swap-a)
  )
)

(define-public (swap-univ2
    (edge {a: (string-ascii 1), b: principal, c: uint, d: principal, e: principal, f: bool})
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-univ2
                  edge amt-in
                  token-in token-out
                  share-fee-to)))
  )
    (ok swap-a)
  )
)

(define-public (swap-univ2v2
    (edge {a: (string-ascii 1), b: principal, c: uint, d: principal, e: principal, f: bool})
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (univ2v2-pool <univ2v2-pool-trait>) (univ2v2-fees <univ2v2-fees-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-univ2v2
                  edge amt-in
                  token-in token-out
                  univ2v2-pool univ2v2-fees)))
  )
    (ok swap-a)
  )
)

(define-public (swap-curve
    (edge {a: (string-ascii 1), b: principal, c: uint, d: principal, e: principal, f: bool})
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (curve-pool <curve-pool-trait>) (curve-fees <curve-fees-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-curve
                  edge amt-in
                  token-in token-out
                  curve-pool curve-fees)))
  )
    (ok swap-a)
  )
)

(define-public (swap-ststx
    (edge {a: (string-ascii 1), b: principal, c: uint, d: principal, e: principal, f: bool})
    (amt-in uint)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (ststx-pool <ststx-pool-trait>) (curve-fees <curve-fees-trait>)
    (ststx-proxy <ststx-proxy-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging swap-ststx
                  edge amt-in
                  token-in token-out
                  ststx-pool curve-fees ststx-proxy)))
  )
    (ok swap-a)
  )
)
```
