---
title: "Trait vdp001-reduce-proposal-duration"
draft: true
---
```
;; Title: VDP001 Reduce Proposal Duration
;; Description: This contract is used to reduce the proposal duration for VibesDAO to ensure easier testing on mainet.

(impl-trait 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		
		;; Set emergency team members.
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde002-proposal-submission set-parameter "proposal-duration" u2)) ;; 2 blocks = 20 minutes
		
		(print "Voting duration is reduced to 2 blocks.")
		(ok true)
	)
)
```
