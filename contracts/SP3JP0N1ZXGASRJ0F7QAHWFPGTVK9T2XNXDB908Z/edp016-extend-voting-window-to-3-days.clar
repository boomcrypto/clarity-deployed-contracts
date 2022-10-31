;; DAO: Ecosystem DAO
;; Title: EDP016 Change Voting Window
;; Author: Clarity Lab
;; Synopsis: Change DAO parameters for testing SIP activation voting.
;; Description:
;; This proposal sets the voting window to 432 (3 days) for DAO testing. 

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ede008-funded-proposal-submission-v2 set-parameter "proposal-duration" u432))
		(ok true)
	)
)
