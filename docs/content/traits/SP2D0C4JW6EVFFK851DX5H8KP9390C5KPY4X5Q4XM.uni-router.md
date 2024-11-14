---
title: "Trait uni-router"
draft: true
---
```

(define-public (DDD-apia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDS-apia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDD-apma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDH-apma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DS-apa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DHH-apla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDD-aipa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDS-aipa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DS-aia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DHH-aila (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDD-ampa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DDS-ampa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DSS-amka (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DH-ama (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DSS-afea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DV-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
in u0)))
(router_1 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (DH-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SH-aha (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc get-balance tx-sender)) u100) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SH-aga (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia get-balance tx-sender)) u100) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSS-ajea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
(unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SHH-ajla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvibes
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvibes get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSD-akma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSH-akma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSS-akea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SD-apa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDD-apia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDS-apia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDD-apma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDH-apma (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SHH-apla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSS-aeka (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSD-aefa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSV-aefa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSH-aefa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSS-aeja (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
(unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSH-aela (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSV-aena (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kr3b59xpn
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SSV-aeba (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
in u0)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SD-aia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDD-aipa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SDS-aipa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
in u0)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SHH-aila (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SV-aa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kev7mmmd2
in u0)))
(router_1 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u16
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SHH-ala (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kev7mmmd2
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot get-balance tx-sender)) u100000000) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SV-aoa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kmnnwc4wo
in u0)))
(router_1 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u12
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (SHH-aola (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kmnnwc4wo
in u0)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VSS-anea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kr3b59xpn
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VHH-anla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VS-aoa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u12
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kmnnwc4wo
(unwrap-panic (contract-call? 'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VHH-aola (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u12
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VHH-adla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u14
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VS-aa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u16
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kev7mmmd2
(unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VHH-ala (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u16
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot get-balance tx-sender)) u100000000) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VD-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VSS-afea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VH-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VSS-abea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
(unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (VHH-abla (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
in u1)))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
u100000000 (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo get-balance tx-sender)) u100) (some u0))))
(router_2 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HSS-alea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
(unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHD-alia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHS-alia (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHD-alpa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHS-alpa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHV-alna (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpepe
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u11
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHV-alda (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u14
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHS-ala (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kev7mmmd2
(unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHV-ala (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u16
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHS-aloa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kmnnwc4wo
(unwrap-panic (contract-call? 'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHV-aloa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmick
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u12
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP2Y8T3TR3FKH3Y2FPZVNQAEKNJXKWVS4RVQF48JE.stakemouse get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHS-alja (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvibes
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
(unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HHV-alba (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
u100000000 (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender)) (some u0))))
(router_2 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u28
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HD-ama (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HDD-ampa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HDS-ampa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HSS-amka (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
(unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HS-aga (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
(unwrap-panic (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HS-aha (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
(unwrap-panic (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HD-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HSS-afea (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u0)))
(router_2 (try! (contract-call?
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
(unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender)) u0)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
(define-public (HV-afa (in uint))
(let ((sender tx-sender))
(try! (stx-transfer? in sender (as-contract tx-sender)))
(as-contract (let (
(router_0 (try! (contract-call?
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
u100000000 (* in u100) (some u0))))
(router_1 (try! (contract-call?
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u27
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
(unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender)) u1)))
(out (stx-get-balance tx-sender))
)
(asserts! (> out in) (err out))
(try! (stx-transfer? out tx-sender sender))
(ok (list out in))
))))
```
