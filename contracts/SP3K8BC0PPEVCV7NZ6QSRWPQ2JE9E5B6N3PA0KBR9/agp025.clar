(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))
(define-constant reward-cycles (list u5 u6 u7))
(define-constant ERR-GET-BALANCE-FIXED-FAIL (err u6001))
(define-constant dx (* u200000 ONE_8))

(define-private (claim-fwp-alex-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .fwp-wstx-alex-50-50-v1-01 reward-cycle)
)
(define-private (claim-fwp-wbtc-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .fwp-wstx-wbtc-50-50-v1-01 reward-cycle)
)
(define-private (claim-alex-staking-reward (reward-cycle uint))
  (contract-call? .alex-reserve-pool claim-staking-reward .age000-governance-token reward-cycle)
)
(define-private (add-to-fwp-alex)
	(begin
		(try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .age000-governance-token u50000000 u50000000 .fwp-wstx-alex-50-50-v1-01 dx none))
		(ok true)
	)
)

(define-public (execute (sender principal))
	(begin 
    	(map claim-alex-staking-reward reward-cycles)
		(map claim-fwp-alex-staking-reward reward-cycles)
		(map claim-fwp-wbtc-staking-reward reward-cycles)
		
		(and (> dx u0) (try! (add-to-fwp-alex)))

		(let 
			(
				(alex (unwrap! (contract-call? .age000-governance-token get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
				(fwp-alex (unwrap! (contract-call? .fwp-wstx-alex-50-50-v1-01 get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
				(fwp-wbtc (unwrap! (contract-call? .fwp-wstx-wbtc-50-50-v1-01 get-balance-fixed tx-sender) ERR-GET-BALANCE-FIXED-FAIL))
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
)
