(use-trait ft-trait .sip-010-v1a.sip-010-trait)
(use-trait vault-trait .stackswap-vault-trait-v1b.vault-trait)
(use-trait collateral-types-trait .stackswap-collateral-types-trait-v1b.collateral-types-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)

(define-trait vault-manager-trait
  (

    (get-collateral-type-for-vault (uint) (response (string-ascii 12) bool))
    (calculate-current-collateral-to-debt-ratio (uint <collateral-types-trait> <oracle-trait> bool) (response uint uint))

    (pay-stability-fee (uint <collateral-types-trait>) (response uint uint))
    (accrue-stability-fee (uint <collateral-types-trait>) (response bool uint))

    (finalize-liquidation (uint) (response bool uint))

    (get-lbtc-balance () (response uint bool))
  )
)
