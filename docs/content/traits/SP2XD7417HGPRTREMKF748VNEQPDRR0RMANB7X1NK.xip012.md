---
title: "Trait xip012"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin	
		(try! (contract-call? .mint-for-vault-v2-01 mint-for-vault .token-abtc u1101000000 u3 0x321f7d116f980fAc4415262E50f674eFFD5ff58D 0x0014c86e5a028fc0344d6b3fb44420d4f02e51ad22be))
		(try! (contract-call? .mint-for-vault-v2-01 mint-for-vault .token-abtc u2000000000 u3 0x321f7d116f980fAc4415262E50f674eFFD5ff58D 0x0014c86e5a028fc0344d6b3fb44420d4f02e51ad22be))
		(ok true)))
```
