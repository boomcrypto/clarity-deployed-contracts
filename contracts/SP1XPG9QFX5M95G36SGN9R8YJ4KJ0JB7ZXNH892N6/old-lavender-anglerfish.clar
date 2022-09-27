(define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))

(define-public (transfer-name-to-contract (namespace (buff 20)) (name (buff 48)))
    (contract-call?
        'SP000000000000000000002Q6VF78.bns
        name-transfer 
        namespace
        name
        DEPLOYER_CONTRACT_PRINCIPAL  ;; new owner. for mvp version, escrow to marketplace itself.
        none ;; zonefile
    )
)

(define-public (transfer-name-from-contract (namespace (buff 20)) (name (buff 48)) (recipient principal))
    (let ((new-owner tx-sender))
        (as-contract
            (contract-call?
                'SP000000000000000000002Q6VF78.bns 
                name-transfer 
                namespace
                name
                recipient  ;; new owner. this is supposedly the buyer. need guardrails.
                none ;; zonefile
            )
        )
    )
)

(transfer-name-to-contract 0x6c6761 0x627463)