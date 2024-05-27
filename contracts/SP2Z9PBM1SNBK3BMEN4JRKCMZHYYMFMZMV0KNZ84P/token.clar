;; Assert that this contract implements the `sip-010-trait`
;; the contract principal is the mainnet address where this trait
;; is deployed
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Set a few constants for the contract owner, and a couple of error codes
(define-constant contract-owner contract-caller)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; No maximum supply!
;; To provide a maximum supply, an optional second `uint` argument can be given
(define-fungible-token clarity-coin)

;; `transfer` function to move tokens around from `contract-caller` to someone else
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq contract-caller sender) err-not-token-owner)
		(try! (ft-transfer? clarity-coin amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

(define-read-only (get-name)
	(ok "TokenizedAsset")
)

(define-read-only (get-symbol)
	(ok "TA")
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance clarity-coin who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply clarity-coin))
)

(define-read-only (get-token-uri)
	(ok none)
)

;; owner-only function to `mint` some `amount` of tokens to `recipient`
(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq contract-caller contract-owner) err-owner-only)
		(ft-mint? clarity-coin amount recipient)
	)
)