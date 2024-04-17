(define-read-only (six-to-eight (n uint))
    (/ (* n u100000000) u1000000)
)

(define-public (execute_ (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                u100000000 
                (six-to-eight in) 
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            
            (unwrap-panic (contract-call? 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-susdt-v-1-2 swap-y-for-x 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt 
                'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-susdt-lp-token-v-1-2 
                (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance tx-sender)) 
                u0
            ))

            (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda 
                'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 
                (six-to-eight (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
                none
            ))
        
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mout) (err u400))
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (execute (dd uint) (mr uint))
    (ok (list 
        (execute_ dd mr)
    ))
)