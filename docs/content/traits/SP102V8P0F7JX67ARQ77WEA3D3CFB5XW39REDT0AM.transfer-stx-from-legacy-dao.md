---
title: "Trait transfer-stx-from-legacy-dao"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-wstx-v2 transfer-fixed u15048799190300 tx-sender .treasury-grant none))
		(ok true)))
```
