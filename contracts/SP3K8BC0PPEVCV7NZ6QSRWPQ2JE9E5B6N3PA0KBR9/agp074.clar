(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin			
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SPVZB7A41TMC654VEKGN8YF5SH6THP4CYHZDHW10 u1 (* u6000000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP2XE79SP3TQK67M50C44G1N021RJCMG0PPHFXWPN u1 (* u6000000 ONE_8)))
		
		(ok true)	
	)
)