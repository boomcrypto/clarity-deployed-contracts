(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .auto-fwp-wstx-alex-120x set-available-alex 'SP31YA1ZJFR9D2S8QDCPFM212FVCV6P3S5EB12T53 (* u212145 ONE_8)))
		(ok true)	
	)
)
