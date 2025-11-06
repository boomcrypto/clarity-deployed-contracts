;; Title: Dispute and Voting Windows
;; Author(s): mijoco.btc
;; Synopsis: Aligns dispute and voting windows
;; Description: makes these windows easier to reason about and explain to users

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme024-0-market-scalar-pyth set-dispute-window-length u72))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme024-0-market-predicting  set-dispute-window-length u72))
		(try! (contract-call? 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ.bme021-0-market-voting  set-voting-duration u72))
		(ok true)
	)
)