;; SIP-010 Token: QUSD

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-NOT-ENOUGH-FUND (err u102))
(define-constant ERR-INVALID-PARAMETERS (err u103))

;; Data
(define-constant token-decimals u8)
(define-data-var token-name (string-ascii 32) "QvaPayUSD")
(define-data-var token-symbol (string-ascii 10) "QUSD")
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://qvpay.me/qusd.json"))

;; Fungible Token
(define-fungible-token QUSD)

;; Mint (only owner)
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
        (asserts! (> amount u0) ERR-INVALID-PARAMETERS)
        (ft-mint? QUSD amount recipient)
    )
)

;; Burn (only owner)
(define-public (burn (amount uint) (sender principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
        (asserts! (> amount u0) ERR-INVALID-PARAMETERS)
        (ft-burn? QUSD amount sender)
    )
)

;; Transfer (must be called by sender)
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
		(try! (ft-transfer? QUSD amount sender recipient))
		(match memo to-print (print to-print) 0x)
		(ok true)
	)
)

;; Set token uri
(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
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

;; Set token name
(define-public (set-token-name (value (string-ascii 32)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
        (var-set token-name value)
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

;; Set token symbol
(define-public (set-token-symbol (value (string-ascii 10)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-OWNER-ONLY)
        (var-set token-symbol value)
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

;; Read-only accessors
(define-read-only (get-name)
    (ok (var-get token-name))
)
(define-read-only (get-symbol)
    (ok (var-get token-symbol))
)
(define-read-only (get-decimals)
    (ok token-decimals)
)
(define-read-only (get-balance (who principal))
    (ok (ft-get-balance QUSD who))
)
(define-read-only (get-total-supply)
    (ok (ft-get-supply QUSD))
)
(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)
