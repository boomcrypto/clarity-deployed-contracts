(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))
(define-constant fifty-percent (/ ONE_8 u2))

(define-constant alex-dx u8143327558931)
(define-constant alex-max-dy (some u7728860630698))
(define-constant wbtc-dx u1441184580000)
(define-constant wbtc-max-dy (some u58928708))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .age000-governance-token fifty-percent fifty-percent .fwp-wstx-alex-50-50 ONE_8))
		(try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50 ONE_8))
		
		(try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .age000-governance-token fifty-percent fifty-percent .fwp-wstx-alex-50-50-v1-01 alex-dx alex-max-dy))
		(try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50-v1-01 wbtc-dx wbtc-max-dy))

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
)
