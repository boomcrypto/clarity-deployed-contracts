---
title: "Trait xip015"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin	
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .meta-bridge-endpoint-v2-01, enabled: true }
		)))
		(ok true)))
```
