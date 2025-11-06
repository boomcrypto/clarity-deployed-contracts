;; Title: End BigMarket Dry Run
;; Author(s): mijoco.btc
;; Synopsis: Switch off market creation and BIG token rewards
;; Description: Finalises the dry run period by switching off the ability to create new markets and BIG token rewards

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme030-0-reputation-token set-reward-per-epoch u0))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme022-0-market-gating set-merkle-root-by-principal 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme024-0-market-predicting  0xfba1ea342f9221b03ede814f4944f8ed3b2b9d9ff7e9371333ae41e652776164))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme022-0-market-gating set-merkle-root-by-principal 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme024-0-market-scalar-pyth 0xfba1ea342f9221b03ede814f4944f8ed3b2b9d9ff7e9371333ae41e652776164))
		(ok true)
	)
)