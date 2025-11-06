(define-constant err-user-not-found (err u8000))

(define-constant ststxbtc-address-v2 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)

(define-constant zststxbtc_v2-0 .zststxbtc-v2-0)


(define-constant deployer tx-sender)
(define-data-var executed bool false)

(define-constant ststxbtc-holders (list
'SPKNY5VDKXEY132EXGN8F23MK3A3JFNQWGAMMJ2Q
'SP3X8G3VXCVSH4HE2JDMBASF0FTGT3WZWJJW2ZWWS
'SP1CZV9Y0MWTEZQWTAJ8RXY39FE5Y2NT2BVJP4H85
'SP2T395ZMA7X6N3JQ5VRKCME0D4DZQVM84M8AAKT1
'SP36Q34V1Y55ZB4E675GX5CPHMZ62P5EMP7W3D668
'SP4CGMN877MANH279W194X4ZHM7CN2PV30S5NHQ9
'SP3VVPEFZNN84EGMD0GN4XWAZ4X5ZMWC852NGWVWN
'SP2JFW1CBXJD3P0EJ0QNGBWY4W5NQBV066V8BCARC
'SP23SY381RZ6QXB1X8Z4DG6G8ETZDWZAT5BWEKCET
'SP1C1HNXKT4Z37W8KR2JGGNDK99SR46AT7K05TD87
))


(define-public (run-update)
	(begin
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		(try! (burn-mint-zststxbtc))

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

(define-private (burn-mint-zststxbtc)
	(begin
		(try! (contract-call? .zststxbtc-v2-0 set-approved-contract (as-contract tx-sender) true))
		(try! (contract-call? .zststx-token set-approved-contract zststxbtc_v2-0 true))
		(try! (contract-call? .zststxbtc-v2_v2-0 set-approved-contract (as-contract tx-sender) true))
		(try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

		;; burn/mint v2 to v3
		(try! (fold check-err (map consolidate-balance ststxbtc-holders) (ok true)))

		;; disable access
		(try! (contract-call? .zststxbtc-v2-0 set-approved-contract (as-contract tx-sender) false))
		(try! (contract-call? .zststx-token set-approved-contract zststxbtc_v2-0 false))
		(try! (contract-call? .zststxbtc-v2_v2-0 set-approved-contract (as-contract tx-sender) false))
		(try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

		(ok true)
	)
)

(define-private (consolidate-balance (account principal))
  (let (
    (balance (unwrap-panic (contract-call? .zststxbtc-v2-0 get-principal-balance account)))
    )
	(if (> balance u0)
		(begin
			;; update user-reserve-data
			(match (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data account ststxbtc-address))
				found (try! (contract-call? .pool-reserve-data set-user-reserve-data account ststxbtc-address-v2 found))
				false
			)
			;; update user-index
			(try! (contract-call? .pool-reserve-data set-user-index account ststxbtc-address-v2 u100000000))
			(try! (add-supplied-asset account ststxbtc-address-v2))

			(try! (contract-call? .pool-reserve-data delete-user-reserve-data account ststxbtc-address))
			(try! (contract-call? .pool-reserve-data delete-user-index account ststxbtc-address))
			(try! (remove-supplied-asset account ststxbtc-address))

			(try! (contract-call? .zststxbtc-v2-0 burn balance account))
			(try! (contract-call? .zststxbtc-v2_v2-0 mint balance account))
			(ok true)
		)
		(ok false)
	)
  )
)

(define-private (add-supplied-asset (who principal) (asset principal))
	(let ((assets-data (get-user-assets who)))
		(if (is-none (index-of? (get assets-supplied assets-data) asset))
			(contract-call? .pool-reserve-data
				set-user-assets
				who
				{
					assets-supplied: (unwrap-panic (as-max-len? (append (get assets-supplied assets-data) asset) u100)),
					assets-borrowed: (get assets-borrowed assets-data)
				})
			(ok true)
		)
	)
)

(define-private (remove-supplied-asset (who principal) (asset principal))
	(let ((assets-data (get-user-assets who)))
		(contract-call? .pool-reserve-data
			set-user-assets
			who
			{
				assets-supplied: (get agg (fold filter-asset (get assets-supplied assets-data) { filter-by: asset, agg: (list) })),
				assets-borrowed: (get assets-borrowed assets-data)
			}
		)
	)
)


(define-private (get-user-assets (who principal))
	(default-to
		{ assets-supplied: (list), assets-borrowed: (list) }
		(contract-call? .pool-reserve-data get-user-assets-read who)))

(define-read-only (filter-asset (asset principal) (ret { filter-by: principal, agg: (list 100 principal) }))
	(if (is-eq asset (get filter-by ret))
		;; ignore, do not add
		ret
		;; add back to list
		{ filter-by: (get filter-by ret), agg: (unwrap-panic (as-max-len? (append (get agg ret) asset) u100)) }
	)
)


(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
	(match prior ok-value result err-value (err err-value))
)