
(define-constant OWNER tx-sender)

(define-constant ERR_HLEX_A (err u2101))
(define-constant ERR_HLEX_B (err u2102))
(define-constant ERR_DIKO_A (err u2201))
(define-constant ERR_DIKO_B (err u2202))
(define-constant ERR_STSW_A (err u2301))
(define-constant ERR_STSW_B (err u2302))
(define-constant ERR_VELAR_A (err u2401))
(define-constant ERR_VELAR_B (err u2402))
(define-constant ERR_IC (err u10000))

(define-constant ERR_V u1001)
(define-constant ERR_W u1002)
(define-constant ERR_Q u1003)
(define-constant ERR_F u1004)
(define-constant ERR_L u1005)
(define-constant ERR_S (err u1006))
(define-constant ERR_X (err u1007))
(define-constant ERR_O u1008)

(define-constant STX "a")
(define-constant LEO "b")
(define-constant VELAR "c")
(define-constant LONG "d")
(define-constant aBTC "p")
(define-constant STSW "f")
(define-constant WELSH "g")
(define-constant MIA2 "h")
(define-constant NYC2 "i")
(define-constant DIKO "j")
(define-constant USDA "k")
(define-constant VIBES "l")
(define-constant lBTC "m")
(define-constant ALEX "n")
(define-constant XBTC "o")



(define-private (xfer
  (a (string-ascii 1))
  (amt uint)
  (src principal)
  (dst principal)
)
  (if (is-eq a STX) (stx-transfer? amt src dst)
  (if (is-eq a LEO) (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token transfer amt src dst none)
  (if (is-eq a VELAR) (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar transfer amt src dst none)
  (if (is-eq a LONG) (contract-call? 'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin transfer amt src dst none)
  (if (is-eq a aBTC) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer amt src dst none)
  (if (is-eq a STSW) (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer amt src dst none)
  (if (is-eq a WELSH) (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer amt src dst none)
  (if (is-eq a MIA2) (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer amt src dst none)
  (if (is-eq a NYC2) (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer amt src dst none)
  (if (is-eq a DIKO) (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token transfer amt src dst none)
  (if (is-eq a USDA) (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer amt src dst none)
  (if (is-eq a VIBES) (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token transfer amt src dst none)
  (if (is-eq a lBTC) (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c transfer amt src dst none)
  (if (is-eq a ALEX) (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer amt src dst none)
  (if (is-eq a XBTC) (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer amt src dst none)
  ERR_X)))))))))))))))
)

(define-private (alex-diko-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 x (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (diko-alex-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 (* x u100) (some u0))
r (ok (get dx r))
e (err e)))
        
(define-private (alex-usda-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 x (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (usda-alex-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 (* x u100) (some u0))
r (ok (get dx r))
e (err e)))
        
(define-private (stx-alex-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* x u100) (some u0))
r (ok (get dy r))
e (err e)))

