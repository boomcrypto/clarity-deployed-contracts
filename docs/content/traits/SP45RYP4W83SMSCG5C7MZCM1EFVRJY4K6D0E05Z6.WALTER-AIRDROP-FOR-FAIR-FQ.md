---
title: "Trait WALTER-AIRDROP-FOR-FAIR-FQ"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP45RYP4W83SMSCG5C7MZCM1EFVRJY4K6D0E05Z6.walter send-many (list {to: 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R, amount: u1000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
