(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unknown-asset-principal (err u3502))
(define-private (transfer-in (amount uint) (user-id uint) (asset-id uint) (asset principal))
    (if (is-eq asset .token-susdt)
        (contract-call? .stxdx-wallet-zero transfer-in amount user-id asset-id .token-susdt)
        (if (is-eq asset .token-wbtc)
            (contract-call? .stxdx-wallet-zero transfer-in amount user-id asset-id .token-wbtc)
            (if (is-eq asset .age000-governance-token)
                (contract-call? .stxdx-wallet-zero transfer-in amount user-id asset-id .age000-governance-token)
                (if (is-eq asset .token-wstx)
                    (contract-call? .stxdx-wallet-zero transfer-in amount user-id asset-id .token-wstx)
                    err-unknown-asset-principal
                )                
            )
        )
    )
)
(define-public (transfer-in-many (user-id uint) (amounts (list 10 uint)) (asset-ids (list 10 uint)) (assets (list 10 principal)))
    (ok 
        (map transfer-in 
            amounts
            (list user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id)
            asset-ids
            assets
        )
    )
)
(define-public (register-and-deposit (pub-key (buff 33)) (amounts (list 10 uint)) (asset-ids (list 10 uint)) (assets (list 10 principal)))
    (transfer-in-many (try! (contract-call? .stxdx-registry register-user pub-key)) amounts asset-ids assets)
)