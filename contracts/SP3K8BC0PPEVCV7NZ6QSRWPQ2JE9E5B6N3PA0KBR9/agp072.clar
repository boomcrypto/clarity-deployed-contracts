(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP13F0C8HFJC9H1FR7S7WFZ9FEMNV1PBEG3GWS5N0 u1 u0))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP1QSYZ0TY2SM6GKNF7SKN0BRD5GFM4HN5KXZNHG5 u1 u0))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP20G252BDQ3920ABQAT6PJSZE77NXZ35MC4Q7R4R u1 u0))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP17GNF0HPB5K5MSNYFEBQ16CRY17KX4YJ3RXKDRP u1 u0))	
			
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SPVZB7A41TMC654VEKGN8YF5SH6THP4CYHZDHW10 u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP2XE79SP3TQK67M50C44G1N021RJCMG0PPHFXWPN u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP1D5G1QK9W2NF17Y4WTRK5YB1NTXMJ4185YF7KG5 u1 (* u1500000 ONE_8)))
		(try! (contract-call? .auto-fwp-alex-autoalex-x-v1-01 set-available-alex 'SP27P9THY6FP2XCH30RQG9Y7GD7779JXTNJQFP97V u1 (* u3000000 ONE_8)))
		
		(ok true)	
	)
)