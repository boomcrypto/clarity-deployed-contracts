(define-read-only (get-pools-1)
    (let (
        (STX-ALEX (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex u100000000))
        )
    {
        STX-ALEX: (ok STX-ALEX)
    })
)