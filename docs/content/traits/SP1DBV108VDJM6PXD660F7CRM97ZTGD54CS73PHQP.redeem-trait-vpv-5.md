---
title: "Trait redeem-trait-vpv-5"
draft: true
---
```
(use-trait registry-trait .registry-trait-vpv-5.registry-trait)
(use-trait bsd-trait .bsd-trait-vpv-5.bsd-trait)
(use-trait oracle-trait .oracle-trait-vpv-5.oracle-trait)
(use-trait vault-trait .vault-trait-vpv-5.vault-trait)
(use-trait sbtc-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-5.sorted-vaults-trait)

(define-trait redeem-trait
  (
    (redeem-wrapper (uint <bsd-trait> <sbtc-trait> <oracle-trait> <registry-trait> <vault-trait> <sorted-vaults-trait>) (response bool uint))
  )
)
```
