---
title: "Contract cp-staking-1"
draft: true
---
Deployer: SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8


 



Block height: 102822 (2023-04-20T19:56:04.000Z)

Source code: {{<contractref "cp-staking-1" SP3D03X5BHMNSAAW71NN7BQRMV4DW2G4JB3MZAGJ8 cp-staking-1>}}

Functions:

* append-helper-list-from-id-staked-to-height-difference _private_
* filter-out-collections-with-no-stakes _private_
* get-token-max-supply _private_
* is-not-id _private_
* is-not-removeable _private_
* map-from-id-staked-to-height-difference _private_
* map-from-list-staked-to-generation-per-collection _private_
* map-to-append-to-list-of-height-differences _private_
* map-to-loop-through-active-collection _private_
* map-to-reset-all-ids-staked-by-user-in-this-collection _private_
* map-to-set-reset-last-claimed-or-staked-height _private_
* add-admin-address-for-whitelisting _public_
* admin-add-new-custodial-collection _public_
* admin-add-new-non-custodial-collection _public_
* admin-emergency-unstake _public_
* claim-all-stake _public_
* claim-collection-stake _public_
* claim-item-stake _public_
* get-unclaimed-balance _public_
* get-unclaimed-balance-by-collection _public_
* remove-admin-address-for-whitelisting _public_
* stake _public_
* unstake-item _public_
* active-collections _read_only_
* custodial-active-collections _read_only_
* get-balance-by-collection-and-item _read_only_
* get-balance-by-collection-and-items _read_only_
* get-generation-by-collection _read_only_
* get-stake-details _read_only_
* get-staked-by-collection-and-user _read_only_
* get-total-generation _read_only_
* non-custodial-active-collections _read_only_
