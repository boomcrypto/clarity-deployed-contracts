---
title: "Trait alex_sbtc_to_aeusdc_1"
draft: true
---
```
(define-public (swap (sbtc uint))
    (let
        (
            (stx 
                (unwrap-panic
                    (contract-call? 
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
                    swap-helper 
                    'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc 
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
                    u100000000 
                    sbtc 
                    none)
                )
            )
            (usdc 
                (unwrap-panic
                    (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 
                    swap-helper 
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
                    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-waeusdc 
                    u100000000 
                    stx
                    none)
                )
            )
        ) 
        (ok usdc)
    )
)
```
