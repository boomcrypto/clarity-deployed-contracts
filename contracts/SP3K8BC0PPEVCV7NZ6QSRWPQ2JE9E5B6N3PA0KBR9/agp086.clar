(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount-to-add (* u1000000 ONE_8))
(define-public (execute (sender principal))
	(let 
		(
			(bal-before (contract-call? .alex-reserve-pool get-balance .auto-alex))
		)
		(try! (contract-call? .auto-alex transfer-fixed amount-to-add tx-sender .alex-vault none))
		(try! (contract-call? .alex-reserve-pool add-to-balance .auto-alex amount-to-add))
		(try! (contract-call? .collateral-rebalancing-pool-v1 roll-auto .ytp-alex-v1 .age000-governance-token .auto-alex .yield-alex-v1 .key-alex-autoalex-v1 .auto-ytp-alex .auto-key-alex-autoalex))
		(let 
			(
				(bal-after (contract-call? .alex-reserve-pool get-balance .auto-alex))
				(amount-to-return (- bal-after bal-before))
			)
			(try! (contract-call? .alex-reserve-pool remove-from-balance .auto-alex amount-to-return))
			(try! (contract-call? .alex-vault transfer-ft .auto-alex amount-to-return tx-sender))
			(ok true)
		)		
	)
)