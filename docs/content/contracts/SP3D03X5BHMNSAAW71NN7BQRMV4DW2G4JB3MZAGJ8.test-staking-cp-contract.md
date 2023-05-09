---
title: "Contract test-staking-cp-contract"
draft: true
---
Deployer: SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8


 



Block height: 104775 (2023-05-08T18:55:48.000Z)

Source code: {{<contractref "test-staking-cp-contract" SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8 test-staking-cp-contract>}}

Functions:

* append-helper-list-from-id-staked-to-height-difference _private_
* filter-out-collections-with-no-stakes _private_
* get-token-max-supply _private_
* is-not-id _private_
* is-not-removeable _private_
* is-not-removeable-collection _private_
* map-from-id-staked-to-height-difference _private_
* map-from-list-staked-to-generation-per-collection _private_
* map-to-append-to-list-of-height-differences _private_
* map-to-loop-through-active-collection _private_
* map-to-set-reset-last-claimed-or-staked-height _private_
* add-admin-address-for-whitelisting _public_
* admin-add-new-custodial-collection _public_
* admin-add-new-non-custodial-collection _public_
* admin-emergency-unstake _public_
* admin-remove-custodial-collection _public_
* admin-remove-non-custodial-collection _public_
* claim-all-stake _public_
* claim-item-stake _public_
* get-unclaimed-balance _public_
* get-unclaimed-balance-by-collection _public_
* remove-admin-address-for-whitelisting _public_
* stake _public_
* unstake-item _public_
* active-admins _read_only_
* active-collections _read_only_
* custodial-active-collections _read_only_
* get-generation-rate-of-a-collection _read_only_
* get-item-stake-details _read_only_
* get-items-staked-by-collection-and-user _read_only_
* get-total-generation-rate-through-all-collections _read_only_
* get-unclaimed-balance-by-collection-and-item _read_only_
* get-unclaimed-balance-by-collection-and-items _read_only_
* non-custodial-active-collections _read_only_
