(define-constant OWNER tx-sender)

(define-constant ERR_O (err u1000))
(define-constant ERR_L (err u1001))
(define-constant ERR_Q (err u1002))
(define-constant ERR_F (err u1003))
(define-constant ERR_S (err u1004))
(define-constant ERR_X (err u1005))

(define-constant ERR_ALEX_A (err u2101))
(define-constant ERR_ALEX_B (err u2102))
(define-constant ERR_DIKO_A (err u2201))
(define-constant ERR_DIKO_B (err u2202))
(define-constant ERR_STSW_A (err u2301))
(define-constant ERR_STSW_B (err u2302))

(define-constant T_STX  "a")
(define-constant T_XUSD "b")
(define-constant T_XBTC "c")
(define-constant T_ALEX "d")
(define-constant T_DIKO "e")
(define-constant T_USDA "f")
(define-constant T_STSW "g")
(define-constant T_LBTC "h")
(define-constant T_MIA2 "i")
(define-constant T_NYC2 "j")
(define-constant T_MIA1 "k")
(define-constant T_NYC1 "l")
    

(define-private (wstx-xusd-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 u50000000 (* dx u100) none))))
(ok (get dy r))))

(define-private (xusd-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 u50000000 dx none))))
(ok (/ (get dx r) u100))))


(define-private (wstx-xbtc-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 u50000000 (* dx u100) none))))
(ok (get dy r))))

(define-private (xbtc-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 u50000000 dx none))))
(ok (/ (get dx r) u100))))


(define-private (wstx-alex-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
u50000000 u50000000 (* dx u100) none))))
(ok (get dy r))))

(define-private (alex-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
u50000000 u50000000 dx none))))
(ok (/ (get dx r) u100))))


(define-private (wstx-mia2-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
u50000000 u50000000 (* dx u100) none))))
(ok (/ (get dy r) u100))))

(define-private (mia2-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
u50000000 u50000000 (* dx u100) none))))
(ok (/ (get dx r) u100))))


(define-private (wstx-nyc2-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
u50000000 u50000000 (* dx u100) none))))
(ok (/ (get dy r) u100))))

(define-private (nyc2-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
u50000000 u50000000 (* dx u100) none))))
(ok (/ (get dx r) u100))))


(define-private (alex-usda-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
dx none))))
(ok (/ (get dy r) u100))))

(define-private (usda-alex-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
(* dx u100) none))))
(ok (get dx r))))


(define-public (swap-alex
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)
    (if (is-eq b T_XUSD) (wstx-xusd-a x)
    (if (is-eq b T_XBTC) (wstx-xbtc-a x)
    (if (is-eq b T_ALEX) (wstx-alex-a x)
    (if (is-eq b T_MIA2) (wstx-mia2-a x)
    (if (is-eq b T_NYC2) (wstx-nyc2-a x)
    ERR_ALEX_B)))))
  (if (is-eq a T_XUSD)
    (if (is-eq b T_STX) (xusd-wstx-a x)
    ERR_ALEX_B)
  (if (is-eq a T_XBTC)
    (if (is-eq b T_STX) (xbtc-wstx-a x)
    ERR_ALEX_B)
  (if (is-eq a T_ALEX)
    (if (is-eq b T_STX)  (alex-wstx-a x)
    (if (is-eq b T_USDA) (alex-usda-a x)
    ERR_ALEX_B))
  (if (is-eq a T_USDA)
    (if (is-eq b T_ALEX) (usda-alex-a x)
    ERR_ALEX_B)
  (if (is-eq a T_MIA2)
    (if (is-eq b T_STX) (mia2-wstx-a x)
    ERR_ALEX_B)
  (if (is-eq a T_NYC2)
    (if (is-eq b T_STX) (nyc2-wstx-a x)
    ERR_ALEX_B)
  ERR_ALEX_A)))))))
)


