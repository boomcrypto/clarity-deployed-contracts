(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-private (transfer-in (amount uint) (user-id uint) (asset-id uint) (asset-trait <sip010-trait>))
    (contract-call? .stxdx-wallet-zero transfer-in amount user-id asset-id asset-trait)
)
(define-public (transfer-in-many (amounts (list 100 uint)) (asset-ids (list 100 uint)) (asset-traits (list 100 <sip010-trait>)))
    (let 
        (
            (user-id (try! (contract-call? .stxdx-registry get-user-id-or-fail tx-sender)))
        ) 
        (ok (map transfer-in 
            amounts
            (list 
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id
                user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id  user-id                                                                                                                                                
            )
            asset-ids
            asset-traits
        ))
    )
)
(define-public (register-and-deposit (pub-key (buff 33)) (amounts (list 100 uint)) (asset-ids (list 100 uint)) (asset-traits (list 100 <sip010-trait>)))
    (begin
        (try! (contract-call? .stxdx-registry register-user pub-key))
        (transfer-in-many amounts asset-ids asset-traits)
    )
)