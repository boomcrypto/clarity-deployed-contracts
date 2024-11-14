---
title: "Trait EDMUND-AIRDROP-FOR-1-WALLETS-HK"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MJPVQ6ZE408ZW4JM6HET50S8GYTYRZ7PC6RKH7.edmundfitzgeraldcoin send-many (list {to: 'SP1RJC76DDEGTXEA21MNVDAV40Y4HW845C9J46RJS, amount: u1250000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
