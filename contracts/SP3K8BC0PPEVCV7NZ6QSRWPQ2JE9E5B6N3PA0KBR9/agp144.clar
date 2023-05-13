(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount u102663738)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .age000-governance-token mint-fixed (* amount ONE_8) .auto-alex-buyback-helper))
		(ok true)	
	)
)