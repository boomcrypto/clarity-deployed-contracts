(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
        (try! (contract-call? .alex-vault add-approved-contract .yield-token-pool))
        (try! (contract-call? .alex-reserve-pool add-approved-contract .yield-token-pool))
        (try! (contract-call? .yield-alex-v1 transfer-fixed u65500 u192022375050 tx-sender 'SP22PCWZ9EJMHV4PHVS0C8H3B3E4Q079ZHY6CXDS1))
        (ok true)                    
	)
)