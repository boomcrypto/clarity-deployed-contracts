---
title: "Trait AMIGO-DONATE-FOR-1-WALLETS-HM"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3.amigo-stxcity transfer u50000000000 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3 'SPQX8KXY2N5Q75GWBS8F75ZV957RMD5KB7VJ7HW2 none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
