---
title: "Trait agp200"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
			(atalex-amount (unwrap-panic (contract-call? .auto-alex-v2 get-balance-fixed .alex-vault-v1-1)))
			(lunr-amount (unwrap-panic (contract-call? .token-slunr get-balance-fixed .alex-vault-v1-1)))
			(sko-amount (unwrap-panic (contract-call? .token-ssko get-balance-fixed .alex-vault-v1-1)))
	)
		(try! (contract-call? .auto-alex-v2 burn-fixed atalex-amount .alex-vault-v1-1))        
        (try! (contract-call? .token-slunr burn-fixed lunr-amount .alex-vault-v1-1))
        (try! (contract-call? .token-ssko burn-fixed sko-amount .alex-vault-v1-1))
		(ok true)	
	)
)
```
