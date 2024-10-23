(impl-trait .proposal-trait.proposal-trait)
(define-constant recipients (list
	{ amount: u278718100000000, recipient: 'SP1SP2QKB7N8T9XJZB88206HJ53FB98MNR6MTMSN3 }
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many recipients))
		(ok true)))