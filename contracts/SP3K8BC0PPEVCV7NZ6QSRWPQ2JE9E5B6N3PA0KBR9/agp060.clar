(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)
(define-constant start-block u0)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-vault add-approved-token .auto-fwp-alex-autoalex-x))
		(try! (contract-call? .age000-governance-token edg-add-approved-contract .auto-fwp-alex-autoalex-x))
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-start-block start-block))
		
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-tranche-end-block u1 u114149))
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-available-alex 'SP13F0C8HFJC9H1FR7S7WFZ9FEMNV1PBEG3GWS5N0 u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-available-alex 'SP1QSYZ0TY2SM6GKNF7SKN0BRD5GFM4HN5KXZNHG5 u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-available-alex 'SP20G252BDQ3920ABQAT6PJSZE77NXZ35MC4Q7R4R u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x set-available-alex 'SP17GNF0HPB5K5MSNYFEBQ16CRY17KX4YJ3RXKDRP u1 (* u1500000 ONE_8)))

		(ok true)	
	)
)
