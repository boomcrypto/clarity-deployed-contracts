
(define-public (get-usda-balance)
        (let 
            (
                (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance tx-sender)))
            )
            (ok balance)
        )
)
