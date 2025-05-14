---
title: "Trait vdp002-reduce-signals-required"
draft: true
---
```
;; Title: VDP002 Reduce Signals Required
;; Description: This contract is used to reduce signals required for emergency execute for VibesDAO to ensure easier testing on mainet.

(impl-trait 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		
		;; Set emergency team members.
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde004-emergency-execute set-signals-required u1)) ;; signal from 1 out of 3 team members required.
		
		(print "Signals required is reduced to 1.")
		(ok true)
	)
)
```
