;; DAO: Ecosystem DAO
;; Title: EDP017 Extend Voting Window
;; Author: Clarity Lab
;; Synopsis: Set voting window for Stacks 2.1 Upgrade.
;; Description:
;; Sets the voting window, for the Stacks 2.1 Upgrade vote,
;; to 4032 block (roughly 4 weeks). 

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ede008-funded-proposal-submission-v2 set-parameter "proposal-duration" u4032))
		(ok true)
	)
)
