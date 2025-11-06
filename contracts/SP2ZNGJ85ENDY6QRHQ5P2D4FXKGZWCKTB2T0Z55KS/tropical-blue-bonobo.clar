;; Basic Fungible Token Contract

;; Errors
(define-constant err-not-enough-balance (err u1))
(define-constant err-sender-recipient (err u2))
(define-constant err-invalid-amount (err u3))
(define-constant err-not-token-owner (err u4))

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))
(define-constant MAX_SUPPLY u10000000000) ;; 10B

;; Fungible Token Definition
(define-fungible-token TKN MAX_SUPPLY)

;; --- SIP10 Standard Interface ---

(define-read-only (get-name)
	(ok "Token")
)

(define-read-only (get-symbol)
	(ok "TKN")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance TKN who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply TKN))
)

(define-read-only (get-token-uri)
	(ok u"data:application/json;base64,eyJzaXAiOjE2LCJuYW1lIjoiVG9rZW4iLCJpbWFnZSI6ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBQUVBQUFBQkNBWUFBQUFmRmNTSkFBQUFEVWxFUVZSNEFXTVFZVHIzSHdBQzlnSGtmazFpTHdBQUFBQkpSVTVFcmtKZ2dnPT0ifQ==")
)

(define-public (transfer
		(amount uint)
		(sender principal)
		(recipient principal)
		(memo (optional (buff 34)))
	)
	(begin
		;; Security checks
		(asserts! (is-eq tx-sender sender) err-not-token-owner)
		(asserts! (>= amount u1) err-invalid-amount)
		(asserts! (not (is-eq sender recipient)) err-sender-recipient)
		(asserts! (>= (ft-get-balance TKN sender) amount) err-not-enough-balance)
		;; Transfer tokens
		(ft-transfer? TKN amount sender recipient)
	)
)

;; --- Initialization ---

(begin
	;; Mint tokens to deployer
	(ft-mint? TKN MAX_SUPPLY DEPLOYER)
)
