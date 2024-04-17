(define-constant A tx-sender)

(define-public (claim-25-rewards-of (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-x-for-y
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvibes
		u100000000 (* a0 u100) none)))
	(a1 (get dy b0))
	(b1 (try! (contract-call?
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
		'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-v5kup9f32ck
		a1 u0)))
	(a2 (unwrap-panic (element-at b1 u0)))
	(b2 (try! (contract-call?
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k swap-y-for-x
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a
		'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw
		a2 u0)))
	(a3 (unwrap-panic (element-at b2 u0)))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))