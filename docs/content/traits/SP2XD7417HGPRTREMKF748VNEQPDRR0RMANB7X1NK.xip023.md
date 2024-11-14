---
title: "Trait xip023"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .btc-peg-in-endpoint-v2-02, enabled: true }
			{ extension: .btc-peg-in-endpoint-v2-01, enabled: false }
		)))
		(try! (contract-call? .btc-peg-in-endpoint-v2-02 pause-peg-in false))
		(try! (contract-call? .btc-peg-in-endpoint-v2-01 pause-peg-in true))
		(ok true)
	)
)
```
