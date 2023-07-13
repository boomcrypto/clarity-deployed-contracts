(define-trait sft-trait
	(
		(get-balance (uint principal) (response uint uint))
		(get-overall-balance (principal) (response uint uint))
		(get-total-supply (uint) (response uint uint))
		(get-overall-supply () (response uint uint))
		(get-decimals (uint) (response uint uint))
		(get-token-uri (uint) (response (optional (string-ascii 256)) uint))
		(transfer (uint uint principal principal) (response bool uint))
		(transfer-memo (uint uint principal principal (buff 34)) (response bool uint))
	)
)