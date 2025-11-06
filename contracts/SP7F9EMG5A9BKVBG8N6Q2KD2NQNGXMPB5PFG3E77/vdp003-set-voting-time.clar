;; Title: VDP003 Set Voting Time
;; Description: This contract is used to set voting period of proposals.

(impl-trait 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		
		;; set voting period to 7 days
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde002-proposal-submission set-parameter "minimum-proposal-start-delay" u1008)) 
		

		;; increase the emergency proposal and emergency execute by 12 months
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde003-emergency-proposals set-emergency-team-sunset-height (+ burn-block-height u51840))) 
		(try! (contract-call? 'SP17W58X5Y59K4SD574XTRA6VN1DZNSHXBVP4PQSX.vde004-emergency-execute set-executive-team-sunset-height (+ burn-block-height u51840))) 
			

		(print "VDP003 Reduce Voting Time executed")
		(ok true)

	)
)