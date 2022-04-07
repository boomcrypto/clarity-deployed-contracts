(define-trait micro-dao 
    (
        (get-balance () (response uint uint))
        (get-proposal (uint) 
            (response 
                {
                    targets: (list 10 
                        {
                            address: principal,
                            amount: uint
                        }), 
                    proposer: principal,
                    created-at: uint,
                    status: uint,
                    total-amount: uint,
                    memo: (string-utf8 50)
                }
                uint
            )
        )
        (create-funding-proposal ((list 10 {address: principal, amount: uint}) (string-utf8 50)) (response bool uint))
        (dissent (uint) (response bool uint))
        (execute-funding-proposal (uint) (response bool uint))
        (deposit (uint) (response bool uint))
    )
)
