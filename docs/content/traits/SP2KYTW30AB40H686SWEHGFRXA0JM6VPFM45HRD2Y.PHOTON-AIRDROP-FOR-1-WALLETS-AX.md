---
title: "Trait PHOTON-AIRDROP-FOR-1-WALLETS-AX"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2KYTW30AB40H686SWEHGFRXA0JM6VPFM45HRD2Y.photon-stxcity send-many (list {to: 'SP38C4PCSDNSXD50PE28BM9NNTQ0J2CZ3D190M1XD, amount: u23085162000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
