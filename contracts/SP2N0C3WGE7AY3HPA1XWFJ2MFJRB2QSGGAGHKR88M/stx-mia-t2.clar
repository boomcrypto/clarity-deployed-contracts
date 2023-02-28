(define-constant ONE_8 (pow u10 u8))

(define-constant ERR_LIQUIDITY (err u10001))
(define-constant ERR_SLIPPAGE  (err u10002))

(define-private (mul-down (a uint) (b uint))
  (/ (* a b) ONE_8)
)

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b))
)

(define-private (alex (dx uint))
(match
  (contract-call?
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
    u50000000 (* dx u100) none
  )
  r (ok (/ (get dy r) u100))
  e (err e)
))

(define-private (stsw (dx uint))
(match
  (contract-call?
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
    'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
    dx u0
  )
  r (ok (unwrap-panic (element-at r u1)))
  e (err e)
))

(define-public (stx-mia (dx uint) (min_dy (optional uint)))
(let
  (
    (sender tx-sender)
  )
  (try! (stx-transfer? dx tx-sender (as-contract tx-sender)))
  (as-contract
  (let
  (
    (pool-alex (try! (contract-call?
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 get-pool-details
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
      u50000000 u50000000
    )))

    (pool-stsw (unwrap-panic (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773 get-lp-data
    )))

    (x1 (get balance-x pool-alex))
    (y1 (get balance-y pool-alex))
    (x2 (* (get balance-x pool-stsw) u100))
    (y2 (* (get balance-y pool-stsw) u100))
    (x (+ x1 x2))
    (y (+ y1 y2))

    (dx8 (* dx u100))

    (dx_est (/ (* dx8 u997) u1000))
    (dy_est (div-down (mul-down y dx_est) (+ x dx_est)))
    (price (div-down (- y dy_est) (+ x dx_est)))

    (dx1 (match (contract-call?
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.weighted-equation-v1-01 get-x-given-price
      x1 y1 u50000000 u50000000 price)
      r (if (< r dx8) (/ r u100) dx)
      e u0)
    )
    (dx2 (if (< dx1 dx) (- dx dx1) u0))

    (dy1 (if (> dx1 u0) (try! (alex dx1)) u0))
    (dy2 (if (> dx2 u0) (try! (stsw dx2)) u0))
    (dy (+ dy1 dy2))
  )
    (asserts! (>= dy (default-to u0 min_dy)) ERR_SLIPPAGE)
    (try! (contract-call?
      'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer dy tx-sender sender none)
    )
    (ok (list dy dx1 dy1 dx2 dy2))
  )
  )
))