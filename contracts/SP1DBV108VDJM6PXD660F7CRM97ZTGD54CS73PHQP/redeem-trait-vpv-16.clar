(use-trait registry-trait .registry-trait-vpv-16.registry-trait)
(use-trait bsd-trait .bsd-trait-vpv-16.bsd-trait)
(use-trait oracle-trait .oracle-trait-vpv-16.oracle-trait)
(use-trait vault-trait .vault-trait-vpv-16.vault-trait)
(use-trait sbtc-trait .sip-010-trait-ft-standard-vpv-16.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-16.sorted-vaults-trait)

(define-trait redeem-trait
  (
    (redeem-wrapper (uint (optional (buff 8192)) <bsd-trait> <sbtc-trait> <oracle-trait> <registry-trait> <vault-trait> <sorted-vaults-trait>) (response bool uint))
  )
)