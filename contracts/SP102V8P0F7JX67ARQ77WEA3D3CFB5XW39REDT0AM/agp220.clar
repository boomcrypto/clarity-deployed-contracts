(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .migrate-legacy-v2 finalise-migrate 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer-fixed (* u30000000 ONE_8) tx-sender 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao none))
		(try! (contract-call? .migrate-legacy-v2 migrate))
		(try! (contract-call? .migrate-legacy-v2 finalise-migrate tx-sender))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-legacy migrate))
		(ok true)
	)
)