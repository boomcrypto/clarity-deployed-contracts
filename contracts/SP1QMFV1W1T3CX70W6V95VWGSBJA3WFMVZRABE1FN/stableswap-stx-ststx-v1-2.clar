(define-constant A tx-sender)

(define-public (swap-x-for-y (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(a1 (unwrap-panic (contract-call?
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
		a0 u0)))
	(b1 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u8
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a1 u1)))
	(a2 (get amt-out b1))
	(b2 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u6
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a2 u1)))
	(a3 (get amt-out b2))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))

(define-public (swap-y-for-x (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
	(b0 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u6
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a0 u1)))
	(a1 (get amt-out b0))
	(b1 (try! (contract-call?
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
		u8
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
		'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
		'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
		a1 u1)))
	(a2 (get amt-out b1))
	(a3 (unwrap-panic (contract-call?
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
		'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
		'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
		a2 u0)))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	))))