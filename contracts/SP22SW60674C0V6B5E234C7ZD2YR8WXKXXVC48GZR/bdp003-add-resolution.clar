;; Title: Resolver

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .bme021-0-market-voting set-voting-duration u24))
		(try! (contract-call? .bme024-0-market-predicting set-dispute-window-length u24))
		(try! (contract-call? .bme024-0-market-predicting set-resolution-agent 'SP3NS9010CQ9AK3M6XN3XD9EHNTDZVGYSMFWZ288Z))
		(ok true)
	)
)
