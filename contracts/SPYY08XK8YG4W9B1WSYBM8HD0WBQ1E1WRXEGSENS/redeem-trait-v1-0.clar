(use-trait registry-trait .registry-trait-v1-0.registry-trait)
(use-trait bsd-trait .bsd-trait-v1-0.bsd-trait)
(use-trait oracle-trait .oracle-trait-v1-0.oracle-trait)
(use-trait vault-trait .vault-trait-v1-0.vault-trait)
(use-trait sbtc-trait .sip-010-trait-ft-standard-v1-0.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-v1-0.sorted-vaults-trait)

(define-trait redeem-trait
  (
    (redeem-wrapper (uint (optional (buff 8192)) <bsd-trait> <sbtc-trait> <oracle-trait> <registry-trait> <vault-trait> <sorted-vaults-trait>) (response bool uint))
  )
)