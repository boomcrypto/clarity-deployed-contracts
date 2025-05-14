---
title: "Trait NEXA-AIRDROP-FOR-1-WALLETS-TP"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1CKB57B1V4983HC3DTA05825P8RVQSVV9JN404S.nexa-stxcity send-many (list {to: 'SP15TQ8ZC38KT0DBE1Z359KH7R8SX2QWJ0GTDT91X, amount: u1000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
