---
title: "Trait arb-price"
draft: true
---
```
(define-read-only (reserves)
    (let (
        (s-w (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core get-pool u27)) ;; velar stx-welsh
        (w-iw (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool u1)) ;; chadex welsh-iouwelsh
        (c-w (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool u3)) ;; chadex cha-welsh
        (c-iw (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool u5)) ;; chadex cha-iouwelsh
        (s-c (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool u4)) ;; chadex stx-cha
        (s-ss (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core get-pool u10)) ;; chadex stx-synstx
    )
    {
        reserve00: (get reserve0 s-w),
        reserve10: (get reserve0 s-w),
        reserve01: (get reserve0 w-iw),
        reserve11: (get reserve1 w-iw),
        reserve02: (get reserve0 c-w),
        reserve12: (get reserve1 c-w),
        reserve03: (get reserve0 c-iw),
        reserve13: (get reserve1 c-iw),
        reserve04: (get reserve0 s-c),
        reserve14: (get reserve1 s-c),
        reserve05: (get reserve1 s-ss),
        reserve15: (get reserve1 s-ss)
    })
)
```
