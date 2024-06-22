(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
(claim-details (contract-call? .claim-recovered get-claim-or-default 'SPFP4YRN8XZCZ34YKB9NJT5NCZCE5ST5AVGJMH7B))
(transfer-wvibes (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvibes transfer-fixed (get amt-token-wvibes claim-details) 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao .executor-dao none))))
(ok true)))