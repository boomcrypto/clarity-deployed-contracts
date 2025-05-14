---
title: "Trait AMIGO-DONATE-FOR-2-WALLETS-BP"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3.amigo-stxcity transfer u50000000000 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3 'SPGSDWYMSA6FTYPMV542D19FTZ73A7WPYXKF1QWE none)
(contract-call? 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3.amigo-stxcity transfer u50000000000 'SP3SE348DFBQT3PV6YT9B85014W0XAC5CT5Q50FB3 'SP3BX108WY579NDJTSGZMWJEQ12E2H5X7FD2P7BBJ none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
