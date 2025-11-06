(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		(contract-call? .pool-0-reserve is-lending-pool .pool-0-reserve-v2-0)

		(try! (contract-call? .pool-0-reserve set-lending-pool tx-sender))

		(try!
			(contract-call? .pool-0-reserve transfer-to-user
				'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
				'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG
				u7592614
			)
		)

		(try! (contract-call? .pool-0-reserve set-lending-pool .pool-0-reserve-v2-0))

		(asserts! (contract-call? .pool-0-reserve is-lending-pool .pool-0-reserve-v2-0) (err u12))

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