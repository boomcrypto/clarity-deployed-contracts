;; leos-stage1-traits
;; description: all trait definitions for leos-stage1

;; ft-trait
(define-trait ft-trait
	(
		;; the ticker symbol, or empty if none
		(get-symbol () (response (string-ascii 32) uint))

		;; the balance of the passed principal
		(get-balance (principal) (response uint uint))
	)
)

;; sandbox-contract-trait
(define-trait sandbox-contract-trait
	(
		(test-emit-event () (response uint uint))
	)
)

;; boom-nft-trait
(define-trait boom-nft-trait
	(
		;; Owner of a given token identifier
		(get-owner (uint) (response (optional principal) uint))
	)
)

;; MultiSafe trait
(define-trait safe-trait
	(
		(get-info () (response {version: (string-ascii 20), owners: (list 20 principal), threshold: uint, nonce: uint, mb-address: principal} uint))
	)
)
