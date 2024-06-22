---
title: "Trait agp196"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(contract-call? .alex-reserve-pool set-coinbase-amount 
		.age000-governance-token 
		(* u103200 ONE_8)
		(* u103200 ONE_8)
		(* u103200 ONE_8)
		(* u51600 ONE_8)
		(* u25800 ONE_8)))
```
