(define-trait governance-token-trait
	(
		(bmg-get-balance (principal) (response uint uint))
		(bmg-has-percentage-balance (principal uint) (response bool uint))
		(bmg-transfer (uint principal principal) (response bool uint))
		(bmg-lock (uint principal) (response bool uint))
		(bmg-unlock (uint principal) (response bool uint))
		(bmg-get-locked (principal) (response uint uint))
		(bmg-mint (uint principal) (response bool uint))
		(bmg-burn (uint principal) (response bool uint))
	)
)
