---
title: "Trait boot"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .operators, enabled: true }
		)))
		
		;; Set initial operators
		(try! (contract-call? .operators set-operators (list
			{ operator: 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC, enabled: true }
			{ operator: 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ, enabled: true }
			{ operator: 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84, enabled: true }
			{ operator: 'SP414JA5BZ7QBWET7QEC8Y18KQFKRVXCST5JZZ24, enabled: true }
			{ operator: 'SP1YMSMZQ8XSNKWHEXPWJ03T18E6ZTFJD3SH40FBZ, enabled: true }
		)))
		;; Set operator signal threshold, i.e. 3-of-5
		(try! (contract-call? .operators set-proposal-threshold 3))
		(ok true)
	)
)
```
