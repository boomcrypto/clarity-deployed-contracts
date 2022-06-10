(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extension .age008-claim-and-send-stake true))
		(try! (contract-call? .executor-dao set-extension .age007-claim-and-send-stake false))
		(ok true)	
	)
)
