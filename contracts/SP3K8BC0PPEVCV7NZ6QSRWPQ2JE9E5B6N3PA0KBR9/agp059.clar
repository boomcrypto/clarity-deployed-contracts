(impl-trait .proposal-trait.proposal-trait)

(define-constant to-mint (* u500000 u100000000))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-apower add-approved-contract .autoalex-apower-helper))
		(try! (contract-call? .age000-governance-token mint-fixed to-mint 'SPC7TY5JGGGA8HS4HGTTWXBN8NJ28XH2JR9HCXN4))
		(ok true)	
	)
)
