(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-token .auto-alex-v2))
		(ok true)	
	)
)