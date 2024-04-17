(define-constant A tx-sender)

(define-public (stake (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-x-for-y
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5k0yl5ot8l
		a0 u0)))
	(a1 (unwrap-panic (element-at b0 u1)))
	(a2 (unwrap-panic (contract-call?
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-susdt-v-1-2 swap-x-for-y
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2
		a1 u0)))
	(b2 (try! (contract-call?
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool swap-y-for-x
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
		u100000000 a2 none)))
	(a3 (/ (get dx b2) u100))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))