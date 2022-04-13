(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(let
		(
			(balance (unwrap-panic (contract-call? .fwp-alex-usda get-balance-fixed tx-sender)))
		)
		(and 
			(> balance u0)
			(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-alex-usda balance u32))
		)	
		(try! (contract-call? .executor-dao set-extension .age005-claim-and-stake true))
		(ok true)	
	)
)
