(define-constant ONE_8 (pow u10 u8))

(define-constant ERR_LIQUIDITY (err u10001))
(define-constant ERR_SLIPPAGE  (err u10002))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8)
)

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b))
)

(define-private (nyc2-stx-alex (dy uint))
(match
  (contract-call?
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
    u50000000 (* dy u100) none
  )
  r (ok (/ (get dx r) u100))
  e (err e)
))

(define-private (nyc2-stx-stsw (dy uint))
(match
  (contract-call?
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
    'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
    dy u0
  )
  r (ok (unwrap-panic (element-at r u0)))
  e (err e)
))

(define-public (nyc-stx (dy uint) (min_dx (optional uint)))
(let
  (
    (sender tx-sender)
  )
  (try! (contract-call?
    'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer dy tx-sender (as-contract tx-sender) none)
  )
  (as-contract
  (let
  (
    (pool-alex (try! (contract-call?
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 get-pool-details
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
      u50000000 u50000000
    )))
    
    (pool-stsw (unwrap-panic (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7 get-lp-data
    )))
    
    (bx1 (get balance-x pool-alex))
    (by1 (get balance-y pool-alex))
    (bx2 (* (get balance-x pool-stsw) u100))
    (by2 (* (get balance-y pool-stsw) u100))
    
    (dy8 (* dy u100))

    (x (+ bx1 bx2))
    (y (+ by1 by2))
 
    (dy_est (/ (* dy8 u997) u1000))
    (dx_est (div-down (mul-down x dy_est) (+ y dy_est)))

    (price (div-down (+ y dy_est) (- x dx_est)))

    (dy1 (match (contract-call?
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.weighted-equation-v1-01 get-y-given-price
      bx1 by1 u50000000 u50000000 price)
      r (if (< r dy8) (/ r u100) dy)
      e u0)
    )
    (dy2 (if (< dy1 dy) (- dy dy1) u0))
 
    (dx1 (if (> dy1 u0) (try! (nyc2-stx-alex dy1)) u0))
    (dx2 (if (> dy2 u0) (try! (nyc2-stx-stsw dy2)) u0))
    (dx (+ dx1 dx2))
  )
    (asserts! (>= dx (default-to u0 min_dx)) ERR_SLIPPAGE)
    (try! (stx-transfer? dx tx-sender sender))
    (ok (list dx dx1 dy1 dx2 dy2))
  )
  )
))