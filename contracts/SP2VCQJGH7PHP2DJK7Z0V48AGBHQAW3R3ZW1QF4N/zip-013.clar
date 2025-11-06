(define-data-var executed bool false)


(define-public (execute (sender principal))
	(begin
		(asserts! (not (var-get executed)) (err u10))

		;; core (need recipient to accept)

		(try! (contract-call? .pool-0-reserve-v2-0 confirm-configurator-transfer))
		(try! (contract-call? .pool-0-reserve-v2-0 confirm-admin-transfer))

		(var-set executed true)
		(ok true)
	)
)


(define-read-only (can-execute)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(ok (not (var-get executed)))
	)
)
