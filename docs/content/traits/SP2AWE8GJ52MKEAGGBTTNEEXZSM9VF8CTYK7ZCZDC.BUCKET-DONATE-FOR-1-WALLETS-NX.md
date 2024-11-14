---
title: "Trait BUCKET-DONATE-FOR-1-WALLETS-NX"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2AWE8GJ52MKEAGGBTTNEEXZSM9VF8CTYK7ZCZDC.bucket-coin-stxcity transfer u635000000000 'SP2AWE8GJ52MKEAGGBTTNEEXZSM9VF8CTYK7ZCZDC 'SP3JP35HCKEZAXQCXFFC0JCM3VVHCXQEWBM4H6E1X none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
