(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .cross-peg-in-endpoint-v2-01, enabled: true }
			{ extension: .cross-peg-out-endpoint-v2-01, enabled: true }
			{ extension: .btc-peg-in-endpoint-v2-01, enabled: true }
			{ extension: .btc-peg-out-endpoint-v2-01, enabled: true }
			{ extension: .migrate-legacy, enabled: true }
		)))
		(ok true)
	)
)