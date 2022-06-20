---
title: "Contract collateral-rebalancing-pool"
draft: true
---
Deployer: SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9


 



Block height: 64576 (2022-06-19T17:03:28.000Z)

Source code: {{<contractref "collateral-rebalancing-pool" SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9 collateral-rebalancing-pool>}}

Functions:

* accumulate_division _private_
* accumulate_product _private_
* add-to-position-with-spot _private_
* check-is-approved _private_
* check-is-owner _private_
* check-is-self _private_
* create-and-configure-pool-with-spot _private_
* div-down _private_
* div-up _private_
* erf _private_
* exp-fixed _private_
* exp-pos _private_
* fwp-oracle-instant _private_
* fwp-oracle-instant-internal _private_
* fwp-oracle-resilient _private_
* fwp-oracle-resilient-internal _private_
* get-ltv-with-spot _private_
* get-pool-value-in-collateral-with-spot _private_
* get-pool-value-in-token-with-spot _private_
* get-position-given-burn-internal _private_
* get-position-given-burn-key-with-spot _private_
* get-position-given-mint-internal _private_
* get-position-given-mint-with-spot _private_
* get-token-given-position-internal _private_
* get-token-given-position-with-spot _private_
* get-weight-x-with-spot _private_
* get-x-given-price-internal _private_
* get-x-given-y-internal _private_
* get-x-in-given-y-out-internal _private_
* get-y-given-price-internal _private_
* get-y-given-x-internal _private_
* get-y-in-given-x-out-internal _private_
* is-fixed-weight-pool-v1-01 _private_
* is-from-fixed-to-simple-alex _private_
* is-from-simple-alex-to-fixed _private_
* is-simple-weight-pool-alex _private_
* ln-fixed _private_
* ln-priv _private_
* log-fixed _private_
* mint-auto-internal _private_
* mul-down _private_
* mul-up _private_
* pow-down _private_
* pow-fixed _private_
* pow-priv _private_
* pow-up _private_
* redeem-auto-internal _private_
* rolling_div_sum _private_
* rolling_sum_div _private_
* simple-oracle-instant _private_
* simple-oracle-instant-internal _private_
* simple-oracle-resilient _private_
* simple-oracle-resilient-internal _private_
* add-to-position _public_
* add-to-position-and-switch _public_
* add-to-yield-token-pool-and-mint-auto _public_
* buy-to-key-token-and-mint-auto _public_
* buy-to-yield-token-pool-and-mint-auto _public_
* create-and-configure-pool _public_
* create-margin-position _public_
* create-pool _public_
* mint-auto _public_
* redeem-auto _public_
* redeem-auto-and-reduce-from-yield-token-pool _public_
* reduce-position-key _public_
* reduce-position-key-many _public_
* reduce-position-yield _public_
* reduce-position-yield-many _public_
* roll-auto _public_
* roll-auto-key _public_
* roll-auto-pool _public_
* roll-auto-yield _public_
* roll-borrow _public_
* roll-borrow-many _public_
* roll-deposit _public_
* roll-deposit-many _public_
* set-approved-contract _public_
* set-approved-pair _public_
* set-bounty-in-fixed _public_
* set-capacity-multiplier _public_
* set-contract-owner _public_
* set-expiry-cycle-length _public_
* set-fee-rate-x _public_
* set-fee-rate-y _public_
* set-fee-rebate _public_
* set-fee-to-address _public_
* set-max-in-ratio _public_
* set-max-out-ratio _public_
* set-shortfall-coverage _public_
* set-strike-multiplier _public_
* swap-helper _public_
* swap-x-for-y _public_
* swap-y-for-x _public_
* get-activation-block-or-default _read_only_
* get-approved-pair _read_only_
* get-auto-total-supply-or-default _read_only_
* get-bounty-in-fixed-or-default _read_only_
* get-capacity-multiplier _read_only_
* get-contract-owner _read_only_
* get-expiry _read_only_
* get-expiry-cycle _read_only_
* get-expiry-cycle-length _read_only_
* get-fee-rate-x _read_only_
* get-fee-rate-y _read_only_
* get-fee-rebate _read_only_
* get-fee-to-address _read_only_
* get-first-stacks-block-in-expiry-cycle _read_only_
* get-given-helper _read_only_
* get-helper _read_only_
* get-invariant _read_only_
* get-last-expiry _read_only_
* get-ltv _read_only_
* get-max-in-ratio _read_only_
* get-max-out-ratio _read_only_
* get-pool-details _read_only_
* get-pool-total-supply-or-default _read_only_
* get-pool-value-in-collateral _read_only_
* get-pool-value-in-token _read_only_
* get-position-given-burn-key _read_only_
* get-position-given-mint _read_only_
* get-shortfall-coverage _read_only_
* get-spot _read_only_
* get-strike-multiplier _read_only_
* get-token-given-position _read_only_
* get-weight-x _read_only_
* get-x-given-price _read_only_
* get-x-given-y _read_only_
* get-y-given-price _read_only_
* get-y-given-x _read_only_
* oracle-instant-helper _read_only_
* oracle-resilient-helper _read_only_
