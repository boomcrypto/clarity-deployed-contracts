(define-trait sip010-ft-trait
	(
		(transfer (uint principal principal (optional (buff 34))) (response bool uint))

		(get-name () (response (string-ascii 32) uint))

		(get-symbol () (response (string-ascii 32) uint))

		(get-decimals () (response uint uint))

		(get-balance (principal) (response uint uint))

		(get-total-supply () (response uint uint))

		(get-token-uri () (response (optional (string-utf8 256)) uint))
	)
)