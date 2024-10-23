(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin	
		(try! (contract-call? .token-susdt mint-fixed u170040884100 'SP189S0AFM4P1WQ1RQJH5F2N7PSP708RESADM1WJ9))
		(ok true)))