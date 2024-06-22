(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .migrate-legacy-v2 migrate))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-legacy migrate))		
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao set-extension .executor-dao true))
		(ok true)
	)
)