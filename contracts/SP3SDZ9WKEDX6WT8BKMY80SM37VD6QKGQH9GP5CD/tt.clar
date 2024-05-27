(define-constant M tx-sender)

(define-public (tt)
	(let (
			(before (stx-get-balance tx-sender))
			(a1 (unwrap-panic (contract-call?
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
					u6
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
					'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
					'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
					before u1
				)))
			(a2 (unwrap-panic (contract-call?
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 add-liquidity
				'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
				'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
				u0
				(unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender))
				u0
			)))
			(a3 (unwrap-panic (contract-call?
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2
				withdraw-liquidity
				'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
				'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
				(unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2 get-balance tx-sender))
				u0
				u0
			)))
			(a4 (unwrap-panic (contract-call?
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-2 swap-x-for-y
				'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
				'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
				'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2
				(unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)) u0)))
			(a99 (unwrap-panic (contract-call?
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
					u6
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
					'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
					'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
					'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
					(unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance tx-sender)) u1
				)))
			(after (stx-get-balance tx-sender))
		)
		(asserts! (< before after) (err u1))
		(asserts! (is-eq tx-sender M) (err u2))
		(ok u0)
	)
)