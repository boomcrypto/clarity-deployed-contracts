(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-apower add-approved-contract .alex-launchpad-v1-1))
		(ok true)
	)
)
