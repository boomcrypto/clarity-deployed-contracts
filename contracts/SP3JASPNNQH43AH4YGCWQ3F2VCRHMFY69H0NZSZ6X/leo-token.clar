(define-constant A tx-sender)

(define-public (transfer (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
	(a2 (unwrap-panic (contract-call?
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-x-for-y
		'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
		a1 u0)))
	(b2 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u6
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a2 u0)))
	(a3 (get amt-out b2))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))