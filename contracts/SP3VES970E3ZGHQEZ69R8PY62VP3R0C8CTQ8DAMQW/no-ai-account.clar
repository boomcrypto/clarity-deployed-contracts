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
        owner: 'SP3VES970E3ZGHQEZ69R8PY62VP3R0C8CTQ8DAMQW,
        sbtc: CANT-BE-EVIL-ADDRESS
    })
)