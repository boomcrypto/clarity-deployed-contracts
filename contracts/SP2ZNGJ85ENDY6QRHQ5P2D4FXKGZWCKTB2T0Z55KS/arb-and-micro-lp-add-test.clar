;; Title: Arb WELSH-sWELSH LP STX-sCHA
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; Description:
;; The basic WELSH-sWELSH arbitrage, using some profits for a liquidity micro-deposit to STX-sCHA.

(define-public (execute-strategy (amount-in uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3 amount-in amount-in 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 unstake amount-in))
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router add-liquidity u54 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha u100000 u750000 u50000 u15000))
        (ok true)
    )
)