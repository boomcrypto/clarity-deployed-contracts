(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-susdt set-approved-contract .bridge-endpoint-v1-02 true))
		(ok true)	
	)
)