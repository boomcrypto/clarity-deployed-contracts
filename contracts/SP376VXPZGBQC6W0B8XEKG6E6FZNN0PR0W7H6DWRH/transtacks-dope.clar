(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)
(use-trait nft-trait .sip009-nft-trait.sip009-nft-trait)

(define-private (transfer-stx-many-core (recipient {amount: uint, to: principal}))
	(begin
		(stx-transfer? (get amount recipient) tx-sender (get to recipient))
	)
)

(define-public (transfer-stx-many (recipients (list 400 {amount: uint, to: principal})))
	(begin
		(map transfer-stx-many-core recipients)
		(ok true)
	)
)

(define-private (transfer-ft-many-core (recipient {amount: uint, sender: principal, to: principal}) (token-contract <ft-trait>))
	(begin
		(unwrap-panic (contract-call? token-contract transfer (get amount recipient) (get sender recipient) (get to recipient) none))
		token-contract
	)
)

(define-public (transfer-ft-many (recipients (list 400 {amount: uint, sender: principal, to: principal})) (token-contract <ft-trait>))
	(begin
		(fold transfer-ft-many-core recipients token-contract)
		(ok true)
	)
)

(define-public (transfer-nft (nft-contract <nft-trait>) (recipient {token-id: uint, sender: principal, to: principal}))
	(let 
		(
			(token-id (get token-id recipient))
			(sender (get sender recipient))
			(to (get to recipient))
		)
		(contract-call? nft-contract transfer token-id sender to)
	)
)

