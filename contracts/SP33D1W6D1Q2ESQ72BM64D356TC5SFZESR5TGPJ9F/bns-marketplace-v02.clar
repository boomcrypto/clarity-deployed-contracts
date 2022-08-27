;; +--------------------------------------------------------
;; | BNS MARKETPLACE
;; --------------------------------------------------------

(define-constant DEPLOYER_STANDARD_PRINCIPAL tx-sender)  ;; deployer becomes the marketplace owner
(define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))  ;; has same standard principal as the deployer

;; List a BNS name
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

;; Buy a BNS name
(define-public (transfer-name-from-contract (namespace (buff 20)) (name (buff 48)))
    (let ((new-owner tx-sender))
        (as-contract
            (contract-call?
                'SP000000000000000000002Q6VF78.bns 
                name-transfer 
                namespace
                name
                new-owner  ;; new owner. this is supposedly the buyer. need guardrails.
                none ;; zonefile
            )
        )
    )
)