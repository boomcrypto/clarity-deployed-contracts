(define-trait wallet-trait
	(
		(add-owner (principal) (response bool uint))
		(remove-owner (principal) (response bool uint))
		(set-min-confirmation (uint) (response bool uint))
	)
)

(define-trait executor-trait
	(
		(execute (<wallet-trait> principal uint) (response bool uint))
	)
)

