---
title: "Trait a380-380"
draft: true
---
```
(define-read-only (alex-get-pools-1)
    (let (
        (STX-ALEX (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex u100000000))
        (ALEX-DIKO (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko u100000000))
        (STX-DIKO (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko u100000000))
        (STX-USDA (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda u100000000))
        (ALEX-USDA (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda u100000000))
        (ALEX-LEO (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo u100000000))
    )
    {
        STX-ALEX: (ok STX-ALEX),
        ALEX-DIKO: (ok ALEX-DIKO),
        STX-DIKO: (ok STX-DIKO),
        STX-USDA: (ok STX-USDA),
        ALEX-USDA: (ok ALEX-USDA),
        ALEX-LEO: (ok ALEX-LEO)
    })
)

(define-read-only (alex-get-pools-2)
    (let (
        (STX-aeUSDC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-waeusdc u100000000))
        (ALEX-B20 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 u100000000))
        (aBTC-B20 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 u100000000))
        (STX-aBTC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc u100000000))
        (ALEX-sBTC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc u100000000))
        (aBTC-sBTC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc u5000000))
    )
    {
        STX-aeUSDC: (ok STX-aeUSDC),
        ALEX-B20: (ok ALEX-B20),
        aBTC-B20: (ok aBTC-B20),
        STX-aBTC: (ok STX-aBTC),
        ALEX-sBTC: (ok ALEX-sBTC),
        aBTC-sBTC: (ok aBTC-sBTC)
    })
)

(define-read-only (alex-get-pools-3)
    (let (
        (STX-sBTC (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc u100000000))
        (STX-WELSH (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi u100000000))
        (STX-stSTX (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wststx u100000000))
        (STX-sUSDT (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt u100000000))
        (aBTC-sUSDT (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt u100000000))
        (sUSDT-USDh (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wusdh u5000000))
    )
    {
        STX-sBTC: (ok STX-sBTC),
        STX-WELSH: (ok STX-WELSH),
        STX-stSTX: (ok STX-stSTX),
        STX-sUSDT: (ok STX-sUSDT),
        aBTC-sUSDT: (ok aBTC-sUSDT),
        sUSDT-USDh: (ok sUSDT-USDh)
    })
)

(define-read-only (velar-get-pools-1)
    (let (
        (stx-leo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u28))
        (leo-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u9))
        (stx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u6))
        (stx-abtc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u3))
    )
    {
        stx-leo: (ok stx-leo),
        leo-aeusdc: (ok leo-aeusdc),
        stx-aeusdc: (ok stx-aeusdc),
        stx-abtc: (ok stx-abtc)
    })
)

(define-read-only (velar-get-pools-2)
    (let (
        (stx-welsh (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u27))
        (welsh-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u10))
        (velar-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u22))
        (velar-wstx (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u21))
    )
    {
        stx-welsh: (ok stx-welsh),
        welsh-aeusdc: (ok welsh-aeusdc),
        velar-aeusdc: (ok velar-aeusdc),
        velar-wstx: (ok velar-wstx)
    })
)

(define-read-only (velar-get-pools-3)
    (let (
        (ststx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
        (abtc-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u7))
        (stx-odin (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u23))
        (stx-rock (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u18))
    )
    {
        ststx-aeusdc: (ok ststx-aeusdc),
        abtc-aeusdc: (ok abtc-aeusdc),
        stx-odin: (ok stx-odin),
        stx-rock: (ok stx-rock)
    })
)

(define-read-only (velar-get-pools-4)
    (let (
        (stx-long (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u14))
        (stx-kangaroo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u15))
    )
    {
        stx-long: (ok stx-long),
        stx-kangaroo: (ok stx-kangaroo)
    })
)

(define-read-only (velar-get-pools-5)
    (let (
        (usdh-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-v1_1_0-0001 do-get-pool))
        (stx-ststx (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001 do-get-pool))
        (stx-sbtc (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070 do-get-pool))
        (stx-diko (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0056 do-get-pool))
       
    )
    {   
        usdh-aeusdc: (ok usdh-aeusdc),
        stx-ststx: (ok stx-ststx),
        stx-sbtc: (ok stx-sbtc),
        stx-diko: (ok stx-diko)
    })
)

(define-read-only (arkadiko-get-pools-1)
    (let (
        (STX-DIKO (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token))
        (DIKO-USDA (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
    )
    {
        STX-DIKO: (ok STX-DIKO),
        DIKO-USDA: (ok DIKO-USDA)
    })
)

(define-read-only (arkadiko-get-pools-2)
    (let (
        (STX-USDA (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
        (STX-WELSH (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 get-pair-details 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token))
    )
    {
        STX-USDA: (ok STX-USDA),
        STX-WELSH: (ok STX-WELSH)
    })
)
```
