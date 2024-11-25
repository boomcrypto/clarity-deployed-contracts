---
title: "Trait pontis-migration-helper"
draft: true
---
```
(use-trait bridge-config-trait-v1 .bridge-config-trait-v1.bridge-config-trait-v1)


(define-public (migrate-new-signer-set
	(bridge-contract <bridge-config-trait-v1>)
	(peg-out-key-utxo (list 1000 uint))
	(new-multisig-owner principal)
	(stx-amount-to-migrate uint)
)
	(begin
		(try! (contract-call? bridge-contract remove-peg-out-key-utxo peg-out-key-utxo))
		(try! (contract-call? .pontis-bridge-controller migrate-owner new-multisig-owner))
		(stx-transfer? stx-amount-to-migrate tx-sender new-multisig-owner)
	)
)


```
