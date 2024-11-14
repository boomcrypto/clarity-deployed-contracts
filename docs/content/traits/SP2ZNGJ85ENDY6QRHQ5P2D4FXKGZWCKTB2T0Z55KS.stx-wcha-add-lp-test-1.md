---
title: "Trait stx-wcha-add-lp-test-1"
draft: true
---
```
;; Created With Charisma

(define-public (execute-strategy (amt0-desired uint) (amt1-desired uint) (amt0-min uint) (amt1-min uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router add-liquidity u55 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-wcha amt0-desired amt1-desired amt0-min amt1-min))
        (ok true)
    )
)
```
