(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-public (claim (lottery-id uint) (round-id uint) (winners (list 200 principal)) (token-trait <ft-trait>))
	(let 
		( 
			(output (try! (contract-call? .alex-lottery claim lottery-id round-id winners token-trait)))
		)
		(as-contract (try! (contract-call? token-trait burn-fixed (get tax output) (unwrap-panic (contract-call? .alex-lottery get-contract-owner)))))
		(ok output)
	)
)