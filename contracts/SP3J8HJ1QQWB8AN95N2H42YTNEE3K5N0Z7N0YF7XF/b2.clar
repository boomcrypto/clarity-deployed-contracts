(define-constant A tx-sender)

(define-public (z (a0 uint))
(begin
	(asserts! (is-eq tx-sender A) (err u1000))
	(let (
		(b0 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
			u50000000 u50000000 (* a0 u100) none)))
		(a1 (get dy b0))
		(b1 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
			'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
			a1 u0)))
		(a2 (unwrap-panic (element-at b1 u0)))
	)
		(asserts! (> a2 a0) (err u1001))
		(ok (list a0 a1 a2))
	)
))