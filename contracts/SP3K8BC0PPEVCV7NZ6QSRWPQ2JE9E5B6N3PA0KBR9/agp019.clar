(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

(define-constant approved-contract 'SP3N7Y3K01Y24G9JC1XXA13RQXXCY721WAVBMMD38)

(define-public (execute (sender principal))
	(contract-call? .token-apower add-approved-contract approved-contract)
)
