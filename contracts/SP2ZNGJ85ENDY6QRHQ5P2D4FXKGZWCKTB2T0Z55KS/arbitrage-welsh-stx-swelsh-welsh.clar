;; Title: Arbitrage
;; Formula: WELSH -> STX -> sWELSH -> WELSH
;; Author: rozar.btc
;; Synopsis:
;; Grow your Welshcorgicoin holdings by taking advantage of price differences between WELSH and sWELSH.
;; Fees:
;; There is a fee of 200 WELSH for using this paid out to the welsh community staking pool.
;; There is a fee of 800 sWELSH for using this paid out to the contract creator.

(define-constant COMMUNITY_ROYALTY u200000000)
(define-constant CREATOR_ROYALTY u800000000)

(define-public (strategy-welsh-stx-swelsh-welsh (amount-in uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3 amount-in amount-in 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 unstake amount-in))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 unstake COMMUNITY_ROYALTY))
        (try! (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer COMMUNITY_ROYALTY tx-sender 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 none))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 transfer CREATOR_ROYALTY tx-sender 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS none))
        (ok true)
    )
)