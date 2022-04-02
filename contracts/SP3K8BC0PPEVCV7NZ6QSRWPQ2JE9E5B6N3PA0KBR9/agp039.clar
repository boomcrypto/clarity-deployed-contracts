(impl-trait .proposal-trait.proposal-trait)

(define-constant sunset-height u67606)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .age003-emergency-execute set-executive-team-sunset-height sunset-height))
		(try! (contract-call? .executor-dao set-extension .age004-claim-and-stake true))
		(ok true)	
	)
)
