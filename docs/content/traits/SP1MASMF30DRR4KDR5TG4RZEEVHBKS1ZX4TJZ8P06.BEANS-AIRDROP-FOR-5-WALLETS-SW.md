---
title: "Trait BEANS-AIRDROP-FOR-5-WALLETS-SW"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MASMF30DRR4KDR5TG4RZEEVHBKS1ZX4TJZ8P06.mrbeans-stxcity send-many (list {to: 'SP2T2YCP677B907YQC1PGJ4F5K5MTRT2QB073Z8GQ, amount: u398000000, memo: none} {to: 'SP3C730EGZBZYVEE03D4K2PRKVVAPQDVB49RFVVMZ, amount: u398000000, memo: none} {to: 'SP1HN3S4PW69JRWRM3GR8YBYMKHPM2TWBN7ZADHWB, amount: u398000000, memo: none} {to: 'SP39R72YMPZ96DGY9XSCE5DDASXEQBJYYDDZ416WM, amount: u398000000, memo: none} {to: 'SP1WCJ02AAPKMXPK81KFKGJ7MJDET11FPQG1RHB0S, amount: u398000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
