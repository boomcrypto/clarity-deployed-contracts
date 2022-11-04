;; DAO: Ecosystem DAO
;; Title: EDP019 Enable a Cap on Voting
;; Author: Clarity Lab
;; Synopsis: Activates voting extensions which enforce a cap on voting power.
;; Description:
;; These voting contracts enabled by this proposal
;; implement a cap on voting power that any one account can vote with.
;; The cap is set to the current minimum stacking amount. 
;; The prevents whales from overwhelming the vote.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ecosystem-dao set-extensions
			(list
				{extension: .ede007-snapshot-proposal-voting-v3, enabled: true}
				{extension: .ede008-funded-proposal-submission-v3, enabled: true}
			)
		))
		(ok true)
	)
)
