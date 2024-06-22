---
title: "Trait agp305"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant recipients (list
	{ amount: u1090139068000000, recipient: 'SP3ZQMZBRH2DAMW72ZXCZVSME7Q685YQYFTEYM2X8 } ;; MEXC
	{ amount: u14978000000000, recipient: 'SP28V4T92SPPB67HX20SGMAFTW983YBRR354S2XNK } 
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many recipients))
		(ok true)))
```
