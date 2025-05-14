---
title: "Trait dexterity-pool-v1-hold-to-earn"
draft: true
---
```

;; Title: Hold-to-Earn Engine for Dexterity
;; Version: 1.0.0
;; Description: 
;;   Implementation of the Hold-to-Earn mechanism that rewards long-term holders
;;   by measuring their token balance over time and converting it to energy.

;; State
(define-data-var first-start-block uint stacks-block-height)
(define-map last-tap-block principal uint)

;; Balance Tracking
(define-private (get-balance (data { address: principal, block: uint }))
    (let ((target-block (get block data)))
        (if (< target-block stacks-block-height)
            (let ((block-hash (unwrap-panic (get-stacks-block-info? id-header-hash target-block))))
                (at-block block-hash (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-pool-v1 get-balance (get address data)))))
            (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-pool-v1 get-balance (get address data))))))


;; Public Functions
(define-read-only (get-last-tap-block (address principal))
    (default-to (var-get first-start-block) (map-get? last-tap-block address)))

```
