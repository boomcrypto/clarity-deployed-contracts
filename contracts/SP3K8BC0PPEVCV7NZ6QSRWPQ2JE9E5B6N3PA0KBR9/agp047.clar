(impl-trait .proposal-trait.proposal-trait)

(define-constant start-block u57626)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .auto-alex set-start-block start-block))
		(try! (contract-call? .alex-vault add-approved-token .auto-alex))
		(ok true)	
	)
)
