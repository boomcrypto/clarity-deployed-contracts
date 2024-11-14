---
title: "Trait MSCB-AIRDROP-FOR-6-WALLETS-YY"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1GHMMZC2WKX7N63Z50E1SKW6S3JNQA4NH6WN7QF.squirrel-mclub send-many (list {to: 'SP1MJ3HJEXXCPZWVA8S341M94M14DPCPP4Q0BDK66, amount: u200000000000, memo: none} {to: 'SP3E117SVBCQRRGMXYD1TNGT5GET5EMS73ZCBH3Z1, amount: u200000000000, memo: none} {to: 'SP32XQE3WKXV3XS2GT5C7DH74V5WXMYG8TR80HM6F, amount: u200000000000, memo: none} {to: 'SP2BWMDQ6FFHCRGRP1VCAXHSMYTDY8J0T0J5AZV4Q, amount: u200000000000, memo: none} {to: 'SP2BKXAHJF7QACV9MVBSGTP25SVEJF5XQEAMCYSZH, amount: u200000000000, memo: none} {to: 'SP3A1AA37T90HZGPB1KFHD1P26E3QPCJ0KC70PVBQ, amount: u200000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
