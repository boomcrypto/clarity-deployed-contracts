(define-data-var executed bool false)


(define-constant stx-address .wstx)
(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant stx-oracle .stx-btc-oracle-v1-4)
(define-constant ststx-oracle .stx-btc-oracle-v1-4)
(define-constant ststxbtc-oracle .stx-btc-oracle-v1-4)
(define-constant sbtc-oracle .stx-btc-oracle-v1-4)

(define-public (execute (sender principal))
	(let (
		(reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read stx-address)))
		(reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
		(reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address)))
		(reserve-data-4 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
	)
		(asserts! (not (var-get executed)) (err u10))

		(print reserve-data-1)
		(print reserve-data-2)
		(print reserve-data-3)
		(print reserve-data-4)

		(try!
			(contract-call? .pool-borrow-v2-4 set-reserve stx-address
				(merge reserve-data-1 { oracle: stx-oracle })
			)
		)
		(try!
			(contract-call? .pool-borrow-v2-4 set-reserve ststx-address
				(merge reserve-data-2 { oracle: ststx-oracle })
			)
		)
		(try!
			(contract-call? .pool-borrow-v2-4 set-reserve ststxbtc-address
				(merge reserve-data-3 { oracle: ststxbtc-oracle })
			)
		)
		(try!
			(contract-call? .pool-borrow-v2-4 set-reserve sbtc-address
				(merge reserve-data-4 { oracle: sbtc-oracle })
			)
		)

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
