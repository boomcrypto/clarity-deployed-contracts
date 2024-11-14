---
title: "Trait transfer-from-legacy-stxoshi"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
			(amount (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-STXOSHI-RNTJY get-balance-fixed tx-sender))))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-STXOSHI-RNTJY transfer-fixed amount tx-sender .executor-dao none))
		(ok true)))
```
