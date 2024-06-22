(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .migrate-legacy, enabled: true }
		)))
		(ok true)
	)
)