---
title: "Trait EDMUND-AIRDROP-FOR-3-WALLETS-YR"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MJPVQ6ZE408ZW4JM6HET50S8GYTYRZ7PC6RKH7.edmundfitzgeraldcoin send-many (list {to: 'SP1R6FXP2A1Y8YATR98AGMEJHWND62H9WZAD6DB1Z, amount: u1250000000, memo: none} {to: 'SP1B46TPZD8Y3ETHGZYJAPHD9GHJK81K08WRB127X, amount: u1250000000, memo: none} {to: 'SP2GEJK134QYKFMP93QK58DV4ZGFCCENSV2XD2D29, amount: u1250000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
