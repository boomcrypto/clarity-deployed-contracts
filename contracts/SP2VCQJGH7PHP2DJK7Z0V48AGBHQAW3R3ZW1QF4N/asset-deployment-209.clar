(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststx-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)

(define-constant new-curve-params
	{
		variable-rate-slope-1: u10000000,
	}
)

(define-constant ststx-debt-ceiling u500000000000000)

(define-public (run-update)
	(let (
    	(reserve-data-ststx (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-token)))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))


		(print "update usdh")

		(print
			{
				variable-rate-slope-1: (unwrap-panic (contract-call? .pool-reserve-data get-variable-rate-slope-1 usdh-address))
			}
		)
		(try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 usdh-address (get variable-rate-slope-1 new-curve-params)))


		(print "update ststx")

		(print reserve-data-ststx)
		(try!
			(contract-call? .pool-borrow-v2-3 set-reserve ststx-token
				(merge reserve-data-ststx { debt-ceiling: ststx-debt-ceiling })
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