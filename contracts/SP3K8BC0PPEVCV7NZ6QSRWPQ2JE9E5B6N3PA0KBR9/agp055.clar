(impl-trait .proposal-trait.proposal-trait)

(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))

(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(let 
		(		
			(claimed (unwrap! (contract-call? .fwp-wstx-wxusd-50-50-v1-01 get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
		)
		(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-wxusd-50-50-v1-01 claimed u32))
		(ok true)	
	)
)
