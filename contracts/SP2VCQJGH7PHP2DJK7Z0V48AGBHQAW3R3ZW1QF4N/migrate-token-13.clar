(define-constant err-user-not-found (err u8000))

(define-constant ststxbtc-address-v2 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)

(define-constant zststxbtc_v2-0 .zststxbtc-v2-0)


(define-constant deployer tx-sender)
(define-data-var executed bool false)

(define-constant ststxbtc-holders (list
'SPG8J970FVRT4GZHKZJ0MC8819ZBN9S1QZ6Z9BKG
'SP1D0DYDKRSF5CSJ7QNMJZEWKVEJWSJ9A8T0V891X
'SP4KBYFKW8S98YFVN2P816FXGNVCFEN9THK6ABDX
'SP24WS3W13JK7W2S1W7XGES386CJ91W783RK140WY
'SP30R04XNAQAFXRRBG83G4JK99E5628T0J40B9QWA
'SP3ND3H6QF7RW2H3TM4MA316Y1J158SFWS6YDD83Z
'SP3AR8D1JAC5VKZ5FFJ90R7M6TD3NVJYV0X55P2DM
'SP3PKRBPR9JVA3C4DB1X6AB8BPWWMZFK158GC7RA1
'SP99GMESHFA1WBXXNY7R1V2SD9TV9VWGM62GRT7S
'SP1FSX9QG8K0ZBFM104737ZN8KMB5S6PCM8J7TGMP
'SP1N29JZHE36RR6C0XD4HC9VGRJDC79Q2JY6WCKW9
'SP3N2RARPZ4FZP7JHJTXF30NAHQ0T9EYG4QZG4DJ5
'SP2FZE6EAYZ2VTJK2JKHR22XGYA5ZKXY1YYTVB1GW
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