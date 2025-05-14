---
title: "Trait tiger-lion-puma-0"
draft: true
---
```

(define-constant ERR_USER_BALANCE (err u801))

(define-read-only (get-total-sBTC-balance)
	(contract-call? 
		'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
		get-balance
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-vault
	)
)

(define-read-only (get-user-total-sBTC-balance (address principal))
	(contract-call?
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
		get-balance
		address
	)
)

(define-public (print-user-total-sBTC-balance (address principal))
	(contract-call?
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
		get-balance
		address
	)
)

```
