---
title: "Contract cp-staking"
draft: true
---
Deployer: SP245BWGP81RRK328109J2MY98GBJCYZ8DHDBBGA9


 



Block height: 111669 (2023-07-03T17:09:40.000Z)

Source code: {{<contractref "cp-staking" SP245BWGP81RRK328109J2MY98GBJCYZ8DHDBBGA9 cp-staking>}}

Functions:

* append-helper-list-from-id-staked-to-height-difference _private_
* filter-out-collections-with-no-stakes _private_
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
* change-collection-multiplier _public_
* claim-all-stake _public_
* claim-item-stake _public_
* get-unclaimed-balance _public_
* get-unclaimed-balance-by-collection _public_
* remove-admin-address-for-whitelisting _public_
* stake _public_
* stake-many _public_
* unstake-item _public_
* unstake-many _public_
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
