(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .amm-swap-pool set-max-in-ratio u10000000000))
		(try! (contract-call? .amm-swap-pool set-max-out-ratio u30000000))
		(ok true)
	)
)