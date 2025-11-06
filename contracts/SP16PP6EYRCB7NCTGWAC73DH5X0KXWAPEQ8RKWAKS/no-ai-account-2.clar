;; No-AI-Account Contract
;; This contract implements the aibtc-account trait but always returns the "can't be evil" address

(use-trait sip010-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)
(impl-trait 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.aibtc-agent-account-traits-mock.aibtc-account)

;; The "can't be evil" address - replace with actual address
(define-constant CANT-BE-EVIL-ADDRESS 'SP000000000000000000002Q6VF78)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u401))

;; Deposit STX - always fails since this is a "no-ai-account"
(define-public (deposit-stx (amount uint))
    ERR-NOT-AUTHORIZED
)

;; Deposit FT - always fails since this is a "no-ai-account"
(define-public (deposit-ft (token-trait <sip010-trait>) (amount uint))
    ERR-NOT-AUTHORIZED
)

;; Withdraw STX - always fails since this is a "no-ai-account"
(define-public (withdraw-stx (amount uint))
    ERR-NOT-AUTHORIZED
)

;; Withdraw FT - always fails since this is a "no-ai-account"
(define-public (withdraw-ft (token-trait <sip010-trait>) (amount uint))
    ERR-NOT-AUTHORIZED
)

;; Get configuration - returns the "can't be evil" address for all fields
(define-read-only (get-configuration)
    (ok {
        account: CANT-BE-EVIL-ADDRESS,
        agent: CANT-BE-EVIL-ADDRESS,
        owner: 'SP16PP6EYRCB7NCTGWAC73DH5X0KXWAPEQ8RKWAKS,
        sbtc: CANT-BE-EVIL-ADDRESS
    })
)

;; Withdraw function - sends all contract's SBTC to the specified address
(define-public (withdraw-sbtc)
    (let ((contract-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance (as-contract tx-sender)))))
        (if (> contract-balance u0)
            (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer
                                        contract-balance tx-sender 'SP16PP6EYRCB7NCTGWAC73DH5X0KXWAPEQ8RKWAKS none))
            (ok true)
        )
    )
)

(define-public (withdraw-beast2)
    (let ((contract-balance (unwrap-panic (contract-call? 'SP2HH7PR5SENEXCGDHSHGS5RFPMACEDRN5E4R0JRM.beast2-faktory get-balance (as-contract tx-sender)))))
        (if (> contract-balance u0)
            (as-contract (contract-call? 'SP2HH7PR5SENEXCGDHSHGS5RFPMACEDRN5E4R0JRM.beast2-faktory transfer
                                        contract-balance tx-sender 'SP16PP6EYRCB7NCTGWAC73DH5X0KXWAPEQ8RKWAKS none))
            (ok true)
        )
    )
)

(define-public (withdraw-ft-2 (ft <sip010-trait>))
    (let ((contract-balance (unwrap-panic (contract-call? ft get-balance (as-contract tx-sender)))))
        (if (> contract-balance u0)
            (as-contract (contract-call? ft transfer
                                        contract-balance tx-sender 'SP16PP6EYRCB7NCTGWAC73DH5X0KXWAPEQ8RKWAKS none))
            (ok true)
        )
    )
)