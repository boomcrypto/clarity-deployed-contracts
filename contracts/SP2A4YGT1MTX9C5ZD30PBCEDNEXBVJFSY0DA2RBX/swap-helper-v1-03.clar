(define-constant OWNER tx-sender)

(define-constant ERR_V u1001)
(define-constant ERR_W u1002)
(define-constant ERR_Q u1003)
(define-constant ERR_F u1004)
(define-constant ERR_L u1005)
(define-constant ERR_S (err u1006))
(define-constant ERR_X (err u1007))
(define-constant ERR_O u1008)

(define-constant ERR_AA (err u2101))
(define-constant ERR_AB (err u2102))
(define-constant ERR_BA (err u2201))
(define-constant ERR_BB (err u2202))
(define-constant ERR_CA (err u2301))
(define-constant ERR_CB (err u2302))

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
(define-constant T_WLSH "m")
(define-constant T_atALEX "n")
(define-constant T_VIBES "o")

(define-private (wstx-xusd-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 (* x u100) none)
r (ok (get dy r))
e (err e)))

(define-private (xusd-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 x none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (wstx-xbtc-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 (* x u100) none)
r (ok (get dy r))
e (err e)))

(define-private (xbtc-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 x none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (wstx-alex-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
u50000000 (* x u100) none)
r (ok (get dy r))
e (err e)))

(define-private (alex-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
u50000000 x none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (wstx-mia2-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
u50000000 (* x u100) none)
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (mia2-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia
u50000000 (* x u100) none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (wstx-nyc2-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-wstx-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
u50000000 (* x u100) none)
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (nyc2-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
u50000000 (* x u100) none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (alex-usda-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
x none)
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (usda-alex-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
(* x u100) none)
r (ok (get dx r))
e (err e)))


(define-private (xusd-usda-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
u500000 x (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (usda-xusd-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
u500000 (* x u100) (some u0))
r (ok (get dx r))
e (err e)))


(define-private (alex-diko-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko
u100000000 x (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (diko-alex-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko
u100000000 (* x u100) (some u0))
r (ok (get dx r))
e (err e)))


(define-private (wstx-wlsh-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi
u100000000 (* x u100) (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (wlsh-wstx-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wcorgi
u100000000 (* x u100) (some u0))
r (ok (/ (get dx r) u100))
e (err e)))

;;M;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private (alex-atalex-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
x none)
r (ok (/ (get dx r) u100))
e (err e)))

(define-private (atalex-alex-a (x uint))
(match (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.simple-weight-pool-alex swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
x none)
r (ok (/ (get dx r) u100))
e (err e)))


(define-private (swap-a
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
    (if (is-eq b T_WLSH) (wstx-wlsh-a x)
    ERR_AB))))))
  (if (is-eq a T_XUSD)
    (if (is-eq b T_STX)  (xusd-wstx-a x)
    (if (is-eq b T_USDA) (xusd-usda-a x)
    ERR_AB))
  (if (is-eq a T_XBTC)
    (if (is-eq b T_STX) (xbtc-wstx-a x)
    ERR_AB)
  (if (is-eq a T_atALEX)
    (if (is-eq b T_ALEX) (atalex-alex-a x)  ;;M
    ERR_AB)
  (if (is-eq a T_ALEX)
    (if (is-eq b T_STX)  (alex-wstx-a x)
    (if (is-eq b T_DIKO) (alex-diko-a x)
    (if (is-eq b T_USDA) (alex-usda-a x)
    (if (is-eq b T_atALEX) (alex-atalex-a x)  ;;M
    ERR_AB))))                              ;;M
  (if (is-eq a T_DIKO)
    (if (is-eq b T_ALEX) (diko-alex-a x)
    ERR_AB)
  (if (is-eq a T_USDA)
    (if (is-eq b T_XUSD) (usda-xusd-a x)
    (if (is-eq b T_ALEX) (usda-alex-a x)
    ERR_AB))
  (if (is-eq a T_MIA2)
    (if (is-eq b T_STX) (mia2-wstx-a x)
    ERR_AB)
  (if (is-eq a T_NYC2)
    (if (is-eq b T_STX) (nyc2-wstx-a x)
    ERR_AB)
  (if (is-eq a T_WLSH)
    (if (is-eq b T_STX) (wlsh-wstx-a x)
    ERR_AB)
  ERR_AA))))))))))                          ;;M
)


