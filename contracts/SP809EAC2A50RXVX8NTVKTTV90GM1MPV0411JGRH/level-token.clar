;; sip010-token
;; A SIP010-compliant fungible token with a mint function.

(impl-trait .sip010-ft-trait.sip010-ft-trait)

(define-constant contract-owner tx-sender)

(define-fungible-token level-coin u10000000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u102))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(ft-transfer? level-coin amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok "Level Coin")
)

(define-read-only (get-symbol)
	(ok "LV5")
)

(define-read-only (get-decimals)
	(ok u6)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance level-coin who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply level-coin))
)

(define-read-only (get-token-uri)
	(ok none)
)

(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(ft-mint? level-coin amount recipient)
	)
)