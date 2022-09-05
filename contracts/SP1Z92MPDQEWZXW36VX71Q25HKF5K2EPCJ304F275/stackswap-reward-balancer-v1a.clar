(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-constant ERR_AMT u000001)
(define-constant ERR_INVALID_CALLER u000002)
(define-constant WRONG_FARM_TYPE u000002)
(define-constant ADMIN_PRINCIPAL tx-sender)

(define-data-var first_ bool true)
(define-data-var second_ bool true)
(define-data-var third_ bool false)


(define-public (setup-contract (first bool) (second bool) (third bool))
  (begin
    (var-set first_ first)
    (var-set second_ second)
    (var-set third_ third)
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private (getContractBalance
    (token <sip-010-token>) 
 )
    (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))
)

(define-private (getUserBalance
    (token <sip-010-token>) 
 )
    (unwrap-panic (contract-call? token get-balance tx-sender))
)

(define-private (ONESTEP_STSW_LBTC
    (STSW_AMT uint)
 )   
    (let 
        (              
            (initSTSWAmt (getContractBalance .stsw-token-v4a))
            (initlBTCAmt (getContractBalance .lbtc-token-v1c))
        ) 
        (asserts! (or (>= initSTSWAmt STSW_AMT) (> STSW_AMT u0)) (err ERR_AMT))
        (try! (as-contract (contract-call? .stackswap-swap-v5k swap-x-for-y .stsw-token-v4a .lbtc-token-v1c .liquidity-token-v5krqbd8nh6 STSW_AMT u0)))
        (let 
            (
                (afterlBTCAmt (getContractBalance .lbtc-token-v1c))
            )
            (asserts! (>= afterlBTCAmt initlBTCAmt) (err ERR_AMT))
            (try! (as-contract (contract-call? .stackswap-swap-v5k swap-y-for-x .stsw-token-v4a .lbtc-token-v1c .liquidity-token-v5krqbd8nh6 (- afterlBTCAmt initlBTCAmt) u0)))
            (ok (- (getContractBalance .stsw-token-v4a) (- initSTSWAmt STSW_AMT)))
        )
    )
)


(define-public (CLAIM_FROM_FARM
    (farm_type uint)
    (round uint) 
    (pool <liquidity-token>) 
    (oracle <oracle-trait>)
 )   
    (let 
        (
            (beforeSTSWAmtUser (getUserBalance .stsw-token-v4a))
        )
        (if (is-eq farm_type u1)
            (try! (contract-call? .stackswap-farming-v2c1 claimStakingReward round pool oracle))
            (if (is-eq farm_type u2) 
                (try! (contract-call? .stackswap-farming-v2c2 claimStakingReward round pool oracle))
                (if (is-eq farm_type u2) 
                    (try! (contract-call? .stackswap-farming-v2c5 claimStakingReward round pool oracle))
                    false
                )
            )
        )
        (let 
            (   
                (claimed_amt (- (getUserBalance .stsw-token-v4a) beforeSTSWAmtUser))
                (stsw-transfer-res (try! (contract-call? .stsw-token-v4a transfer claimed_amt tx-sender (as-contract tx-sender) none)))
                (claimed_amt2 (if (var-get first_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt))
                        claimed_amt
                    )
                )
                (claimed_amt3 (if (var-get second_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt2))
                        claimed_amt2
                    )
                ) 
                (claimed_amt4 (if (var-get third_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt3))
                        claimed_amt3
                    )
                ) 
                (user tx-sender)
            )
            (try! (as-contract (contract-call? .stsw-token-v4a transfer claimed_amt4 tx-sender user  none)))
            (ok claimed_amt4)
        )
    )
)


(define-public (CLAIM_FROM_STSW_STAKING
    (round uint)
 )   
    (let 
        (
            (beforeSTSWAmtUser (getUserBalance .stsw-token-v4a))
        )
        (try! (contract-call? .stackswap-stsw-staking-logic-v2a claim-staking-reward round))

        (let 
            (   
                (claimed_amt (- (getUserBalance .stsw-token-v4a) beforeSTSWAmtUser))
                (stsw-transfer-res (try! (contract-call? .stsw-token-v4a transfer claimed_amt tx-sender (as-contract tx-sender) none)))
                (claimed_amt2 (if (var-get first_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt))
                        claimed_amt
                    )
                )
                (claimed_amt3 (if (var-get second_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt2))
                        claimed_amt2
                    )
                ) 
                (claimed_amt4 (if (var-get third_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt3))
                        claimed_amt3
                    )
                ) 
                (user tx-sender)
            )
            (try! (as-contract (contract-call? .stsw-token-v4a transfer claimed_amt4 tx-sender user  none)))
            (ok claimed_amt4)
        )
    )
)

(define-public (CLAIM_FROM_LBTC_STAKING
    (round uint)
 )   
    (let 
        (
            (beforeSTSWAmtUser (getUserBalance .stsw-token-v4a))
        )
        (try! (contract-call? .stackswap-lbtc-staking-logic-v3a claim-staking-reward round))
        (let 
            (   
                (claimed_amt (- (getUserBalance .stsw-token-v4a) beforeSTSWAmtUser))
                (stsw-transfer-res (try! (contract-call? .stsw-token-v4a transfer claimed_amt tx-sender (as-contract tx-sender) none)))
                (claimed_amt2 (if (var-get first_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt))
                        claimed_amt
                    )
                )
                (claimed_amt3 (if (var-get second_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt2))
                        claimed_amt2
                    )
                ) 
                (claimed_amt4 (if (var-get third_)
                        (try! (ONESTEP_STSW_LBTC claimed_amt3))
                        claimed_amt3
                    )
                ) 
                (user tx-sender)
            )
            (try! (as-contract (contract-call? .stsw-token-v4a transfer claimed_amt3 tx-sender user  none)))
            (ok claimed_amt3)
        )
    )
)