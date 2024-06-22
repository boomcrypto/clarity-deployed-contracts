---
title: "Trait agp219"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .migrate-legacy, enabled: false }
			{ extension: .migrate-legacy-v2, enabled: true }
		)))
		(try! (contract-call? .migrate-legacy-v2 set-threshold (* u10000 ONE_8)))
		(ok true)
	)
)
```
