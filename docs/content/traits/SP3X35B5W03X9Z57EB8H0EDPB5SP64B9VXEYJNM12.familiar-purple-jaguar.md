---
title: "Trait familiar-purple-jaguar"
draft: true
---
```
(define-read-only (get-total-sBTC-balance)
	(contract-call? 
		'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
		get-balance
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-vault
	)
)

(define-read-only (get-user-sBTC-balance (address principal))
	(contract-call? 
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
		get-balance
		address
	)
)
```
