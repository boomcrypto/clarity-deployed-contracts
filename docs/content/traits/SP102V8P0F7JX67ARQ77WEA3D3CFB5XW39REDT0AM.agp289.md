---
title: "Trait agp289"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait) 
(define-public (execute (sender principal)) 
	(let (
				(start-height burn-block-height)
				(end-height (+ start-height u16800)))
		(try! (contract-call? .token-alex transfer-fixed u13283922618666100 tx-sender .treasury-grant none))
		(try! (contract-call? .treasury-grant set-start-height start-height))
		(try! (contract-call? .treasury-grant set-end-height end-height))
		(try! (contract-call? .treasury-grant pause false))
		(ok true)))
```
