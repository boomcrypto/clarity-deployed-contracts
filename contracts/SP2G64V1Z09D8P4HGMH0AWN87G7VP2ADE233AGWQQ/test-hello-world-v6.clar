
(define-constant ERR-TEST u40401)
(define-data-var contract-owner principal tx-sender)

(define-data-var counter int 0)
(define-data-var counter2 int 0)

(define-public (say-hi)
  (ok "hello world")
)

(define-read-only (echo-number (val int))
  (ok val)
)

(define-read-only (get-counter)
  (ok (var-get counter))
)

(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-public (decrement)
  (begin
    (var-set counter (- (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-read-only (get-counter-2)
  (ok (var-get counter2))
)

(define-public (increment-2)
  (begin
    (var-set counter2 (+ (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-public (decrement-2)
  (begin
    (var-set counter2 (- (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-public (swap-wstx-usda (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-usda-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)

(define-public (swap-wstx-diko (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c dx u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-public (swap-diko-wstx (dx uint))
  (let ((r (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c dx u0))))
  (ok (unwrap-panic (element-at r u0))))
)
