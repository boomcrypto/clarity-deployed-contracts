---
title: "Trait xip099"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2, chain-id: u1 } { approved: true, burnable: false, fee: u250000, min-fee: u400000000, min-amount: u400000000, max-amount: u100000000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2, chain-id: u1 } MAX_UINT))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.operators set-operators (list
	{ operator: 'SP1ZSS4BHNV0K3A1T11VEWCB8D201YERK06NE77ZZ, enabled: false }
	{ operator: 'SP1882WWVWQK96NQB97SXMMRMB34W6M4RWDBWZW5B, enabled: true }
)))

(ok true)))

```
