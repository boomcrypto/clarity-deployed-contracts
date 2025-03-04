(define-read-only (get-header-hash (u uint))
	(get-stacks-block-info? header-hash u)
)

(define-read-only (get-id-header-hash (u uint))
	(get-stacks-block-info? id-header-hash u)
)
