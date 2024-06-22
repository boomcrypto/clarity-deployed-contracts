---
title: "Trait agp303"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-whashiko u100000000 u0))
		(try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wplay u100000000 u0))
		(try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wmick u100000000 u0))
		(ok true)))
```
