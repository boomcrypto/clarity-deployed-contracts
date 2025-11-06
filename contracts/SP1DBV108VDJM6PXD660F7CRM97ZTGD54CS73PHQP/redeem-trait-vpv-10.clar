(use-trait registry-trait .registry-trait-vpv-10.registry-trait)
(use-trait bsd-trait .bsd-trait-vpv-10.bsd-trait)
(use-trait oracle-trait .oracle-trait-vpv-10.oracle-trait)
(use-trait vault-trait .vault-trait-vpv-10.vault-trait)
(use-trait sbtc-trait .sip-010-trait-ft-standard-vpv-10.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-10.sorted-vaults-trait)

(define-trait redeem-trait
  (
    (redeem-wrapper (uint (optional (buff 8192)) <bsd-trait> <sbtc-trait> <oracle-trait> <registry-trait> <vault-trait> <sorted-vaults-trait>) (response bool uint))
  )
)