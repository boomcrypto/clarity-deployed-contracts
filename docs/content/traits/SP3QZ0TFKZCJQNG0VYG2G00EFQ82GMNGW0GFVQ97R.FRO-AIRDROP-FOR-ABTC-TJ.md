---
title: "Trait FRO-AIRDROP-FOR-ABTC-TJ"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3QZ0TFKZCJQNG0VYG2G00EFQ82GMNGW0GFVQ97R.frogdog-stxcity send-many (list {to: 'SP2SP2CBZ2GE9YB4N6FMRAZWN5QEZRVHEJHTQ8XC, amount: u100000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
