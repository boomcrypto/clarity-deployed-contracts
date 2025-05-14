---
title: "Trait BEANS-AIRDROP-FOR-4-WALLETS-KK"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MASMF30DRR4KDR5TG4RZEEVHBKS1ZX4TJZ8P06.mrbeans-stxcity send-many (list {to: 'SPCEMCY55HV62G79730B8B6HZSD90337NFQHBR4J, amount: u2200000000, memo: none} {to: 'SP3DGHSW42HV4T5XR999R3MBV02W6KA50W1D85TSV, amount: u2200000000, memo: none} {to: 'SPKSXKVMKQ2E70VEQZE45NJJ36RNW4MDQ4YX6K56, amount: u2200000000, memo: none} {to: 'SP3DGHSW42HV4T5XR999R3MBV02W6KA50W1D85TSV, amount: u2200000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
