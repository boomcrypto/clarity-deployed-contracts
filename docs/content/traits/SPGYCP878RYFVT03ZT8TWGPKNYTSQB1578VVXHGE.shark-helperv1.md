---
title: "Trait shark-helperv1"
draft: true
---
```
;; Base swap function
(define-public (perform-swap-wstx-shark (amount uint))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap
        amount
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
        'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS.shark-coin-stxcity
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))
(define-public (perform-swap-shark-wstx (amount uint))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap
        amount
        'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS.shark-coin-stxcity
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))
;; Fixed amount functions
(define-public (buy-10stx)
    (perform-swap-wstx-shark u10000000))
(define-public (buy-50stx)
    (perform-swap-wstx-shark u50000000))
(define-public (buy-100stx)
    (perform-swap-wstx-shark u100000000))
;; Custom amount function
(define-public (buy-custom-amount (amount uint))
    (perform-swap-wstx-shark (* amount u1000000)))
(define-public (sell-10k-shark)
    (perform-swap-shark-wstx u10000000000))
```
