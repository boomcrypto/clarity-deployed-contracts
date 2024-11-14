---
title: "Trait bridge-config-trait-v1"
draft: true
---
```
(define-trait bridge-config-trait-v1
	(
		(set-rune-token-by-id ((buff 26) principal bool) (response bool uint))
		(set-btc-token (principal) (response bool uint))
		(set-btc-paused (bool) (response bool uint))
		(set-rune-token-active ((buff 26) bool) (response bool uint))
		(remove-peg-out-key-utxo ((list 1000 uint)) (response bool uint))
		(add-peg-out-key-utxo ((list 1000 (buff 36))) (response bool uint))
		(set-ordinals-contract-active (principal bool) (response bool uint))
	)
)

```
