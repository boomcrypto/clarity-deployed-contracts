---
title: "Trait NEXA-AIRDROP-FOR-1-WALLETS-RA"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1CKB57B1V4983HC3DTA05825P8RVQSVV9JN404S.nexa-stxcity send-many (list {to: 'SP1CXHVGJW5Z2B64CDA4VCXT122BXXGX0WJ7GXD8H, amount: u6000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
