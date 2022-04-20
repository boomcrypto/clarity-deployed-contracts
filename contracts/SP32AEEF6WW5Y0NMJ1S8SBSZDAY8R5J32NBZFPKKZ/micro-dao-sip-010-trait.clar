(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-trait micro-dao-sip-010-trait
    (
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
                    token-contract: principal,
                    total-amount: uint,
                    memo: (string-utf8 50)
                }
                uint
            )
        )
        (create-funding-proposal ((list 10 {address: principal, amount: uint}) (string-utf8 50) <sip-010-trait>) (response bool uint))
        (dissent (uint) (response bool uint))
        (execute-funding-proposal (uint <sip-010-trait>) (response bool uint))
        (deposit (<sip-010-trait> uint) (response bool uint))
    )
)
