(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extension .age007-claim-and-send-stake true))
		(try! (contract-call? .executor-dao set-extension .age005-claim-and-stake false))
		(try! (contract-call? .executor-dao set-extension .age004-claim-and-stake false))
		(ok true)	
	)
)
