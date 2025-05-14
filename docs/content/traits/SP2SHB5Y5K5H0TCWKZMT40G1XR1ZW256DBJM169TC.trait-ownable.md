---
title: "Trait trait-ownable"
draft: true
---
```
(define-trait ownable-trait
	(
		(get-contract-owner () (response principal uint))
		(propose-contract-owner (principal) (response bool uint))
		(claim-ownership () (response bool uint))
	)
)
```
