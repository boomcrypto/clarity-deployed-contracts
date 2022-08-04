(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-public (execute (sender principal))
	(let 
		(
			(fwp-wmia-balance (unwrap-panic (contract-call? .fwp-wstx-wmia-50-50-v1-01 get-balance-fixed tx-sender)))
			(fwp-wnycc-balance (unwrap-panic (contract-call? .fwp-wstx-wnycc-50-50-v1-01 get-balance-fixed tx-sender)))
		)		
		(try! (contract-call? .fwp-wstx-wmia-50-50-v1-01 transfer-fixed fwp-wmia-balance tx-sender 'SP24ZWR8D62RGF2BZQM89DAPPJX9GY2G5NDVQNGNY none))
		(try! (contract-call? .fwp-wstx-wnycc-50-50-v1-01 transfer-fixed fwp-wnycc-balance tx-sender 'SP24ZWR8D62RGF2BZQM89DAPPJX9GY2G5NDVQNGNY none))
		(ok true)
	)
)