;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait       'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-lp-token-trait_v1_0_0.curve-lp-token-trait)
(use-trait fees-trait     'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-fees-trait_v1_0_0.curve-fees-trait)
(use-trait proxy-trait    'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-proxy-trait_ststx.curve-proxy-trait)

(impl-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-trait_ststx.curve-pool-trait)

(define-constant STSTX-TOKEN    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant STSTXBTC-TOKEN 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant RESERVE-CONTRACT 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1)

(define-constant pool
  {
  symbol        : "",
  token0        : STSTX-TOKEN,
  token1        : STSTXBTC-TOKEN,
  lp-token      : tx-sender,
  fees          : .curve-fees-dummy,
  A             : u0,
  reserve0      : u0,
  reserve1      : u0,
  block-height  : u0,
  burn-block-height: u0,
})

(define-constant res
  {op         : "noop",
  user        : tx-sender,
  pool        : pool,
  amt0        : u0,
  amt1        : u0,
  liquidity   : u0,
  total-supply: u0,
})

(define-read-only (do-get-pool) pool)

;; =================================================================================

(define-public (swap
   (token-in        <ft-trait>)
   (token-out       <ft-trait>)
   (curve-fees      <fees-trait>)
   (ststx-proxy     <proxy-trait>) ;;not used
   (amt-in          uint)
   (amt-out-desired uint))

 (let ((amt-out
        (if (is-eq (contract-of token-in) STSTX-TOKEN)
          (try!
            (contract-call?
              'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1
              swap-ststx-for-ststxbtc
              amt-in
              RESERVE-CONTRACT
              ))
          (try!
            (contract-call?
              'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.swap-ststx-ststxbtc-v1
              swap-ststxbtc-for-ststx
              amt-in
              RESERVE-CONTRACT
              )) )))
  (ok
    {op :  "swap",
    user: tx-sender,
    pool: pool,
    amt-in          : amt-in,
    amt-out-desired : amt-out-desired,
    amt-out         : amt-out,
    amt-in-adjusted : u0,
    amt-fee-lps     : u0,
    amt-fee-protocol: u0,
    }
  )))

(define-public (mint
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (proxy    <proxy-trait>)
    (amt0_    uint)
    (amt1_    uint))
  (err u103)
)

(define-public (burn
    (token0    <ft-trait>)
    (token1    <ft-trait>)
    (lp-token  <lp-token-trait>)
    (liquidity uint))
  (err u105)
)

(define-read-only (get-pool) (ok pool))

(define-public (init
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (fees     <fees-trait>)
    (A         uint)
    (symbol   (string-ascii 32)))
  (err u101)
)
