(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)
(define-constant start-block u57857)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-token .auto-fwp-wstx-alex-120))
		(try! (contract-call? .alex-vault add-approved-token .auto-fwp-wstx-alex-120x))
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .auto-fwp-wstx-alex-120x))
		(try! (contract-call? .auto-fwp-wstx-alex-120 set-start-block start-block))
		
		(try! (contract-call? .auto-fwp-wstx-alex-120x set-available-alex 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH (* u105005 ONE_8)))
		(try! (contract-call? .auto-fwp-wstx-alex-120x set-available-alex 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66 (* u200000 ONE_8)))

		(ok true)	
	)
)
