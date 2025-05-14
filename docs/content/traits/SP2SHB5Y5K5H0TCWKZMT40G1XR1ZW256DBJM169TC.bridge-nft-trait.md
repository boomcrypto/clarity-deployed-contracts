---
title: "Trait bridge-nft-trait"
draft: true
---
```
(define-trait bridge-nft-trait
	(
		(get-last-token-id () (response uint uint))
		(get-token-uri (uint) (response (optional (string-ascii 256)) uint))
		(get-owner (uint) (response (optional principal) uint))
		(transfer (uint principal principal) (response bool uint))

		(mint (uint principal) (response bool uint))
		(burn (uint principal) (response bool uint))
	)
)
```
