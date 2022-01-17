;; sip010-actest-token
;; A SIP010-compliant fungible token

(impl-trait .sip010-ft-trait.sip010-ft-trait)

(define-constant contract-owner tx-sender)

(define-fungible-token ac-test-coin u10000000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u102))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(ft-transfer? ac-test-coin amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok "AC Test")
)

(define-read-only (get-symbol)
	(ok "ACTEST")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance ac-test-coin who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply ac-test-coin))
)

;; Token URI
;; --------------------------------------------------------------------------

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"https://tokens.arcade.city/metadata/token-actest.json")

;; Public getter for the URI
(define-read-only (get-token-uri)
	(ok (some (var-get uri)))
)

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; Print the action for any off-chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))

(define-read-only (get-balance-of (owner principal))
  (ok (ft-get-balance ac-test-coin owner))
)

;; One-stop functions to gather all relevant token data in one call
(define-read-only (get-data)
  (ok {
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (get-total-supply))
  })
)

(define-read-only (get-data-with-balance (owner principal))
  (ok {
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (get-total-supply)),
    balance: (unwrap-panic (get-balance-of owner))
  })
)


;; Mint -- INITIAL AND ONLY -- Locked at 10B supply
;; --------------------------------------------------------------------------
(ft-mint? ac-test-coin u10000000000 tx-sender)
