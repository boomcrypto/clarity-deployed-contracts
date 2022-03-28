(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

;; fwp-alex-wban
(define-constant start-block u53960) 

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .simple-weight-pool-alex set-start-block .age000-governance-token .token-wban start-block))
		(ok true)	
	)
)
