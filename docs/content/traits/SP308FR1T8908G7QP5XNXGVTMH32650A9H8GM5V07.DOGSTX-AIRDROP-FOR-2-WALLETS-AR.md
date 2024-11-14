---
title: "Trait DOGSTX-AIRDROP-FOR-2-WALLETS-AR"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP308FR1T8908G7QP5XNXGVTMH32650A9H8GM5V07.dog-go-to-the-moon-on-stx-stxcity send-many (list {to: 'SP218TBV9HWW8QQRARHQ6XK7G10271SQTTCCTHW20, amount: u1000000000000, memo: none} {to: 'SP2E5HWWPH7K9WD64RNJKQ7SR7D3DCZC3YFYCPBPD, amount: u1000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
