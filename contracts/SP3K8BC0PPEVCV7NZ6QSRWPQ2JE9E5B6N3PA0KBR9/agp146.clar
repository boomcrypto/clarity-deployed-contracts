(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-token .auto-alex-v2))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-tranche-end-block u1 u105233))
		(ok true)	
	)
)