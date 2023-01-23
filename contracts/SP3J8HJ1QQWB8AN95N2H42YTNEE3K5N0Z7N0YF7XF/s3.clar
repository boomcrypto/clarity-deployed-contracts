(impl-trait .s-trait.s-trait)

(use-trait token-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(use-trait lp-trait    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)
  
(define-constant err-tok u2000)
  
(define-private (ex
  (y2x bool)
  (d uint)
  (x <token-trait>)
  (y <token-trait>)
  (lp <lp-trait>) 
) 
  (let
    (
      (v (if y2x
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x x y lp d u0))
        (try! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y x y lp d u0))
      ))
    )
    (ok (if y2x
      (unwrap-panic (element-at v u0))
      (unwrap-panic (element-at v u1))
    ))
  )
) 
  
(define-private (wstx-stsw (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
))

(define-private (wstx-lbtc (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
))

(define-private (stsw-lbtc (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
))

(define-private (wstx-usda (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
))

(define-private (wstx-diko (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
))

(define-private (wstx-mia1 (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kmnws5cgl
))

(define-private (wstx-nyc1 (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt8k62b86
))

(define-private (wstx-mia2 (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
))

(define-private (wstx-nyc2 (y2x bool) (d uint))
  (ex y2x d
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
  'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
  'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
))

(define-public (z
  (a uint)
  (b uint)
  (x uint)
)
  (if (is-eq a u1) ;; stx
    (if (is-eq b u5)  (wstx-diko false x)
    (if (is-eq b u6)  (wstx-usda false x)
    (if (is-eq b u7)  (wstx-stsw false x)
    (if (is-eq b u8)  (wstx-lbtc false x)
    (if (is-eq b u9)  (wstx-mia2 false x)
    (if (is-eq b u10) (wstx-nyc2 false x)
    (if (is-eq b u11) (wstx-mia1 false x)
    (if (is-eq b u12) (wstx-nyc1 false x)
    (err err-tok)
    ))))))))
  (if (is-eq a u5) ;; diko
    (if (is-eq b u1) (wstx-diko true x)
    (err err-tok)
    )
  (if (is-eq a u6) ;; usda
    (if (is-eq b u1) (wstx-usda true x)
    (err err-tok)
    )
  (if (is-eq a u7) ;; stsw
    (if (is-eq b u1) (wstx-stsw true x)
    (if (is-eq b u8) (stsw-lbtc false x)
    (err err-tok)
    ))
  (if (is-eq a u8) ;; lbtc
    (if (is-eq b u1) (wstx-lbtc true x)
    (if (is-eq b u7) (stsw-lbtc true x)
    (err err-tok)
    ))
  (if (is-eq a u9) ;; mia-2
    (if (is-eq b u1) (wstx-mia2 true x)
    (err err-tok)
    )
  (if (is-eq a u10) ;; nyc-2
    (if (is-eq b u1) (wstx-nyc2 true x)
    (err err-tok)
    )
  (if (is-eq a u11) ;; mia-1
    (if (is-eq b u1) (wstx-mia1 true x)
    (err err-tok)
    )
  (if (is-eq a u12) ;; nyc-1
    (if (is-eq b u1) (wstx-nyc1 true x)
    (err err-tok)
    )
  (err err-tok)
  )))))))))
)