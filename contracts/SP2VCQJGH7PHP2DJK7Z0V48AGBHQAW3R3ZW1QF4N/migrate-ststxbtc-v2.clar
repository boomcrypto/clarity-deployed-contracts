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
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant alex-address 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)


(define-constant ststxbtc-address-v2 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)


(define-constant zststxbtc_v2-0 .zststxbtc-v2-0)

(define-constant zststxbtc-v2-token .zststxbtc-v2-token)
(define-constant zststxbtc-v2_v2-0 .zststxbtc-v2_v2-0)

(define-constant ststxbtc-debts {
	ststx: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststx-address)),
	aeusdc: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address aeusdc-address)),
	wstx: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address wstx-address)),
	diko: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address diko-address)),
	usdh: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usdh-address)),
	susdt: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address susdt-address)),
	usda: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address usda-address)),
	sbtc: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address sbtc-address)),
	ststxbtc: (default-to u0 (contract-call? .pool-reserve-data-3 get-asset-isolation-mode-debt-read ststxbtc-address ststxbtc-address)),
})

(define-constant curve-params
	{
		base-variable-borrow-rate: u0,
		variable-rate-slope-1: u7000000,
		variable-rate-slope-2: u300000000,
		optimal-utilization-rate: u45000000,
		liquidation-close-factor-percent: u50000000,
		origination-fee-prc: u0,
		reserve-factor: u10000000,
	}
)

(define-public (run-update)
	(let (
		(ststxbtc-data
			(merge 
				(unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address))
				{
					a-token-address: zststxbtc-v2_v2-0,
					is-frozen: true
				}
			)
		)
		(ststx-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)) { is-frozen: true }))
		(aeusdc-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-address)) { is-frozen: true }))
		(wstx-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)) { is-frozen: true }))
		(diko-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read diko-address)) { is-frozen: true }))
		(usdh-data
			(merge  (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usdh-address)) { is-frozen: true }))
		(susdt-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read susdt-address)) { is-frozen: true }))
		(usda-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usda-address)) { is-frozen: true }))
		(sbtc-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)) { is-frozen: true }))
		(alex-data
			(merge (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read alex-address)) { is-frozen: true }))
	)
		(asserts! (not (var-get executed)) (err u10))
		(asserts! (is-eq deployer tx-sender) (err u11))

		;; pause reserves
		(try! (contract-call? .pool-borrow-v2-3 set-reserve ststx-address ststx-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve aeusdc-address aeusdc-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve wstx-address wstx-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve diko-address diko-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve usdh-address usdh-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve susdt-address susdt-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve usda-address usda-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve sbtc-address sbtc-data))
		(try! (contract-call? .pool-borrow-v2-3 set-reserve alex-address alex-data))

		;; update ststxbtc-v2
		(try! (contract-call? .pool-borrow-v2-3 set-reserve ststxbtc-address-v2 ststxbtc-data))

		;; add-asset
		(try! (contract-call? .pool-borrow-v2-3 remove-asset ststxbtc-address))
		(try! (contract-call? .pool-borrow-v2-3 add-asset ststxbtc-address-v2))


		;; add isolated asset
		(try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

		(try! (contract-call? .pool-reserve-data set-isolated-assets ststxbtc-address false))
		(try! (contract-call? .pool-reserve-data set-isolated-assets ststxbtc-address-v2 true))


		(try! (contract-call? .pool-reserve-data set-base-variable-borrow-rate ststxbtc-address-v2 (get base-variable-borrow-rate curve-params)))
		(try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 ststxbtc-address-v2 (get variable-rate-slope-1 curve-params)))
		(try! (contract-call? .pool-reserve-data set-variable-rate-slope-2 ststxbtc-address-v2 (get variable-rate-slope-2 curve-params)))
		(try! (contract-call? .pool-reserve-data set-optimal-utilization-rate ststxbtc-address-v2 (get optimal-utilization-rate curve-params)))
		(try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent ststxbtc-address-v2 (get liquidation-close-factor-percent curve-params)))
		(try! (contract-call? .pool-reserve-data set-origination-fee-prc ststxbtc-address-v2 (get origination-fee-prc curve-params)))
		(try! (contract-call? .pool-reserve-data set-reserve-factor ststxbtc-address-v2 (get reserve-factor curve-params)))

		(try! (contract-call? .pool-borrow-v2-3 set-grace-period-enabled ststxbtc-address-v2 false))
		(try! (contract-call? .pool-borrow-v2-3 set-freeze-end-block ststxbtc-address-v2 burn-block-height))


		;; STSTXBTC-V2 UPGRADE
		(try! (contract-call? .zststxbtc-v2-token set-approved-contract zststxbtc-v2_v2-0 true))
		(try! (contract-call? .zststx-token set-approved-contract zststxbtc_v2-0 false))
		;; permission to logic lp token
		;; revoke pool-borrow permissions to v1-2 version
		(try! (contract-call? .zststxbtc-v2-0 set-approved-contract .pool-borrow-v2-3 false))
		(try! (contract-call? .zststxbtc-v2-0 set-approved-contract .liquidation-manager-v2-3 false))
		(try! (contract-call? .zststxbtc-v2-0 set-approved-contract .pool-0-reserve-v2-0 false))

		;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
		(try! (contract-call? .zststxbtc-v2_v2-0 set-approved-contract .pool-borrow-v2-3 true))
		(try! (contract-call? .zststxbtc-v2_v2-0 set-approved-contract .liquidation-manager-v2-3 true))
		(try! (contract-call? .zststxbtc-v2_v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
		;; ===

		(try! (contract-call? .pool-reserve-data delete-reserve-state ststxbtc-address))

		(try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))


		(try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) true))

		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address ststx-address (get ststx ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address aeusdc-address (get aeusdc ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address wstx-address (get wstx ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address diko-address (get diko ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address usdh-address (get usdh ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address susdt-address (get susdt ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address usda-address (get usda ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address sbtc-address (get sbtc ststxbtc-debts)))
		(try! (contract-call? .pool-reserve-data-3 set-asset-isolation-mode-debt ststxbtc-address ststxbtc-address (get ststxbtc ststxbtc-debts)))

		(try! (contract-call? .pool-reserve-data-3 set-approved-contract (as-contract tx-sender) false))

		(var-set executed true)

		(ok true)
	)
)


(define-public (disable)
	(begin
		(asserts! (is-eq deployer tx-sender) (err u11))
		(ok (var-set executed true))
	)
)