(define-private (wstx-xbtc-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (xbtc-wstx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-diko-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (diko-wstx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-usda-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-wstx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-wlsh-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (wlsh-wstx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (xbtc-usda-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-xbtc-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (diko-usda-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-diko-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (swap-b
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)
    (if (is-eq b T_XBTC) (wstx-xbtc-d x)
    (if (is-eq b T_DIKO) (wstx-diko-d x)
    (if (is-eq b T_USDA) (wstx-usda-d x)
    (if (is-eq b T_WLSH) (wstx-wlsh-d x)
    ERR_BB))))
  (if (is-eq a T_XBTC)
    (if (is-eq b T_STX)  (xbtc-wstx-d x)
    (if (is-eq b T_USDA) (xbtc-usda-d x)
    ERR_BB))
  (if (is-eq a T_DIKO)
    (if (is-eq b T_STX)  (diko-wstx-d x)
    (if (is-eq b T_USDA) (diko-usda-d x)
    ERR_BB))
  (if (is-eq a T_USDA)
    (if (is-eq b T_STX)  (usda-wstx-d x)
    (if (is-eq b T_XBTC) (usda-xbtc-d x)
    (if (is-eq b T_DIKO) (usda-diko-d x)
    ERR_BB)))
  (if (is-eq a T_WLSH)
    (if (is-eq b T_STX)  (wlsh-wstx-d x)
    ERR_BB)
  ERR_BA)))))
)


(define-private (wstx-diko-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (diko-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-usda-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (stsw-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-lbtc-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (lbtc-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-mia2-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (mia2-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (wstx-nyc2-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (nyc2-wstx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (stsw-lbtc-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (lbtc-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))


(define-private (stsw-wlsh-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (wlsh-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

;;M;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private (stsw-alex-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (alex-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (stsw-atalex-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbwkf4h0n
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (atalex-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbwkf4h0n
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (stsw-vibes-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (vibes-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (stx-vibes-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

(define-private (vibes-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))

;;M;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (swap-c
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
    (if (is-eq b T_VIBES) (stx-vibes-s x)   ;;M
    ERR_CB)))))))                           ;;M
  (if (is-eq a T_DIKO)
    (if (is-eq b T_STX) (diko-wstx-s x)
    ERR_CB)
  (if (is-eq a T_USDA)
    (if (is-eq b T_STX) (usda-wstx-s x)
    ERR_CB)
  (if (is-eq a T_STSW)
    (if (is-eq b T_STX)  (stsw-wstx-s x)
    (if (is-eq b T_LBTC) (stsw-lbtc-s x)
    (if (is-eq b T_WLSH) (stsw-wlsh-s x)
    (if (is-eq b T_VIBES) (stsw-vibes-s x)  ;;M
    (if (is-eq b T_ALEX) (stsw-alex-s x)    ;;M
    (if (is-eq b T_WLSH) (stsw-atalex-s x)  ;;M
    ERR_CB))))))                            ;;M
  (if (is-eq a T_LBTC)
    (if (is-eq b T_STX)  (lbtc-wstx-s x)
    (if (is-eq b T_STSW) (lbtc-stsw-s x)
    ERR_CB))
  (if (is-eq a T_VIBES)                     ;;M
      (if (is-eq b T_STX)  (vibes-stx-s x)  ;;M
      (if (is-eq b T_STSW) (vibes-stsw-s x) ;;M
      ERR_CB))                              ;;M
  (if (is-eq a T_MIA2)
    (if (is-eq b T_STX) (mia2-wstx-s x)
    ERR_CB)
  (if (is-eq a T_NYC2)
    (if (is-eq b T_STX) (nyc2-wstx-s x)
    ERR_CB)
  (if (is-eq a T_WLSH)
    (if (is-eq b T_STSW) (wlsh-stsw-s x)
    ERR_CB)
  (if (is-eq a T_atALEX)                        ;;M
      (if (is-eq b T_STSW) (atalex-stsw-s x)    ;;M
      ERR_CB)                                   ;;M
  (if (is-eq a T_ALEX)                          ;;M
      (if (is-eq b T_STSW) (alex-stsw-s x)      ;;M
      ERR_CB)                                   ;;M
  ERR_CA)))))))))))                             ;;M
)


(define-private (swap
  (s (string-ascii 1))
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq s "a") (swap-a a b x)
  (if (is-eq s "b") (swap-b a b x)
  (if (is-eq s "c") (swap-c a b x)
  ERR_S)))
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
  (if (is-eq a T_WLSH) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amt src dst none)
  ERR_X)))))))))))
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
    x v
  )
)

(define-private (u
  (q (response uint uint))
)
  (match q y y e e)
)

(define-private (ex
  (p (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (let
    (
      (v (fold t p (list (ok x))))
      (w (map u v))
    )
    (match (unwrap-panic (element-at v (- (len v) u1)))
      y (begin
          (asserts! (>= y Y) (err (append w ERR_L)))
          (ok w)
        )
      y (err w)
    )
  )
)

(define-private (z
  (p (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (ex p x Y)
)

(define-private (c
  (p (list 20 (string-ascii 3)))
  (x uint)
)
  (z p x (+ x u1))
)

(define-public (Z
  (p (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (let
    (
      (sender tx-sender)
      (f (unwrap-panic (element-at p u0)))
      (l (unwrap-panic (element-at p (- (len p) u1))))
      (a (unwrap-panic (element-at f u1)))
      (b (unwrap-panic (element-at l u2)))
    )
    (asserts! (is-eq tx-sender OWNER) (err (list ERR_O)))
    (unwrap! (xfer a x tx-sender (as-contract tx-sender)) (err (list ERR_V)))
    (as-contract
    (match (ex p x Y)
        v (let ((y (unwrap-panic (element-at v (- (len v) u1)))))
            (unwrap! (xfer b y tx-sender sender) (err (append v ERR_W)))
            (ok v)
          )
        v (err v)
    )
    )
  )
)

(define-public (swap-helper
  (p (list 20 (string-ascii 3)))
  (x uint)
)
  (begin
    (asserts! (is-eq tx-sender OWNER) (err (list ERR_O)))
    (Z p x (+ x u10000))
  )
)