(define-private (alex-stx-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 x (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (stx-xbtc-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (* x u100) (some u0))
r (ok (get dy r))
e (err e)))

(define-private (xbtc-stx-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 x (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (stx-mia2-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
u100000000 (* x u100) (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (mia2-stx-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
u100000000 (* x u100) (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (stx-nyc2-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
u100000000 (* x u100) (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (nyc2-stx-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
u100000000 (* x u100) (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (stx-welsh-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* x u100) (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (welsh-stx-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* x u100) (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (abtc-xbtc-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u5000000 (* x u100) (some u0))
r (ok (get dy r))
e (err e)))

(define-private (xbtc-abtc-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u5000000 x (some u0))
r (ok (/ (get dx r) u100))
e (err e)))
        
(define-private (alex-long-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
u100000000 x (some u0))
r (ok (/ (get dy r) u100))
e (err e)))

(define-private (long-alex-h (x uint))
(match (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
u100000000 (* x u100) (some u0))
r (ok (get dx r))
e (err e)))
        

(define-private (swap-h
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a ALEX)
    (if (is-eq b DIKO) (alex-diko-h x)
    (if (is-eq b USDA) (alex-usda-h x)
    (if (is-eq b STX) (alex-stx-h x)
    (if (is-eq b LONG) (alex-long-h x)
    ERR_HLEX_A))))
  (if (is-eq a DIKO)
    (if (is-eq b ALEX) (diko-alex-h x)
    ERR_HLEX_A)
  (if (is-eq a USDA)
    (if (is-eq b ALEX) (usda-alex-h x)
    ERR_HLEX_A)
  (if (is-eq a STX)
    (if (is-eq b ALEX) (stx-alex-h x)
    (if (is-eq b XBTC) (stx-xbtc-h x)
    (if (is-eq b MIA2) (stx-mia2-h x)
    (if (is-eq b NYC2) (stx-nyc2-h x)
    (if (is-eq b WELSH) (stx-welsh-h x)
    ERR_HLEX_A)))))
  (if (is-eq a XBTC)
    (if (is-eq b STX) (xbtc-stx-h x)
    (if (is-eq b aBTC) (xbtc-abtc-h x)
    ERR_HLEX_A))
  (if (is-eq a MIA2)
    (if (is-eq b STX) (mia2-stx-h x)
    ERR_HLEX_A)
  (if (is-eq a NYC2)
    (if (is-eq b STX) (nyc2-stx-h x)
    ERR_HLEX_A)
  (if (is-eq a WELSH)
    (if (is-eq b STX) (welsh-stx-h x)
    ERR_HLEX_A)
  (if (is-eq a aBTC)
    (if (is-eq b XBTC) (abtc-xbtc-h x)
    ERR_HLEX_A)
  (if (is-eq a LONG)
    (if (is-eq b ALEX) (long-alex-h x)
    ERR_HLEX_A)
  ERR_HLEX_B))))))))))
)
(define-private (stx-usda-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-stx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-diko-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (diko-stx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
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
        
(define-private (stx-xbtc-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (xbtc-stx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
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
        
(define-private (stx-welsh-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (welsh-stx-d (x uint))
(match (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        

(define-private (swap-d
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a STX)
    (if (is-eq b USDA) (stx-usda-d x)
    (if (is-eq b DIKO) (stx-diko-d x)
    (if (is-eq b XBTC) (stx-xbtc-d x)
    (if (is-eq b WELSH) (stx-welsh-d x)
    ERR_DIKO_A))))
  (if (is-eq a USDA)
    (if (is-eq b STX) (usda-stx-d x)
    (if (is-eq b DIKO) (usda-diko-d x)
    (if (is-eq b XBTC) (usda-xbtc-d x)
    ERR_DIKO_A)))
  (if (is-eq a DIKO)
    (if (is-eq b STX) (diko-stx-d x)
    (if (is-eq b USDA) (diko-usda-d x)
    ERR_DIKO_A))
  (if (is-eq a XBTC)
    (if (is-eq b STX) (xbtc-stx-d x)
    (if (is-eq b USDA) (xbtc-usda-d x)
    ERR_DIKO_A))
  (if (is-eq a WELSH)
    (if (is-eq b STX) (welsh-stx-d x)
    ERR_DIKO_A)
  ERR_DIKO_B)))))
)
(define-private (stx-nyc2-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (nyc2-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-mia2-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (mia2-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
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
        
(define-private (stsw-welsh-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (welsh-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
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
r (ok (unwrap-panic (element-at r u1)))
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
        
(define-private (stsw-vibes-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
x u0)
r (ok (unwrap-panic (element-at r u1)))
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
        
(define-private (stx-lbtc-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (lbtc-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-usda-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (usda-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (stsw-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-diko-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (diko-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
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
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (stsw-alex-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stsw-leo-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (leo-stsw-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        
(define-private (stx-velar-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPEXN4B0GDRWH0Y1RKAE4G654H6P4V668G6EAYST.velar-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kgzozqgz7
x u0)
r (ok (unwrap-panic (element-at r u1)))
e (err e)))

(define-private (velar-stx-s (x uint))
(match (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPEXN4B0GDRWH0Y1RKAE4G654H6P4V668G6EAYST.velar-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kgzozqgz7
x u0)
r (ok (unwrap-panic (element-at r u0)))
e (err e)))
        

(define-private (swap-s
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a STX)
    (if (is-eq b NYC2) (stx-nyc2-s x)
    (if (is-eq b MIA2) (stx-mia2-s x)
    (if (is-eq b VIBES) (stx-vibes-s x)
    (if (is-eq b lBTC) (stx-lbtc-s x)
    (if (is-eq b USDA) (stx-usda-s x)
    (if (is-eq b STSW) (stx-stsw-s x)
    (if (is-eq b DIKO) (stx-diko-s x)
    (if (is-eq b VELAR) (stx-velar-s x)
    ERR_STSW_A))))))))
  (if (is-eq a NYC2)
    (if (is-eq b STX) (nyc2-stx-s x)
    ERR_STSW_A)
  (if (is-eq a MIA2)
    (if (is-eq b STX) (mia2-stx-s x)
    ERR_STSW_A)
  (if (is-eq a STSW)
    (if (is-eq b lBTC) (stsw-lbtc-s x)
    (if (is-eq b WELSH) (stsw-welsh-s x)
    (if (is-eq b VIBES) (stsw-vibes-s x)
    (if (is-eq b STX) (stsw-stx-s x)
    (if (is-eq b ALEX) (stsw-alex-s x)
    (if (is-eq b LEO) (stsw-leo-s x)
    ERR_STSW_A))))))
  (if (is-eq a lBTC)
    (if (is-eq b STSW) (lbtc-stsw-s x)
    (if (is-eq b STX) (lbtc-stx-s x)
    ERR_STSW_A))
  (if (is-eq a WELSH)
    (if (is-eq b STSW) (welsh-stsw-s x)
    ERR_STSW_A)
  (if (is-eq a VIBES)
    (if (is-eq b STX) (vibes-stx-s x)
    (if (is-eq b STSW) (vibes-stsw-s x)
    ERR_STSW_A))
  (if (is-eq a USDA)
    (if (is-eq b STX) (usda-stx-s x)
    ERR_STSW_A)
  (if (is-eq a DIKO)
    (if (is-eq b STX) (diko-stx-s x)
    ERR_STSW_A)
  (if (is-eq a ALEX)
    (if (is-eq b STSW) (alex-stsw-s x)
    ERR_STSW_A)
  (if (is-eq a LEO)
    (if (is-eq b STSW) (leo-stsw-s x)
    ERR_STSW_A)
  (if (is-eq a VELAR)
    (if (is-eq b STX) (velar-stx-s x)
    ERR_STSW_A)
  ERR_STSW_B))))))))))))
)
(define-private (stx-abtc-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u3
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))

(define-private (abtc-stx-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u3
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))
        
(define-private (stx-long-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u14
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))

(define-private (long-stx-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u14
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))
        
(define-private (velar-stx-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u21
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))

(define-private (stx-velar-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u21
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))
        
(define-private (stx-welsh-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))

(define-private (welsh-stx-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))
        
(define-private (stx-leo-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))

(define-private (leo-stx-v (x uint))
(match (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
x u1)
r (ok (get amt-out r))
e (err e)))
        

(define-private (swap-v
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a STX)
    (if (is-eq b aBTC) (stx-abtc-v x)
    (if (is-eq b LONG) (stx-long-v x)
    (if (is-eq b VELAR) (stx-velar-v x)
    (if (is-eq b WELSH) (stx-welsh-v x)
    (if (is-eq b LEO) (stx-leo-v x)
    ERR_VELAR_A)))))
  (if (is-eq a aBTC)
    (if (is-eq b STX) (abtc-stx-v x)
    ERR_VELAR_A)
  (if (is-eq a LONG)
    (if (is-eq b STX) (long-stx-v x)
    ERR_VELAR_A)
  (if (is-eq a VELAR)
    (if (is-eq b STX) (velar-stx-v x)
    ERR_VELAR_A)
  (if (is-eq a WELSH)
    (if (is-eq b STX) (welsh-stx-v x)
    ERR_VELAR_A)
  (if (is-eq a LEO)
    (if (is-eq b STX) (leo-stx-v x)
    ERR_VELAR_A)
  ERR_VELAR_B))))))
)
(define-private (swap
  (s (string-ascii 1))
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq s "1") (swap-h a b x)
  (if (is-eq s "2") (swap-d a b x)
  (if (is-eq s "3") (swap-s a b x)
  (if (is-eq s "4") (swap-v a b x)
  ERR_S))))
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
  (Xi int)
  (Yo int)
)
  (let
    (
      (sender tx-sender)
      (f (unwrap-panic (element-at p u0)))
      (l (unwrap-panic (element-at p (- (len p) u1))))
      (a (unwrap-panic (element-at f u1)))
      (b (unwrap-panic (element-at l u2)))
      (x (if (> Xi 0) (- (to-uint Xi) (var-get ix)) u0))
      (k (if (< Xi Yo) (- (to-uint Yo) (var-get ix)) u1))
    )
    (asserts! (unwrap-panic (iwl sender)) (err (list ERR_O)))
    (unwrap! (xfer a x tx-sender (as-contract tx-sender)) (err (list ERR_V)))
    (as-contract
    (match (ex p x k)
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
  (x int)
  (y int)
)
  (begin
    (ok (list (Z p x (+ x y))))
  )
)

(define-public (emergency
  (a (string-ascii 1))
  (amt uint)
  (dst principal)
)
  (begin
    (asserts! (unwrap-panic (iwl tx-sender)) (err (list ERR_O)))
    (as-contract (unwrap! (xfer a amt tx-sender dst) (err (list ERR_V))))
    (ok amt)
  )
)

(awl 'SPNJ0ZPYRFMJ8S8173Z56TZEP2E3M6FF8N69H38C)                                                                                                                                                                                (six u433164654600)

(define-map wl principal bool)
(map-set wl tx-sender true)

(define-read-only (iwl (k principal))
  (match (map-get? wl k)
    value (ok true)
    ERR_IC
  )
)
(define-public (awl (k principal))
  (begin
    (asserts! (is-eq contract-caller OWNER) ERR_IC)
    (ok (map-set wl
      k true
    ))
  )
)

(define-public (rwl (k principal))
  (begin
    (asserts! (is-eq contract-caller OWNER) ERR_IC)
    (ok (map-delete wl
      k
    ))
  )
)

(define-data-var ix uint u1000)
(define-public (six (k uint))
  (begin
    (asserts! (is-eq contract-caller OWNER) ERR_IC)
    (ok (var-set ix k))
  )
)

