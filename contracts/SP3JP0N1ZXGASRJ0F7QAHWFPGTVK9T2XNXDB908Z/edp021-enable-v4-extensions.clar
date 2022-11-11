;; DAO: Ecosystem DAO
;; Title: Enable V4 Voting Extensions
;; Author: Clarity Lab
;; Synopsis: Activates voting extensions which enforce a cap on voting power.
;; Description:
;; Reduces max voting power by amount stacked in the cycle when the voting started.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ecosystem-dao set-extensions
			(list
				{extension: .ede007-snapshot-proposal-voting-v4, enabled: true}
				{extension: .ede008-funded-proposal-submission-v4, enabled: true}
			)
		))
		(ok true)
	)
)
