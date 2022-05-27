(impl-trait .proposal-trait.proposal-trait)

(define-constant to-mint (* u150000 u100000000))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .autoalex-apower-helper add-approved-contract 'SP1A6F9ABHQMVP92GH7T9ZBF029T1WG3SHPNMKT0D))
		(try! (contract-call? .autoalex-apower-helper add-approved-contract 'SP3CHZ34C35R5Z1DGSPE4BR53EPSKV2WHN7YN6MN0))
		(try! (contract-call? .age000-governance-token mint-fixed to-mint 'SPC7TY5JGGGA8HS4HGTTWXBN8NJ28XH2JR9HCXN4))
		(ok true)	
	)
)
