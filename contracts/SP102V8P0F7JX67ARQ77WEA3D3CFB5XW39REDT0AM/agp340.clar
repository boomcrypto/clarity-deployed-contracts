(impl-trait .proposal-trait.proposal-trait)
(define-constant recipient 'SP14ZTW676MZ8TZ5EAWH3KJ8MSZQBP0VBMF1AXHR7)
(define-constant old-recipient 'SP98NTAY6CVKNCF7H3A6EEXFK4H0SSJ3PP6SZ61J)
(define-constant amount u7383824537133478)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .migrate-legacy-v2-wl set-threshold u0))
		(ok true)))