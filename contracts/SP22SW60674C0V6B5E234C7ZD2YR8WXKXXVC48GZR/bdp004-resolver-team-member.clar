(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme008-0-resolution-coordinator set-signals-required u1))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme024-0-market-predicting set-resolution-agent 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme008-0-resolution-coordinator))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme008-0-resolution-coordinator set-resolution-team-member 'SP3NS9010CQ9AK3M6XN3XD9EHNTDZVGYSMFWZ288Z true))
		(ok true)
	)
)