(define-private (wstx-xbtc-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
x u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (xbtc-wstx-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
x u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-diko-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
x u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (diko-wstx-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
x u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-usda-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (usda-wstx-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (xbtc-usda-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (usda-xbtc-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (diko-usda-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (usda-diko-d (x uint))
(let ((r (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-public (swap-diko
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)
    (if (is-eq b T_XBTC) (wstx-xbtc-d x)
    (if (is-eq b T_DIKO) (wstx-diko-d x)
    (if (is-eq b T_USDA) (wstx-usda-d x)
    ERR_DIKO_B)))
  (if (is-eq a T_XBTC)
    (if (is-eq b T_STX)  (xbtc-wstx-d x)
    (if (is-eq b T_USDA) (xbtc-usda-d x)
    ERR_DIKO_B))
  (if (is-eq a T_DIKO)
    (if (is-eq b T_STX)  (diko-wstx-d x)
    (if (is-eq b T_USDA) (diko-usda-d x)
    ERR_DIKO_B))
  (if (is-eq a T_USDA)
    (if (is-eq b T_STX)  (usda-wstx-d x)
    (if (is-eq b T_XBTC) (usda-xbtc-d x)
    (if (is-eq b T_DIKO) (usda-diko-d x)
    ERR_DIKO_B)))
  ERR_DIKO_A))))
)


(define-private (wstx-diko-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (diko-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-usda-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (usda-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-stsw-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (stsw-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-lbtc-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
dx u0))))
(ok (unwrap-panic (element-at r u1)))))
    
(define-private (lbtc-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-mia2-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (mia2-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (wstx-nyc2-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (nyc2-wstx-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-private (stsw-lbtc-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
dx u0))))
(ok (unwrap-panic (element-at r u1)))))

(define-private (lbtc-stsw-s (dx uint))
(let ((r (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
dx u0))))
(ok (unwrap-panic (element-at r u0)))))


(define-public (swap-stsw
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)
    (if (is-eq b T_DIKO) (wstx-diko-s x)
    (if (is-eq b T_USDA) (wstx-usda-s x)
    (if (is-eq b T_STSW) (wstx-stsw-s x)
    (if (is-eq b T_LBTC) (wstx-lbtc-s x)
    (if (is-eq b T_MIA2) (wstx-mia2-s x)
    (if (is-eq b T_NYC2) (wstx-nyc2-s x)
    ERR_STSW_B))))))
  (if (is-eq a T_DIKO)
    (if (is-eq b T_STX) (diko-wstx-s x)
    ERR_STSW_B)
  (if (is-eq a T_USDA)
    (if (is-eq b T_STX) (usda-wstx-s x)
    ERR_STSW_B)
  (if (is-eq a T_STSW)
    (if (is-eq b T_STX)  (stsw-wstx-s x)
    (if (is-eq b T_LBTC) (stsw-lbtc-s x)
    ERR_STSW_B))
  (if (is-eq a T_LBTC)
    (if (is-eq b T_STX)  (lbtc-wstx-s x)
    (if (is-eq b T_STSW) (lbtc-stsw-s x)
    ERR_STSW_B))
  (if (is-eq a T_MIA2)
    (if (is-eq b T_STX) (mia2-wstx-s x)
    ERR_STSW_B)
  (if (is-eq a T_NYC2)
    (if (is-eq b T_STX) (nyc2-wstx-s x)
    ERR_STSW_B)
  ERR_STSW_A)))))))
)


(define-public (swap
  (s (string-ascii 1))
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq s "a") (swap-alex a b x)
  (if (is-eq s "b") (swap-diko a b x)
  (if (is-eq s "c") (swap-stsw a b x)
  ERR_S)))
)

(define-private (t
  (q (string-ascii 3))
  (v (list 21 (response uint uint)))
)
  (match (unwrap-panic (element-at v (- (len v) u1)))
    x (let
        (
          (s (unwrap-panic (element-at q u0)))
          (a (unwrap-panic (element-at q u1)))
          (b (unwrap-panic (element-at q u2)))
          (y (swap s a b x))
        )
        (unwrap-panic (as-max-len? (append v y) u21))
      )
    x (unwrap-panic (as-max-len? (append v (err x)) u21))
  )
)

(define-private (t2
  (q (response uint uint))
  (v (list 21 uint))
)
  (unwrap-panic (as-max-len? (append v (unwrap-panic q)) u21))
)

(define-private (xfer
  (a (string-ascii 1))
  (amt uint)
  (src principal)
  (dst principal)
)
  (if (is-eq a T_STX) (stx-transfer? amt src dst)
  (if (is-eq a T_XUSD) (contract-call? 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD     transfer amt src dst none)
  (if (is-eq a T_XBTC) (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer amt src dst none)
  (if (is-eq a T_ALEX) (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer amt src dst none)
  (if (is-eq a T_DIKO) (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token  transfer amt src dst none)
  (if (is-eq a T_USDA) (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token      transfer amt src dst none)
  (if (is-eq a T_STSW) (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a  transfer amt src dst none)
  (if (is-eq a T_LBTC) (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c  transfer amt src dst none)
  (if (is-eq a T_MIA2) (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2      transfer amt src dst none)
  (if (is-eq a T_NYC2) (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer amt src dst none)
  ERR_X))))))))))
)

(define-public (z
  (p (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (let
    (
      (sender tx-sender)
      (f (unwrap! (element-at p u0) ERR_Q))
      (l (unwrap! (element-at p (- (len p) u1)) ERR_Q))
      (a (unwrap! (element-at f u1) ERR_Q))
      (b (unwrap! (element-at l u2) ERR_Q))
    )
    (asserts! (is-eq tx-sender OWNER) ERR_O)
    (try! (xfer a x tx-sender (as-contract tx-sender)))
    (as-contract
    (let
      (
        (vals (fold t p (list (ok x))))
        (last (unwrap! (element-at vals (- (len vals) u1)) ERR_F))
      )
      (match last
        y (begin
;;            (asserts! (>= y Y) (err y))
            (try! (xfer b y tx-sender sender))
            (ok (fold t2 vals (list)))
          )
        y (err y)
      )
    )
    )
  )
)