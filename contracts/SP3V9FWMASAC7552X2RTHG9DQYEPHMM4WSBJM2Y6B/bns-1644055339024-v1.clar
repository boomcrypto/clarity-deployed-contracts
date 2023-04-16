(define-constant A tx-sender)

(define-public (change-price (a0 uint))
(begin
	(asserts! (is-eq tx-sender A) (err u0))
	(let (
		(b0 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
			a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
		(b1 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
			a1 u0)))
		(a2 (unwrap-panic (element-at b1 u1)))
		(b2 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda
			u500000 (* a2 u100) none)))
		(a3 (get dx b2))
		(b3 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
			u50000000 u50000000 a3 none)))
		(a4 (/ (get dx b3) u100))
	)
		(asserts! (> a4 a0) (err a4))
		(ok (list a0 a1 a2 a3 a4))
	)
))