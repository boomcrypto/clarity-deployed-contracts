(define-trait ido-ft-trait
	(
		(transfer-many-ido (uint (list 200 principal)) (response bool uint))
		(transfer-many-amounts-ido ((list 200 {recipient: principal, amount: uint})) (response bool uint))
	)
)