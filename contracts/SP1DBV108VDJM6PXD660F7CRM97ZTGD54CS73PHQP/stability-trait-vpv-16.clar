(use-trait registry-trait .registry-trait-vpv-16.registry-trait)
(use-trait bsd-trait .bsd-trait-vpv-16.bsd-trait)
(use-trait oracle-trait .oracle-trait-vpv-16.oracle-trait)
(use-trait sbtc-trait .sip-010-trait-ft-standard-vpv-16.sip-010-trait)
(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-16.sorted-vaults-trait)

(define-trait stability-trait
  (
    (add-liquidity-wrapper (uint <bsd-trait> <sbtc-trait> <registry-trait> <sorted-vaults-trait>) (response (optional (tuple (liquidity-staked uint) (product_t uint) (sum_t uint) (scale_t uint))) uint))
    (remove-liquidity-wrapper (uint <bsd-trait> <sbtc-trait> <registry-trait> <sorted-vaults-trait>) (response (optional (tuple (liquidity-staked uint) (product_t uint) (sum_t uint) (scale_t uint))) uint))
    (protocol-burn-bsd (uint <bsd-trait> <registry-trait>) (response bool uint))
    (protocol-transfer-bsd (principal uint <bsd-trait>) (response bool uint))
    (protocol-transfer-sbtc (principal uint <sbtc-trait>) (response bool uint))
    (claim-rewards (<sbtc-trait> <registry-trait>) (response bool uint))
  )
) 