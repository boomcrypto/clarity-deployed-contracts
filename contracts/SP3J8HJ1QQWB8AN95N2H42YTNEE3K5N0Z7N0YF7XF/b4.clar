(define-constant A tx-sender)

(define-public (z (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u1000))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
			'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
			u50000000 u50000000 (* a0 u100) none)))
		(a1 (get dy b0))
		(b1 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
			'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
			a1 u0)))
		(a2 (unwrap-panic (element-at b1 u1)))
		(b2 (try! (contract-call?
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
			'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
			a2 u0)))
		(a3 (unwrap-panic (element-at b2 u0)))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	)
	)
))