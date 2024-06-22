(impl-trait .proposal-trait.proposal-trait)
(define-constant recipients (list
	{ amount: u1279876745267647, recipient: 'SPND4GDCJEJ68R5T4QCG2ZVGHD3YDB1JPJEERYT4 } ;; Bitget
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many recipients))
		(ok true)))