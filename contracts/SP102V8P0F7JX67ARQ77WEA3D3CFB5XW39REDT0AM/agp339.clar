(impl-trait .proposal-trait.proposal-trait)
(define-constant recipient 'SP14ZTW676MZ8TZ5EAWH3KJ8MSZQBP0VBMF1AXHR7)
(define-constant old-recipient 'SP98NTAY6CVKNCF7H3A6EEXFK4H0SSJ3PP6SZ61J)
(define-constant amount u7383824537133478)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many (list { recipient: recipient, amount: amount })))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-fixed amount old-recipient))
		(ok true)))