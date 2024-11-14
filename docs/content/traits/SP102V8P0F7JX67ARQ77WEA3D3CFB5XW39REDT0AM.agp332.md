---
title: "Trait agp332"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .amm-vault-v2-01 set-approved-token .token-waewbtc true))
(try! (contract-call? .amm-vault-v2-01 set-approved-token .token-waeusdc true))
(ok true)))
```
