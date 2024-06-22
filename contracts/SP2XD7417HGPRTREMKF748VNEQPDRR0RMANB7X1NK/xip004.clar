(impl-trait .proposal-trait.proposal-trait)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: .token-susdt, chain-id: u2 } u331551841390586))
		(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: .token-ssko, chain-id: u2 } u275866681620230))
		(ok true)
	)
)