---
title: "Trait check-balance-166688"
draft: true
---
```
(define-read-only (staked-roo-address (address principal) (block uint))
 (let
	(
		(block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
		(roo (at-block block-hash (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-balance u20 address) (err u500))))
	)
	(ok roo)
 )
)
(define-read-only (staked-welsh-address (address principal) (block uint))
 (let
	(
		(block-hash (unwrap! (get-block-info? id-header-hash block) (err u500)))
		(welsh (at-block block-hash (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-balance u4 address) (err u500))))
	)
	(ok welsh)
 )
)
```
