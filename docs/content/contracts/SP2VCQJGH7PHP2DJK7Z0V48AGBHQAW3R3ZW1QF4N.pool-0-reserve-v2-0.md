---
title: "Contract pool-0-reserve-v2-0"
draft: true
---
Deployer: SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N


 



Block height: 343142 (2024-12-17T00:43:12.000Z)

Source code: {{<contractref "pool-0-reserve-v2-0" SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N pool-0-reserve-v2-0>}}

Functions:

* accrue-to-treasury _private_
* add-borrowed-asset _private_
* add-supplied-asset _private_
* aggregate-debt _private_
* aggregate-user-data _private_
* cumulate-to-liquidity-index _private_
* get-user-asset-data _private_
* get-user-basic-reserve-data _private_
* remove-borrowed-asset _private_
* remove-supplied-asset _private_
* reset-data-on-zero-balance-internal _private_
* set-reserve-internal _private_
* set-user-index-internal _private_
* set-user-reserve-as-collateral-internal _private_
* update-cumulative-indexes _private_
* update-principal-reserve-state-on-liquidation _private_
* update-reserve-interest-rates-and-timestamp _private_
* update-reserve-state-on-repay _private_
* update-user-state-on-borrow _private_
* update-user-state-on-liquidation _private_
* update-user-state-on-repay _private_
* add-asset _public_
* add-supplied-asset-ztoken _public_
* calculate-user-global-data _public_
* check-balance-decrease-allowed _public_
* confirm-admin-transfer _public_
* confirm-configurator-transfer _public_
* get-reserve-available-liquidity _public_
* get-user-balance-reserve-data _public_
* mint-to-treasury _public_
* remove-asset _public_
* remove-isolated-asset _public_
* remove-supplied-asset-ztoken _public_
* reset-user-index _public_
* set-admin _public_
* set-approved-contract _public_
* set-borroweable-isolated _public_
* set-configurator _public_
* set-flashloan-fee-protocol _public_
* set-flashloan-fee-total _public_
* set-health-factor-liquidation-treshold _public_
* set-isolated-asset _public_
* set-lending-pool _public_
* set-liquidator _public_
* set-reserve _public_
* set-user-assets _public_
* set-user-index _public_
* set-user-reserve _public_
* set-user-reserve-as-collateral _public_
* set-user-reserve-data _public_
* sum-total-debt-in-base-currency _public_
* transfer-fee-to-collection _public_
* transfer-to-reserve _public_
* transfer-to-user _public_
* update-reserve-state-on-borrow _public_
* update-reserve-total-borrows-by-rate-mode _public_
* update-state-on-borrow _public_
* update-state-on-deposit _public_
* update-state-on-flash-loan _public_
* update-state-on-liquidation _public_
* update-state-on-redeem _public_
* update-state-on-repay _public_
* asset-is-of-e-mode-type _read_only_
* calculate-collateral-needed-in-USD _read_only_
* calculate-compounded-interest _read_only_
* calculate-cumulated-balance _read_only_
* calculate-health-factor-from-balances _read_only_
* calculate-interest-rates _read_only_
* calculate-linear-interest _read_only_
* can-enable-e-mode _read_only_
* count-collateral-enabled _read_only_
* div _read_only_
* div-precision-to-fixed _read_only_
* div-to-fixed-precision _read_only_
* e-mode-allows-borrowing _read_only_
* e-mode-type-enabled _read_only_
* filter-asset _read_only_
* from-fixed-to-precision _read_only_
* get-asset-e-mode-type _read_only_
* get-assets _read_only_
* get-assets-used-as-collateral _read_only_
* get-assets-used-by _read_only_
* get-base-supply-rate _read_only_
* get-base-variable-borrow-rate _read_only_
* get-borroweable-isolated _read_only_
* get-collection-address _read_only_
* get-compounded-borrow-balance _read_only_
* get-e-mode-config _read_only_
* get-e-mode-type-config _read_only_
* get-flashloan-fee-protocol _read_only_
* get-flashloan-fee-total _read_only_
* get-health-factor-liquidation-threshold _read_only_
* get-isolated-asset _read_only_
* get-normalized-income _read_only_
* get-optimal-utilization-rate _read_only_
* get-origination-fee-prc _read_only_
* get-reserve-factor _read_only_
* get-reserve-state _read_only_
* get-reserve-state-optional _read_only_
* get-reserve-vault _read_only_
* get-rt-by-block _read_only_
* get-seconds-in-year _read_only_
* get-user-assets _read_only_
* get-user-borrow-balance _read_only_
* get-user-e-mode _read_only_
* get-user-index _read_only_
* get-user-origination-fee _read_only_
* get-user-reserve-data _read_only_
* get-variable-rate-slope-1 _read_only_
* get-variable-rate-slope-2 _read_only_
* is-admin _read_only_
* is-approved-contract _read_only_
* is-borroweable-isolated _read_only_
* is-borrowing-assets _read_only_
* is-configurator _read_only_
* is-even _read_only_
* is-in-e-mode _read_only_
* is-in-isolation-mode _read_only_
* is-isolated-type _read_only_
* is-lending-pool _read_only_
* is-liquidator _read_only_
* is-odd _read_only_
* mul _read_only_
* mul-precision-with-factor _read_only_
* mul-to-fixed-precision _read_only_
* split-isolated _read_only_
* taylor-6 _read_only_
