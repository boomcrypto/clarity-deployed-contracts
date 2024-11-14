---
title: "Trait mint-cha-v2"
draft: true
---
```
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (* u1000000 (pow u10 u6)) 'SP3S11NGYFYE5E8ABYS197BXEQH9EMQYKFZEBX5C9))
		(ok true)
	)
)
```
