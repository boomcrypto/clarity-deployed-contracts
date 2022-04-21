(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait) 

(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant SELF (as-contract tx-sender))

(define-public (execute (spend uint))
    (begin 
        (try! (stx-transfer? spend tx-sender SELF))
        (let 
            (
                (swapped
                    (as-contract 
                        (unwrap-panic 
                            (element-at 
                                (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
                                    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                                    spend 
                                    u0)
                                )
                                u1
                            )
                        )
                    )
                )
            )

            (as-contract 
                (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-01 swap-helper 
                        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 
                        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                        (/ (* swapped ONE_8) ONE_6)
                        none)
                    )  
            )

            (ok (try! (stx-transfer? (stx-get-balance SELF) SELF tx-sender)))
        )
    )
)