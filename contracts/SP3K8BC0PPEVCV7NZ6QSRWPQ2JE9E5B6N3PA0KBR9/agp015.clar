(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

(define-public (execute (sender principal))
	(let
		(
			(alex (unwrap-panic (contract-call? .age000-governance-token get-balance-fixed tx-sender)))
			(fwp-alex (unwrap-panic (contract-call? .fwp-wstx-alex-50-50-v1-01 get-balance-fixed tx-sender)))
			(fwp-wbtc (unwrap-panic (contract-call? .fwp-wstx-wbtc-50-50-v1-01 get-balance-fixed tx-sender)))
		)

		(and 
			(> alex u0) 
			(try! (contract-call? .alex-reserve-pool stake-tokens .age000-governance-token alex u32))
		)
		(and 
			(> fwp-alex u0)
			(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-alex-50-50-v1-01 fwp-alex u32))
		)
		(and 
			(> fwp-wbtc u0)
			(try! (contract-call? .alex-reserve-pool stake-tokens .fwp-wstx-wbtc-50-50-v1-01 fwp-wbtc u32))
		)

		(ok true)	
	)
)
