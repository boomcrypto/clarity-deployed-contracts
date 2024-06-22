(define-public (DDD-akja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDS-akja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDD-akoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDH-akoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DS-aka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DHH-akna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDD-ajka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDS-ajka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DS-aja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DHH-ajna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDD-aoka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DDS-aoka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DSS-aoma (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DH-aoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DHV-aopa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u5000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u3
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DSS-agfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DV-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (DH-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100)
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SH-aia (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc get-balance tx-sender)) u100)
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SH-aha (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia get-balance tx-sender)) u100)
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSS-alfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
              (unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSD-amoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSH-amoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSS-amfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SD-aka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDD-akja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDS-akja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDD-akoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDH-akoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SHH-akna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSS-afma (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5krqbd8nh6
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSD-afga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSV-afga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSH-afga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100)
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSS-afla (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kixf5578t
              (unwrap-panic (contract-call? 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSH-afna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SSV-afba (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SD-aja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDD-ajka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SDS-ajka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (SHH-ajna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              in
              u0)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VHD-apoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u3
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u5000000
              (* (unwrap-panic (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VHH-apoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u3
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u5000000
              (* (unwrap-panic (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VHH-adna (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u14
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong get-balance tx-sender)) u100)
              (some u0))))
        (router_2 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VD-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VSS-agfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VH-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi get-balance tx-sender)) u100)
              (some u0))))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (VSS-abfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u28
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              in
              u1)))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kj1jqlas1
              (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HSS-anfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y 
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k2658uqsb
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHD-anja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHS-anja (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kt9nmle8c
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHD-anka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHS-anka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHV-anda (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlong
              u100000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u14
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HD-aoa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HDD-aoka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HDS-aoka (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
              (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HSS-aoma (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0zm77lq6
              (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kzkks2c2y
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HHV-aopa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x 
              'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
              u5000000
              (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc get-balance tx-sender))
              (some u0))))
        (router_2 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u3
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HS-aha (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wmia
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kboyn2773
              (unwrap-panic (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HS-aia (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
              (unwrap-panic (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HD-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x 
              'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HSS-agfa (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kbe3oqvac
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u0)))
        (router_2 (try! (contract-call?
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x 
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
              'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
              (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a get-balance tx-sender))
              u0)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)

(define-public (HV-aga (in uint))
  (begin (try! (stx-transfer? in tx-sender (as-contract tx-sender)))
    (as-contract (let (
        (router_0 (try! (contract-call?
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
              'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
              u100000000
              (* in u100)
              (some u0))))
        (router_1 (try! (contract-call?
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
              u27
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
              'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
              (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token get-balance tx-sender))
              u1)))
        (out (stx-get-balance (as-contract tx-sender)))
      )
      (asserts! (> out in) (err u0))
      (try! (stx-transfer? out (as-contract tx-sender) tx-sender))
      (ok (list in out))
    ))
  )
)
