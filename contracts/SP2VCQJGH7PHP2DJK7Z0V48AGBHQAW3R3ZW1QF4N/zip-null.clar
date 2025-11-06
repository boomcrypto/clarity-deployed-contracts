(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(print {
			contract-caller: contract-caller,
			tx-sender: tx-sender,
			sender:sender,
		})

		(print "Zest Governance Empty Proposal")

		(ok true)
	)
)
