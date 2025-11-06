(use-trait token-migration-trait .token-migration-trait-v1.token-migration-trait)

(define-trait interim-token-trait
	(
		(start-migration (<token-migration-trait>) (response bool uint))
		(migrate-balance (principal) (response uint uint))
	)
)