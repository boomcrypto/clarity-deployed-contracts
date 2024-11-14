---
title: "Trait EDMUND-AIRDROP-FOR-9-WALLETS-HU"
draft: true
---
```

(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1MJPVQ6ZE408ZW4JM6HET50S8GYTYRZ7PC6RKH7.edmundfitzgeraldcoin send-many (list {to: 'SP1P2TRVPK2X5G2Q2DAZT59STM9NAHJS2RSEQGMKF, amount: u1250000000, memo: none} {to: 'SP1QABQ972DW13WFHARMKEZAKEVYQFX2YW882GV1E, amount: u1250000000, memo: none} {to: 'SP2KP65R907PSN4WEXR0VZY3R1EQJGTHKGDE5K6VG, amount: u1250000000, memo: none} {to: 'SP32F9APQW91AQH1Y18408DP3ACXNX1X0AYMEWHE9, amount: u1250000000, memo: none} {to: 'SP2NM3M5P4MS39ZMVG8JP0K7ZSY910PZV79MDQ179, amount: u1250000000, memo: none} {to: 'SPE00RR56SF6X17S8AVXEXEWVD41SZAMKXZYT591, amount: u1250000000, memo: none} {to: 'SP37F7QSMPEA645NH4ZMSHC3WVF9SVA0RZ03WYE37, amount: u1250000000, memo: none} {to: 'SP1P8QCWK05T41RCH6B6J8SNWVCAJBRJJDQ9ZJ95Z, amount: u1250000000, memo: none} {to: 'SP29EADBWFKWK76345DVY6TGCH8BN7N6SC96PB4K7, amount: u1250000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)

```
