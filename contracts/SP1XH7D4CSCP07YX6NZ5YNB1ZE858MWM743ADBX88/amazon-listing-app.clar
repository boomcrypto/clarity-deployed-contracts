
;;Title:


;;Brief Summary:


;;Proposal Description:


;;Rationale:


;;Implementation Plan:


;;Timeline:


;;Expected Outcomes:


;;Total Amount:

;;Initial Amount:



(impl-trait 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.proposal-trait.proposal-trait)


(define-public (execute (sender principal))
	(begin

		;; vibes-transfer (initial-amount, receiver, memo)
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde000-treasury vibes-transfer u1500000000 'SP1XH7D4CSCP07YX6NZ5YNB1ZE858MWM743ADBX88 none))

		;; lock-funds (proposal-address ,amount, receiver/proposer)
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde005-council lock-funds (as-contract tx-sender) u8500000000 'SP1XH7D4CSCP07YX6NZ5YNB1ZE858MWM743ADBX88))

		(ok true)
	)
)
