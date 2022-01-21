(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))
(define-constant fifty-percent (/ ONE_8 u2))
(define-constant reduce-amount (/ (* ONE_8 u99) u100))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .token-wbtc fifty-percent fifty-percent .fwp-wstx-wbtc-50-50 reduce-amount))
		(try! (contract-call? .weighted-equation set-max-in-ratio (/ (* ONE_8 u1) u100)))
        (try! (contract-call? .weighted-equation set-max-out-ratio (/ (* ONE_8 u1) u100)))
        (ok true)	
	)
)
