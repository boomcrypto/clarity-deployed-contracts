(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount (pow u10 u6))
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .age000-governance-token mint-fixed (* amount ONE_8) 'SPC7TY5JGGGA8HS4HGTTWXBN8NJ28XH2JR9HCXN4))
		(ok true)
	)
)