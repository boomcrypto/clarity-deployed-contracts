(define-data-var executed bool false)
(define-constant deployer 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zest-governance)

(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)

(define-public (execute (sender principal))
	(let (
		(reserve-data-wstx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		(print reserve-data-wstx)

		(try!
			(contract-call? .pool-borrow-v2-4 set-reserve wstx-address
				(merge reserve-data-wstx { borrow-cap: u3600000000000 })
			)
		)

		(var-set executed true)
		(ok true)
	)
)

(define-public (disable)
	(begin
		(asserts! (is-eq deployer tx-sender) (err u11))
		(ok (var-set executed true))
	)
)

(define-read-only (can-execute)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(ok (not (var-get executed)))
	)
)