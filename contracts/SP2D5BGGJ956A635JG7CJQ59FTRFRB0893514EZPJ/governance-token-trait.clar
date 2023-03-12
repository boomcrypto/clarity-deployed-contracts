(define-trait governance-token-trait
	(
		(dmg-get-balance (principal) (response uint uint))
		(dmg-has-percentage-balance (principal uint) (response bool uint))
		(dmg-transfer (uint principal principal) (response bool uint))
		(dmg-lock (uint principal) (response bool uint))
		(dmg-unlock (uint principal) (response bool uint))
		(dmg-get-locked (principal) (response uint uint))
		(dmg-mint (uint principal) (response bool uint))
		(dmg-burn (uint principal) (response bool uint))
	)
)
