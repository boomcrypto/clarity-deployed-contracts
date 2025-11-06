;; Pre-launch Contract Trait v1.1
;; Defines the interface for pre-launch token aibtc faktory contracts
;; Updated to support cross-chain seat purchasing

(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

(define-trait prelaunch-trait
  (
    ;; Core pre-launch functions
    (buy-up-to (uint (optional principal)) (response bool uint))
    (refund () (response bool uint))
    (claim (<faktory-token>) (response uint uint))
    (claim-on-behalf (<faktory-token> principal) (response uint uint))
    
    ;; Fee distribution system
    (trigger-fee-airdrop () (response uint uint))
  )
)