
;; @title Bonding Curve Token for STX.CITY Mini Version
;; @version 1.0
;; @summary A SIP-010 compliant fungible token for memecoin launches
;; @description This contract implements a fungible token that can be traded on bonding curves

;; Error constants
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

;; Implement the SIP-010 trait
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Token constants
(define-constant MAXSUPPLY u100000000000000) ;; 100M tokens with 6 decimals

;; Define the fungible token
(define-fungible-token MINI-TOKEN MAXSUPPLY)

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) none)

;; SIP-010 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
        (try! (ft-transfer? MINI-TOKEN amount from to))
        (ok true)
    )
)

(define-read-only (get-name)
	(ok "Mini Token")
)

(define-read-only (get-symbol)
	(ok "MINI")
)

(define-read-only (get-decimals)
	(ok u6)
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply MINI-TOKEN))
)

(define-read-only (get-balance (owner principal))
	(ok (ft-get-balance MINI-TOKEN owner))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; Owner-only functions
(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
        (var-set token-uri (some value))
        (ok (print {
				notification: "token-metadata-update",
				payload: {
				contract-id: (as-contract tx-sender),
				token-class: "ft"
				}
            })
        )
    )
)

(define-public (transfer-ownership (new-owner principal))
	(begin
		(asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-OWNER))
		(var-set contract-owner new-owner)
		(ok "Ownership transferred successfully")
	)
)

;; Utility Functions
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
	(fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
	(match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
	(send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
	(let ((transferOk (try! (transfer amount tx-sender to memo))))
		(ok transferOk)
	)
)

;; Mint function (called during contract initialization)
(define-public (mint (amount uint) (recipient principal))
	(begin
		(asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
		(try! (ft-mint? MINI-TOKEN amount recipient))
		(ok true)
	)
)

;; ---------------------------------------------------------
;; Top-level initialization - auto-mint tokens on deployment
;; ---------------------------------------------------------
(begin
    ;; Mint all tokens to the deployer initially
    (try! (ft-mint? MINI-TOKEN u100000000000000 tx-sender))
)

