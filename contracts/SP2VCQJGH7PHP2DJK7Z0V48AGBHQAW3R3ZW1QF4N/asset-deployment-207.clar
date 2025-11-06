(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (run-update)
	(let (
		(reserve-data-sbtc (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		(print reserve-data-sbtc)

		(try!
			(contract-call? .pool-borrow-v2-3 set-reserve sbtc-address
				(merge reserve-data-sbtc { debt-ceiling: u300000000000000 })
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