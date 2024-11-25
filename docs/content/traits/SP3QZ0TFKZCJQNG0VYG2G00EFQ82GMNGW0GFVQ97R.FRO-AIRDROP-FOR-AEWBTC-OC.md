---
title: "Trait FRO-AIRDROP-FOR-AEWBTC-OC"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3QZ0TFKZCJQNG0VYG2G00EFQ82GMNGW0GFVQ97R.frogdog-stxcity send-many (list {to: 'SP3ZGSS9CGA2FBYWYFFHYYTAP6CTFBT6YQAZPK1ZE, amount: u100000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
