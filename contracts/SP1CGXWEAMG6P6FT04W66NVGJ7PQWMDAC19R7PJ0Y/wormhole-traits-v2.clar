;; Title: core-traits
;; Version: v2
;; Check for latest version: https://github.com/Trust-Machines/stacks-pyth-bridge#latest-version
;; Report an issue: https://github.com/Trust-Machines/stacks-pyth-bridge/issues

(define-trait core-trait
	(
		;; Parse and Verify cryptographic validity of a VAA
		(parse-and-verify-vaa ((buff 8192)) (response {
			version: uint, 
			guardian-set-id: uint,
			emitter-chain: uint,
			emitter-address: (buff 32),
			sequence: uint,
			payload: (buff 8192),
		} uint))
	)
)