(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-reserve-asset 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant aeusdc-reserve-asset 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-constant aeusdc-params
	{
		borrow-cap: u20000000000000,
		supply-cap: u20000000000000
	}
)

(define-constant sbtc-params
	{
		base-ltv-as-collateral: u70000000,
		debt-ceiling: u1000000000000000
	}
)

(define-public (run-update)
	(let (
		(reserve-data-sbtc (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-reserve-asset)))
		(reserve-data-aeusdc (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-reserve-asset)))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))
		(print reserve-data-sbtc)
		(print reserve-data-aeusdc)

		(try!
			(contract-call? .pool-borrow-v2-3 set-reserve sbtc-reserve-asset
				(merge reserve-data-sbtc
					{
						base-ltv-as-collateral: (get base-ltv-as-collateral sbtc-params),
						debt-ceiling: (get debt-ceiling sbtc-params)
					}
				)
			)
		)

		(try!
			(contract-call? .pool-borrow-v2-3 set-reserve aeusdc-reserve-asset
				(merge reserve-data-aeusdc
					{
						borrow-cap: (get borrow-cap aeusdc-params),
						supply-cap: (get supply-cap aeusdc-params)
					}
				)
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
