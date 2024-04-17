(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant emissions 
	(list 
		{ sft: false, token: .fwp-wstx-wbtc-50-50-v1-01, token-id: u0, amount: u116100 }
		{ sft: false, token: .fwp-alex-wban, token-id: u0, amount: u900 }
		{ sft: false, token: .fwp-alex-usda, token-id: u0, amount: u2250 }
		{ sft: false, token: .fwp-wstx-wxusd-50-50-v1-01, token-id: u0, amount: u4500 }
		{ sft: true, token: .token-amm-swap-pool-v1-1, token-id: u1, amount: u47500 }
		{ sft: true, token: .token-amm-swap-pool-v1-1, token-id: u8, amount: u4750 }
		{ sft: true, token: .token-amm-swap-pool-v1-1, token-id: u11, amount: u70950 }
		{ sft: true, token: .token-amm-swap-pool-v1-1, token-id: u14, amount: u450 }
	)
)
(define-public (execute (sender principal))
	(fold check-err (map execute-private emissions) (ok true)))
(define-private (execute-private (detail { sft: bool, token: principal, token-id: uint, amount: uint }))
	(let (
			(amount (* (get amount detail) ONE_8)))
		(if (get sft detail)
			(contract-call? .alex-reserve-pool-sft set-coinbase-amount (get token detail) (get token-id detail) amount amount amount amount amount)
			(contract-call? .alex-reserve-pool set-coinbase-amount (get token detail) amount amount amount amount amount))))
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))