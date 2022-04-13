(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extension .age005-claim-and-stake true))
		(ok true)	
	)
)
