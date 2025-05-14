---
title: "Trait registry-trait-v0-1"
draft: true
---
```
(define-trait registry-trait
  (
    (get-stability-pool-data () (response (tuple (aggregate-bsd uint) (aggregate-sbtc uint) (active (list 1000 principal)) (product uint) (current-checkpoint uint)) uint))
    (get-stability-pool-provider (principal) (response (optional (tuple (liquidity-staked uint) (sum_t uint) (product_t uint) (checkpoint uint))) uint))
    (calculate-provider-rewards (principal) (response uint uint))
    (calculate-compounded-deposit (principal) (response uint uint))
    (get-provider-calculated-balance (principal) (response uint uint))
    (get-is-paused () (response bool uint))
    (get-decay-rates () (response (list 500 uint) uint))
    (get-protocol-fee-destination () (response principal uint))
    (get-active-vaults () (response uint uint))
    (get-aggregate-debt-and-collateral () (response (tuple (debt-bsd uint) (collateral-sbtc uint)) uint))
    (get-vault (uint) (response (optional (tuple (borrower principal) (created-height uint) (borrowed-bsd uint) (collateral-sbtc uint) (protocol-debt-bsd uint) (protocol-collateral-sbtc uint) (protocol-sum-collateral-sbtc uint) (interest-rate uint) (last-interest-accrued uint) (future-interest-rate uint) (future-interest-epoch uint) (interest-rate-delegate principal))) uint))
    (get-vault-accrued-interest (uint) (response uint uint))
    (get-vault-protocol-shares (uint) (response (tuple (calculated-protocol-debt uint) (calculated-protocol-collateral uint) (attributed-protocol-debt uint) (attributed-protocol-collateral uint)) uint))
    (get-vault-compounded-info (uint uint) (response (tuple (vault-total-debt uint) (vault-total-collateral uint) (vault-debt uint) (vault-collateral uint) (vault-protocol-debt uint) (vault-protocol-collateral uint) (vault-protocol-debt-calculated uint) (vault-protocol-collateral-calculated uint) (vault-collateral-ratio uint) (calculated-block uint) (vault-accrued-interest uint)) uint))
    (get-height-since-last-redeem () (response uint uint))
    (get-base-rate () (response uint uint))
    (get-redemption-batch-info (uint) (response (tuple (vaults (list 10 uint)) (total-redeem-value uint)) uint))
    (calculate-redeem-fee-rate (uint) (response uint uint))
    (calculate-borrow-fee-rate (bool) (response uint uint))
    (get-base-rate-constants () (response (tuple (alpha uint) (delta uint)) uint))
    (set-protocol-state (uint) (response bool uint))
    (set-decay-parameters (uint uint uint (list 500 uint) uint uint) (response bool uint))
    (set-borrow-parameters (uint uint uint) (response bool uint))
    (set-redeem-parameters (uint uint uint uint uint) (response bool uint))
    (set-vault-parameters (uint uint uint uint) (response bool uint))
    (set-global-parameters (uint uint principal uint uint uint) (response bool uint))
    (get-protocol-data (uint) (response (tuple (current-oracle-price-sbtc uint) (global-ratio uint) (recovery-mode bool) (total-collateral-in-bsd uint) (total-bsd-loans uint) (total-sbtc-collateral uint) (active-vaults uint) (created-vaults uint) (is-paused bool) (is-maintenance bool) (base-rate uint) (last-redeem-height uint) (vault-threshold uint) (recovery-threshold uint) (global-threshold uint) (global-collateral-cap uint) (protocol-fee-destination principal) (epoch-genesis uint) (alpha uint) (delta uint) (min-borrow-fee uint) (max-vaults-to-redeem uint) (max-borrow-fee uint) (min-redeem-fee uint) (max-redeem-fee uint) (min-redeem-amount uint) (min-stability-provider-balance uint) (max-decay uint) (max-hours-decay uint) (blocks-per-hour uint) (vault-loan-minimum uint) (vault-interest-minimum uint) (vault-interest-maximum uint) (hours-per-epoch uint) (oracle-stale-threshold uint)) uint))
    (get-protocol-attributes () (response (tuple (total-bsd-loans uint) (total-sbtc-collateral uint) (active-vaults uint) (created-vaults uint) (is-paused bool) (is-maintenance bool) (base-rate uint) (last-redeem-height uint) (vault-threshold uint) (recovery-threshold uint) (global-threshold uint) (global-collateral-cap uint) (protocol-fee-destination principal) (epoch-genesis uint) (alpha uint) (delta uint) (min-borrow-fee uint) (max-borrow-fee uint) (min-redeem-fee uint) (max-redeem-fee uint) (min-redeem-amount uint) (max-vaults-to-redeem uint) (min-stability-provider-balance uint) (max-decay uint) (max-hours-decay uint) (blocks-per-hour uint) (vault-loan-minimum uint) (vault-interest-minimum uint) (vault-interest-maximum uint) (hours-per-epoch uint) (oracle-stale-threshold uint)) uint))
    (get-vault-protocol-info (uint) (response (tuple (current-oracle-price-sbtc uint) (total-bsd-loans uint) (total-sbtc-collateral uint) (total-collateral-in-bsd uint) (recovery-mode bool) (latest-vault-id uint) (is-paused bool) (is-maintenance bool)  (vault-threshold uint) (recovery-threshold uint) (global-collateral-cap uint) (protocol-fee-destination principal) (vault-loan-minimum uint) (vault-interest-minimum uint) (vault-interest-maximum uint) (oracle-stale-threshold uint)) uint))
    (new-vault (principal uint uint uint (optional uint)) (response bool uint))
    (mint-loan (uint uint uint) (response bool uint))
    (repay-loan (uint uint uint) (response bool uint))
    (add-collateral (uint uint uint) (response bool uint))
    (remove-collateral (uint uint uint) (response bool uint))
    (close-vault (uint) (response bool uint))
    (accrue-interest (uint) (response bool uint)) 
    (update-interest-rate (uint uint) (response bool uint))
    (update-epoch-rate (uint (optional uint)) (response bool uint))
    (update-redemptions ((list 65000 uint) uint uint uint uint uint uint) (response bool uint))
    (add-liquidity (uint principal) (response bool uint))
    (remove-liquidity (uint principal) (response bool uint))
    (liquidation-update-provider-distribution (uint uint uint bool) (response bool uint))
    (liquidation-update-vault-redistribution (uint uint uint bool) (response bool uint))
    (claim-rewards (principal) (response bool uint))
    (calculate-collateral-ratio (uint uint uint) (response uint uint))
    (update-delegate (uint principal) (response bool uint))
    (get-oracle-stale-threshold () (response uint uint))
    (unwind-vault (uint uint) (response bool uint))
    (unwind-provider (principal) (response bool uint))
  )
) 






```
