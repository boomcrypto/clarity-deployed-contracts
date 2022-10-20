;; DAO: Ecosystem DAO
;; Title: EDP001 Adjust DAO Parameters
;; Author: daoguy.btc
;; Synopsis:
;; Adjusts the DAO parameters for the 2.1 vote
;; Description:
;; This proposal - if accepted - will set the voting window
;; for the 2.1 vote to 2016 blocks (roughly 2 weeks). This means
;; community members will have 2 weeks to cast their vote after this
;; proposal is deployed and funded.

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Set voting window to 2 weeks.
		(try! (contract-call? .ede008-funded-proposal-submission-v2 set-parameter "proposal-duration" u2016)) 
		(ok true)
	)
)
