(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-flash-loan-user 'SP2FJ75N8SNQY91W997VEPPCZX41GXBXR8B2QRTR9.flash-loan-wstx-to-wbtc))
		(ok true)	
	)
)
