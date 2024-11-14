(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(let (
			(token-id (get pool-id (try! (contract-call? .amm-registry-v2-01 get-pool-details .token-alex .token-wplay ONE_8))))
			(supply (get supply (try! (contract-call? .amm-pool-v2-01 add-to-position .token-alex .token-wplay ONE_8 (* u34800 ONE_8) none)))))
		(try! (contract-call? .alex-farming stake-tokens .token-amm-pool-v2-01 token-id supply u24))
(ok true)))