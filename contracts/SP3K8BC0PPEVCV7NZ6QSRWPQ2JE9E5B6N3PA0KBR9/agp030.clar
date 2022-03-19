(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))
(define-constant BANANA_TOTAL_TICKETS u500)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-launchpad-v1-1 add-to-position u0 BANANA_TOTAL_TICKETS .token-wban))
		(ok true)
	)
)
