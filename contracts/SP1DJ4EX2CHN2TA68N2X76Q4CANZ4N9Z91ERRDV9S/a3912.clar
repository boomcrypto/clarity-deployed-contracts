(define-read-only (AL-1)
    (let (
        (STX-ALEX (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex u100000000))
        (STX-sUSDT (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt u100000000))
        (STX-aBTC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc u100000000))
        (STX-aeUSDC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-waeusdc u100000000))
        (STX-stSTX (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wststx u100000000))
       
        )
    {
        STX-ALEX: (ok STX-ALEX),
        STX-sUSDT: (ok STX-sUSDT),
        STX-aBTC: (ok STX-aBTC),
        STX-aeUSDC: (ok STX-aeUSDC),
        STX-stSTX: (ok STX-stSTX)
    })
)

(define-read-only (AR-XY-2)
    (let (
        (STX-USDA (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
        (STX-aeUSDC (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 get-pool))
    )
    {
        STX-USDA: (ok STX-USDA),
        STX-aeUSDC: (ok STX-aeUSDC)
    })
)

(define-read-only (velar-get-pools-5)
    (let (
        (stx-ststx (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001 do-get-pool))
        (velar-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u22))
        (velar-wstx (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u21))
        (stx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u6))
        
    )
    {   
        stx-ststx: (ok stx-ststx),
        velar-aeusdc: (ok velar-aeusdc),
        velar-wstx: (ok velar-wstx),
        stx-aeusdc: (ok stx-aeusdc)
    })
)


