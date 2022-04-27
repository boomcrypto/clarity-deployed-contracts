(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-flash-loan-user .flash-loan-user-autoalex-to-alex))
		(ok true)	
	)
)
