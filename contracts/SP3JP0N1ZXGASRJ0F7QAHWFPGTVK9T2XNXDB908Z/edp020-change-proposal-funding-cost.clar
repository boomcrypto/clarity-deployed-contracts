;; DAO: Ecosystem DAO
;; Title: EDP020 Change Proposal Funding Cost
;; Author: Clarity Lab
;; Synopsis: Make the cost of funding a proposal affordable.
;; Description:
;; At the momnet the cost of submitting a proposal to the DAO
;; is 1000 STX where this can be crowd funded or paid up front.
;; For the purposes of the 2.1 Vote this is impractical and this
;; proposal drops the cost to 5 STX

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .ede008-funded-proposal-submission-v3 set-parameter "funding-cost" u5000000)) 
		(ok true)
	)
)
