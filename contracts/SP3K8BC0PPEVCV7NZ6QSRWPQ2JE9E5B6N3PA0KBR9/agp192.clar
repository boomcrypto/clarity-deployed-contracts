(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant emissions 
	(list 
		{ sft: false, token: .fwp-wstx-wbtc-50-50-v1-01, token-id: u0, amount: u0 }
		{ sft: false, token: .fwp-alex-wban, token-id: u0, amount: u700 }
		{ sft: false, token: .fwp-alex-usda, token-id: u0, amount: u1750 }
		{ sft: false, token: .fwp-wstx-wxusd-50-50-v1-01, token-id: u0, amount: u3500 }
	)
)
(define-public (execute (sender principal))
	(fold check-err (map execute-private emissions) (ok true)))
(define-private (execute-private (detail { sft: bool, token: principal, token-id: uint, amount: uint }))
	(let (
			(amount (* (get amount detail) ONE_8)))
			(contract-call? .alex-reserve-pool set-coinbase-amount (get token detail) amount amount amount u0 u0)))
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))