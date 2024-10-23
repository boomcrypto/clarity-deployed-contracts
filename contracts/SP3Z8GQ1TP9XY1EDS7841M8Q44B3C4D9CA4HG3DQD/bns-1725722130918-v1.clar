(define-constant A tx-sender)

(define-public (purchase-name (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
		'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
		'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxbtc
		u100000000 (* a0 u100) none)))
	(a1 (get dy b0))
	(a2 (unwrap-panic (contract-call?
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-abtc-xbtc-v-1-2 swap-y-for-x
		'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.abtc-xbtc-lp-token-v-1-2
		a1 u0)))
	(b2 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u3
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
		'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a2 u1)))
	(a3 (get amt-out b2))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))