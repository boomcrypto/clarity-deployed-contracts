---
title: "Trait agp292"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant recipients (list
	{ amount: u924358228964285, recipient: 'SPGZRPG97X81CZE5AJAN4PYS4NFDG1Z1K4Z2RXNT } ;; Kucoin
	{ amount: u3089212508133114, recipient: 'SP33XEHK2SXXH625VG6W6665WBBPX1ENQVKNEYCYY } ;; Gate
	{ amount: u1090139068000000, recipient: 'SP3ZQMZBRH2DAMW72ZXCZVSME7Q685YQYFTEYM2X8 } ;; MEXC
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many recipients))
		(ok true)))
```
