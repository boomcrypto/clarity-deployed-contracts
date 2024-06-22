---
title: "Trait xip010"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .cross-peg-in-endpoint-v2-01, enabled: false }
            { extension: .cross-peg-in-endpoint-v2-02, enabled: true })))
        (try! (contract-call? .cross-peg-in-endpoint-v2-01 set-paused true))
        (try! (contract-call? .cross-peg-in-endpoint-v2-02 set-paused false))
    (ok true)))
```
