---
title: "Contract degenlab-stacking-pool"
draft: true
---
Deployer: SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ


 



Block height: 137647 (2024-01-30T23:30:43.000Z)

Source code: {{<contractref "degenlab-stacking-pool" SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ degenlab-stacking-pool>}}

Functions:

* batch-reward-distribution-one-block _private_
* calculate-all-stackers-weights _private_
* calculate-one-stacker-weight _private_
* check-and-delegate-stack-stx _private_
* check-can-decrement-delegated-balance _private_
* check-can-decrement-locked-balance _private_
* check-can-decrement-owned-balance _private_
* check-can-decrement-reserved-balance _private_
* check-can-decrement-total-balance _private_
* check-is-liquidity-provider _private_
* check-is-stacker _private_
* check-won-block-rewards _private_
* check-won-block-rewards-one-block _private_
* decrement-sc-delegated-balance _private_
* decrement-sc-locked-balance _private_
* decrement-sc-owned-balance _private_
* decrement-sc-reserved-balance _private_
* delegate-stack-extend-increase _private_
* delegate-stx-inner _private_
* div-down _private_
* get-next-reward-cycle _private_
* increment-sc-delegated-balance _private_
* increment-sc-locked-balance _private_
* is-prepare-phase _private_
* lock-delegated-stx _private_
* maybe-stack-aggregation-commit _private_
* min _private_
* minus-percent _private_
* mul-down _private_
* preview-exchange-reward _private_
* register-block-reward _private_
* remove-stacker-stackers-list _private_
* to-one-8 _private_
* transfer-reward-one-stacker _private_
* transfer-rewards-all-stackers _private_
* weight-calculator _private_
* allow-contract-caller _public_
* batch-reward-distribution _public_
* delegate-stack-stx _public_
* delegate-stack-stx-many _public_
* delegate-stx _public_
* deposit-stx-liquidity-provider _public_
* disallow-contract-caller _public_
* join-stacking-pool _public_
* multiple-blocks-check-won-rewards _public_
* quit-stacking-pool _public_
* reserve-funds-future-rewards _public_
* reward-distribution _public_
* set-active _public_
* set-pool-pox-address _public_
* swap-preview _public_
* unlock-extra-reserved-funds _public_
* update-return _public_
* update-sc-balances _public_
* update-sc-balances-one-stacker _public_
* withdraw-stx-liquidity-provider _public_
* already-rewarded-burn-block _read_only_
* calculate-extra-reserved-funds _read_only_
* can-lock-now _read_only_
* can-withdraw-extra-reserved-now _read_only_
* check-caller-allowed _read_only_
* check-pool-SC-pox-allowance _read_only_
* check-won-block-rewards-batch _read_only_
* get-SC-locked-balance _read_only_
* get-SC-owned-balance _read_only_
* get-SC-reserved-balance _read_only_
* get-SC-total-balance _read_only_
* get-address-status _read_only_
* get-amount-rewarded _read_only_
* get-block-rewards _read_only_
* get-blocks-rewarded _read_only_
* get-check-delegation _read_only_
* get-delegated-amount _read_only_
* get-liquidity-provider _read_only_
* get-minimum-deposit-liquidity-provider _read_only_
* get-pool-members _read_only_
* get-pox-addr-indices _read_only_
* get-prepare-phase-length _read_only_
* get-return _read_only_
* get-reward-phase-length _read_only_
* get-stacker-weight _read_only_
* get-stx-account _read_only_
* get-user-data _read_only_
* has-won-burn-block _read_only_
* is-in-pool _read_only_
* updated-balances-given-cycle _read_only_
* was-block-claimed _read_only_
