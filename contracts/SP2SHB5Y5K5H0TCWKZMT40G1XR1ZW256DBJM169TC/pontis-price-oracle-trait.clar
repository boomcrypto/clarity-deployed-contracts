(define-trait pontis-price-oracle-trait
	(
    (get-price ((buff 26)) (response (optional uint) uint))
    (get-last-update-block-height () (response uint uint))
	)
)