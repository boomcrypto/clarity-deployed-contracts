;; Title: arb-cha-launch-2
;; Author: SP1VGCMHKXYGZ4Y0DWZR6449M0EJY3PZV2XX61EMH
;; Created With Charisma
;; Description:
;; fight the jeets to the death

(define-public (execute-strategy (amount-in uint))
    (begin
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma remove-liquidity amount-in))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma stake amount-in))
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3 amount-in amount-in 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to))
        (ok true)
    )
)