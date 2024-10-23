(impl-trait .proposal-trait.proposal-trait)
(define-constant recipient 'SP2EFH89NZXBMF4B3508VKT2521P8NT40C6G5Z6SC)
(define-constant amount u160745246331109)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many (list { recipient: recipient, amount: amount })))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-fixed amount recipient))
		(ok true)))