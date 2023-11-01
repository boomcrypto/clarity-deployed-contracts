(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-apower add-approved-contract .bridge-apower-helper))
		(ok true)	
	)
)