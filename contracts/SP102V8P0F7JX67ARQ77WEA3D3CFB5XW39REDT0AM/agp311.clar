(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPBWF3YPMGYHKBSZ7RES7HK1JPHEBW1P2WWCNZ04))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3P0PYJ5X74PTF48DVN9TJEDB15H4AS320F7QRA1))
(ok true)))