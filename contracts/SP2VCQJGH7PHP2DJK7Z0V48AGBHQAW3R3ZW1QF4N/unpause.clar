(define-constant err-user-not-found (err u8000))

(define-constant deployer tx-sender)
(define-data-var executed bool false)

(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant diko-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant alex-address 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)
(define-constant ststxbtc-v2-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)


(define-public (run-update)
	(let (
		(ststx-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)) { is-frozen: false }))
		(aeusdc-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-address)) { is-frozen: false }))
		(wstx-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)) { is-frozen: false }))
		(diko-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read diko-address)) { is-frozen: false }))
		(usdh-data
			(merge  (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usdh-address)) { is-frozen: false }))
		(susdt-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read susdt-address)) { is-frozen: false }))
		(usda-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usda-address)) { is-frozen: false }))
		(sbtc-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)) { is-frozen: false }))
		(alex-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read alex-address)) { is-frozen: false }))
		(ststxbtc-v2-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-v2-address)) { is-frozen: false }))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		;; unpause reserves
		(try! (contract-call? .pool-borrow-v2-3 set-reserve ststx-address ststx-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve aeusdc-address aeusdc-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve wstx-address wstx-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve diko-address diko-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve usdh-address usdh-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve susdt-address susdt-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve usda-address usda-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve sbtc-address sbtc-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve alex-address alex-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve ststxbtc-v2-address ststxbtc-v2-data))

		(var-set executed true)

		(ok true)
	)
)
