---
title: "Trait bridge-trait-v1"
draft: true
---
```
(use-trait bridge-ft-trait .bridge-ft-trait.bridge-ft-trait)
(use-trait bridge-nft-trait .bridge-nft-trait.bridge-nft-trait)

(define-trait bridge-trait-v1
	(
		(mint-runes-batch ((list 100 <bridge-ft-trait>) (list 100 uint) (list 100 principal) (list 100 (buff 36))) (response bool uint))
		(mint-btc (<bridge-ft-trait> uint principal (buff 36)) (response bool uint))
		(mint-ordinals-batch (<bridge-nft-trait> (list 1000 uint) (list 1000 principal) (list 1000 (buff 36))) (response bool uint))
		
		(mint-runes-batch-from-btc ((list 100 <bridge-ft-trait>) (list 100 uint) (list 100 principal) (list 100 (buff 36)) bool (buff 32) uint) (response bool uint))
		(mint-btc-from-btc (<bridge-ft-trait> uint principal (buff 36) bool (buff 32) uint) (response bool uint))
		(mint-ordinals-batch-from-btc (<bridge-nft-trait> (list 1000 uint) (list 1000 principal) (list 1000 (buff 36)) bool (buff 32) uint) (response bool uint))

		(peg-out-ordinals-batch (<bridge-nft-trait> (list 1000 uint) (list 1000 (buff 64))) (response bool uint))
		(bridge-out-btc (<bridge-ft-trait> uint (buff 64) (buff 12)) (response bool uint))
		(bridge-out-runes ((buff 26) <bridge-ft-trait> uint (buff 64) (buff 12)) (response bool uint))
	)
)
```
