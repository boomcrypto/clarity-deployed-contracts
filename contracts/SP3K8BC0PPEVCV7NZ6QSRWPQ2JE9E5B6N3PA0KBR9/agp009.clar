(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .weighted-equation set-max-in-ratio (/ (* ONE_8 u5) u100)))
          (try! (contract-call? .weighted-equation set-max-out-ratio (/ (* ONE_8 u5) u100)))
          (ok true)	
	)
)
