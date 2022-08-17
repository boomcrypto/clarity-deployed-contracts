(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount-to-add (* u1000000 ONE_8))
(define-public (execute (sender principal))
	(let 
		(
			(bal-before (contract-call? .alex-reserve-pool get-balance .auto-alex))
		)
		(try! (contract-call? .auto-alex transfer-fixed amount-to-add tx-sender .alex-vault none))
		(try! (contract-call? .alex-reserve-pool add-to-balance .auto-alex amount-to-add))
		(print { bal-before: bal-before })
		(ok true)	
	)
)