(define-constant A tx-sender)
(define-public (allow-contract-caller (a0 uint))
(begin
	(asserts! (is-eq tx-sender A) (err u0))
	(let (
		(b0 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-x-for-y
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
			u100000000 (* a0 u100) none)))
		(a1 (get dy b0))
		(b1 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-x-for-y
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
			u5000000 a1 none)))
		(a2 (get dy b1))
		(b2 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
			u50000000 u50000000 a2 none)))
		(a3 (/ (get dx b2) u100))
	)
		(asserts! (> a3 a0) (err a3))
		(ok a3)
	)
))