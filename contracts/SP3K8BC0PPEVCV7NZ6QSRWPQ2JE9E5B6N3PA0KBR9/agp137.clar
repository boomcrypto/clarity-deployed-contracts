(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
    (begin
    	(try! (contract-call? .amm-swap-pool set-oracle-enabled .token-wstx .token-susdt ONE_8 true))
		(try! (contract-call? .amm-swap-pool set-oracle-average .token-wstx .token-susdt ONE_8 u99000000))
    
		(try! (contract-call? .amm-swap-pool set-fee-rebate .token-wstx .token-susdt ONE_8 u50000000))
                
		(try! (contract-call? .amm-swap-pool set-threshold-x .token-wstx .token-susdt ONE_8 u10000000000))
		(try! (contract-call? .amm-swap-pool set-threshold-y .token-wstx .token-susdt ONE_8 u10000000000))
          
        (ok true)
    )
)