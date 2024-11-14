---
title: "Trait KNFE-AIRDROP-FOR-GIGA-PEPE-V2-RY"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3MTMK7R8GQKYHN3XZGBFS81NSDD1YAZW305H2CS.dogwifknife send-many (list {to: 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R, amount: u100088000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
