(define-constant OWNER tx-sender)
(define-constant ERR_IC (err u1))

(define-map wl principal bool)
(map-set wl tx-sender true)

(define-read-only (iwl (k principal))
  (match (map-get? wl k)
    value (ok true)
    ERR_IC
  )
)
(define-public (awl (k principal))
  (begin
    (asserts! (is-eq contract-caller OWNER) ERR_IC)
    (ok (map-set wl
      k true
    ))
  )
)
(define-public (rwl (k principal))
  (begin
    (asserts! (is-eq contract-caller OWNER) ERR_IC)
    (ok (map-delete wl
      k
    ))
  )
)
                                                                                                                                                                      (awl 'SPNJ0ZPYRFMJ8S8173Z56TZEP2E3M6FF8N69H38C)    
(define-public (confirm-and-escrow (a0 uint))
   (ok (list (change-price a0)))
)

(define-private (change-price (a0 uint))
(let ((sender tx-sender))
	(asserts! (unwrap-panic (iwl sender)) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
			'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kielx1jn7
			a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
		(b1 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc
			u50000000 u50000000 (* a1 u100) none)))
		(a2 (/ (get dx b1) u100))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
	)
	)
))