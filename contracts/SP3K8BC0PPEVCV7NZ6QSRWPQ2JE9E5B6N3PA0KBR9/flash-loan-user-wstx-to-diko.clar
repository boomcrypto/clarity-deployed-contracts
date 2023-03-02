(impl-trait .trait-flash-loan-user.flash-loan-user-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-ARB-EXISTS (err u9000))
(define-public (execute (token <ft-trait>) (amount uint) (memo (optional (buff 16))))
    (let
        (               
            (swapped-to-diko
                (unwrap-panic 
                    (element-at 
                        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
                            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
                            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
                            (/ (* amount u1000000) ONE_8)
                            u0)
                        )
                        u1
                    )
                )
            )
            (swapped-to-alex (try! (contract-call? .amm-swap-pool swap-helper .token-wdiko .age000-governance-token ONE_8 (/ (* swapped-to-diko ONE_8) u1000000) none)))
            (swapped-back (try! (contract-call? .swap-helper-v1-03 swap-helper .age000-governance-token .token-wstx swapped-to-alex none)))
            (amount-with-fee (mul-up amount (+ ONE_8 (unwrap-panic (contract-call? .alex-vault get-flash-loan-fee-rate)))))
        )
        (ok (asserts! (>= swapped-back amount-with-fee) ERR-NO-ARB-EXISTS))
    )
)
(define-private (mul-up (a uint) (b uint))
    (let
        (
            (product (* a b))
       )
        (if (is-eq product u0)
            u0
            (+ u1 (/ (- product u1) ONE_8))
       )
   )
)