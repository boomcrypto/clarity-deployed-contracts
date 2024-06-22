---
title: "Trait trait-ownable"
draft: true
---
```
(define-trait ownable-trait
	(
		(get-contract-owner () (response principal uint))
		(set-contract-owner (principal) (response bool uint))
	)
)

```
