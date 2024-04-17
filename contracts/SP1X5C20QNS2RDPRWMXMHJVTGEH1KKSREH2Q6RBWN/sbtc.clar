;; mainnet - SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard
;; testnet - ST2XX28V6YR45HZJ0D5990MRCBHMGC843GQQ12N1Q
;; devnet - ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-amount-not-gt-zero (err u102))
(define-constant err-principal-network-mismatch (err u103))

;; No maximum supply!
(define-fungible-token sbtc)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq true (> amount u0)) err-amount-not-gt-zero)
		(asserts! (is-standard recipient) err-principal-network-mismatch)
		(try! (ft-transfer? sbtc amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

(define-read-only (get-name)
	(ok "Mock Stacks BTC")
)

(define-read-only (get-symbol)
	(ok "mBTC")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance sbtc who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply sbtc))
)

(define-read-only (get-token-uri)
	(ok none)
)

(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(asserts! (is-eq true (> amount u0)) err-amount-not-gt-zero)
		(asserts! (is-standard recipient) err-principal-network-mismatch)
		(ft-mint? sbtc amount recipient)
	)
)	