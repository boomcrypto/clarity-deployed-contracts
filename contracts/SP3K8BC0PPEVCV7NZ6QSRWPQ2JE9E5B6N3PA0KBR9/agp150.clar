(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .alex-reserve-pool-sft))
		(ok true)	
	)
)