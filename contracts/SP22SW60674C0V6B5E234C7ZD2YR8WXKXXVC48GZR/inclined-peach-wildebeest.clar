(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme008-0-resolution-coordinator set-signals-required u1))
		(ok true)
	)
)