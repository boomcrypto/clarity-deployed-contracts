(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extension .age012-claim-and-send-stake true))
		(try! (contract-call? .executor-dao set-extension .age011-claim-and-send-stake false))
		(ok true)	
	)
)