---
title: "Trait multi-damage"
draft: true
---
```
;; for multi-damage kraqen.btc

(use-trait sip010 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)
(define-constant edk 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.land-helper-v2)
(define-constant hogger 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wanted-hogger-v2)

(define-public (multi-exe)
  (begin
    (try! (contract-call? hogger tap u1 edk))
    (try! (contract-call? hogger tap u4 edk))
    (try! (contract-call? hogger tap u5 edk))
    (try! (contract-call? hogger tap u6 edk))
    (try! (contract-call? hogger tap u7 edk))
    (ok true)
  )
)
```
