---
title: "Trait agp071"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP13F0C8HFJC9H1FR7S7WFZ9FEMNV1PBEG3GWS5N0 u1 (* u4500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP1QSYZ0TY2SM6GKNF7SKN0BRD5GFM4HN5KXZNHG5 u1 (* u4500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP20G252BDQ3920ABQAT6PJSZE77NXZ35MC4Q7R4R u1 (* u4500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP17GNF0HPB5K5MSNYFEBQ16CRY17KX4YJ3RXKDRP u1 (* u4500000 ONE_8)))		
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP1RJ9M7YTC2H8DAYGTAQGEYHNQ7SATF0SJMQJX59 u1 (* u2804033 ONE_8)))
		(ok true)	
	)
)
```