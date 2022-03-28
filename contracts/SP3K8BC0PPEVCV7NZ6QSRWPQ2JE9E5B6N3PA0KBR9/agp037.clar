(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

(define-public (execute (sender principal))
	(let
		(
			(balance (unwrap-panic (contract-call? .fwp-alex-wban get-balance-fixed tx-sender)))
		)
		(and 
			(> balance u0)
			(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-alex-wban balance u32))
		)
		(ok true)	
	)
)
