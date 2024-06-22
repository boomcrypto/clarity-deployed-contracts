(impl-trait .proposal-trait.proposal-trait)
(define-constant batch-74 (list 
{ amount: u17300000000000000, recipient: 'SP19ATGT7WJV5J0XGC2Y05QQBV9AFSN24V7F2SEWR }
{ amount: u7156133700000000, recipient: 'SP3EHJV1VNQ9YMV5PTTP93G6C7WRPN8FCGEK3Y7RJ }	
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-special-vote edg-mint-many batch-74))
		(ok true)
	)
)