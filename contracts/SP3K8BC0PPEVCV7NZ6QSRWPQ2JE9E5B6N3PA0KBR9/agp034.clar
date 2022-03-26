(impl-trait .proposal-trait.proposal-trait)

(define-constant amount (* u100000 (pow u10 u8)))

(define-public (execute (sender principal))
	(begin 
    	(try! (contract-call? .age000-governance-token mint-fixed amount 'SPZN0SK6Y4JP96S342KR3HA108RGJBJJGE266CC0))
		(ok true)
  	)
)
