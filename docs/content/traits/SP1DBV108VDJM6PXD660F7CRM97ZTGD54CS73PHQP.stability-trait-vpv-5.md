---
title: "Trait stability-trait-vpv-5"
draft: true
---
```
(use-trait registry-trait .registry-trait-vpv-5.registry-trait)
(use-trait bsd-trait .bsd-trait-vpv-5.bsd-trait)
(use-trait oracle-trait .oracle-trait-vpv-5.oracle-trait)
(use-trait sbtc-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-5.sorted-vaults-trait)

(define-trait stability-trait
  (
    (add-liquidity-wrapper (uint <bsd-trait> <sbtc-trait> <registry-trait> <sorted-vaults-trait>) (response (optional (tuple (liquidity-staked uint) (product_t uint) (sum_t uint) (checkpoint uint))) uint))
    (remove-liquidity-wrapper (uint <bsd-trait> <sbtc-trait> <registry-trait> <sorted-vaults-trait>) (response (optional (tuple (liquidity-staked uint) (product_t uint) (sum_t uint) (checkpoint uint))) uint))
    (vault-manager-burn (uint <bsd-trait> <registry-trait>) (response bool uint))
    (protocol-transfer (principal uint <bsd-trait> <registry-trait>) (response bool uint))
    (claim-rewards (<sbtc-trait> <registry-trait>) (response bool uint))
  )
) 
```
