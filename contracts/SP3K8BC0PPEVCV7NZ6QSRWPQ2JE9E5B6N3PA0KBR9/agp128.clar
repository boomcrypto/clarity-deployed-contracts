(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant amount u5000000)
(define-public (execute (sender principal))
    (begin
		(try! (contract-call? .amm-swap-pool set-fee-rebate .token-wxusd .token-wusda u500000 u50000000))
        (try! (contract-call? .amm-swap-pool set-fee-rebate .token-wstx .token-wcorgi ONE_8 u50000000))
        (try! (contract-call? .amm-swap-pool set-fee-rebate .age000-governance-token .token-wdiko ONE_8 u50000000))
                
		(try! (contract-call? .amm-swap-pool set-threshold-x .token-wxusd .token-wusda u500000 u1000000000))
		(try! (contract-call? .amm-swap-pool set-threshold-y .token-wxusd .token-wusda u500000 u1000000000))
        
        (try! (contract-call? .alex-vault add-approved-flash-loan-user .flash-loan-user-diko-to-wstx))
        (try! (contract-call? .alex-vault add-approved-flash-loan-user .flash-loan-user-wstx-to-diko))
        (ok true)
    )
)