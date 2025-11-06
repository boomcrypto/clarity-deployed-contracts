;; Title: Gating
;; Author(s): mijoco.btc
;; Synopsis:
;; Description:

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .bigmarket-dao set-extensions
			(list
				{extension: .bme008-0-resolution-coordinator, enabled: true}
			)
		))
		;; [alice, bob, tom, betty, wallace];
		(try! (contract-call? .bme021-0-market-voting set-voting-duration u3))
		(try! (contract-call? .bme024-0-market-predicting set-dispute-window-length u3))
		(try! (contract-call? .bme024-0-market-predicting set-resolution-agent .bme008-0-resolution-coordinator))
		(ok true)
	)
)
