;; --- 101BNS Team ----
;; Transfer BNS name between Standard Principal and Contract Principal

;; For simpler testing, switch between DEPLOYER_STANDARD and DEPLOYER_CONTRACT as sender and receiver.
(define-constant DEPLOYER_STANDARD_PRINCIPAL tx-sender)  ;; DEPLOYER will be set tx-sender during deploy.  Transaction sender is the address that deploy the contract.
(define-constant DEPLOYER_CONTRACT_PRINCIPAL (as-contract tx-sender))  ;; has same standard principal as the deployer

(define-constant BNS_NAMESPACE 0x737478)                        ;; buff 'stx'
(define-constant BNS_NAME      0x313031626e737465737430303031)  ;; buff '101bnstest0001'

(define-public (transfer-name-to-contract)
    (contract-call?
        'SP000000000000000000002Q6VF78.bns     ;; mainnet
        name-transfer 
        BNS_NAMESPACE
        BNS_NAME
        DEPLOYER_CONTRACT_PRINCIPAL  ;; new owner
        none ;; zonefile
    )
)

(define-public (transfer-name-from-contract)
    (as-contract
        (contract-call?
            'SP000000000000000000002Q6VF78.bns     ;; mainnet
            name-transfer 
            BNS_NAMESPACE
            BNS_NAME
            DEPLOYER_STANDARD_PRINCIPAL  ;; new owner
            none ;; zonefile
        )
    )
)
