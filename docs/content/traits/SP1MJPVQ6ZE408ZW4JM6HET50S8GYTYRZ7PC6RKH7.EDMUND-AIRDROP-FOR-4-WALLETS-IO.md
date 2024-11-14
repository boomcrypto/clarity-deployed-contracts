---
title: "Trait EDMUND-AIRDROP-FOR-4-WALLETS-IO"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MJPVQ6ZE408ZW4JM6HET50S8GYTYRZ7PC6RKH7.edmundfitzgeraldcoin send-many (list {to: 'SP1WCJ02AAPKMXPK81KFKGJ7MJDET11FPQG1RHB0S, amount: u1250000000, memo: none} {to: 'SP2BKE5W2F9S0PGDHC5KW5TCP48JQAQH0A3T1238B, amount: u1250000000, memo: none} {to: 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75, amount: u1250000000, memo: none} {to: 'SPMF5MT7BFT4V3YV6V5DG2AJJK7ST273WN4ZG8SB, amount: u1250000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
