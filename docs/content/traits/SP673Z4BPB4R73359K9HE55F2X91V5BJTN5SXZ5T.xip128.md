---
title: "Trait xip128"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
			{ extension: .btc-peg-in-v2-07d-agg, enabled: false }
			{ extension: .btc-peg-in-v2-07e-agg, enabled: true }
			
		)))
		(try! (contract-call? .btc-peg-in-v2-07d-agg pause-peg-in true))
		(try! (contract-call? .btc-peg-in-v2-07e-agg pause-peg-in false))
		(ok true)
	)
)

```
