(define-trait actions-trait
	(
		(pause (bool) (response bool uint))
    (set-approval-status (principal uint bool) (response bool uint))
	)
)