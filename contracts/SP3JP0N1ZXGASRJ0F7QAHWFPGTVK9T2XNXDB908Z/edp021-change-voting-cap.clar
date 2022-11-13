;; DAO: Ecosystem DAO
;; Title: Enable V4 Voting Extensions
;; Author: Clarity Lab
;; Synopsis: Activates voting extensions which enforce a cap on voting power.
;; Description:
;; Changes the voting cap to 140K STX and disables the v4 voting extensions.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ecosystem-dao set-extensions
			(list
				{extension: .ede007-snapshot-proposal-voting-v5, enabled: true}
				{extension: .ede008-funded-proposal-submission-v5, enabled: true}
				{extension: .ede007-snapshot-proposal-voting-v4, enabled: false}
				{extension: .ede008-funded-proposal-submission-v4, enabled: false}
			)
		))
		(ok true)
	)
)
