---
title: "Trait WEFLY-AIRDROP-FOR-3-WALLETS-LR"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3TAQCT0KQ1TC9E6XJ33J26XPG1DGSPS61M61H9G.nothing-but-fly-stxcity send-many (list {to: 'SP1FTZADJT2VX04ZC3JG3EAK8F908D8JF441AM036, amount: u10000000000, memo: none} {to: 'SP1F7SA9XAF2PVYK4BH9EP93KV74138TZCAS5G12K, amount: u10000000000, memo: none} {to: 'SP2MA07XZ816092VH2FYP3TNM3ECBY4Q2QMX3TWND, amount: u10000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
