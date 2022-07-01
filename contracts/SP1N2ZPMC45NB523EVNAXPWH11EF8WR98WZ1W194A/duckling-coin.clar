;; SIP010 trait on mainnet
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; No maximum supply!
(define-fungible-token duckling-coin)

;; Transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (try! (ft-transfer? duckling-coin amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

;; Get name
(define-read-only (get-name)
    (ok "Duckling Coin")
)

;; Get Symbol
(define-read-only (get-symbol)
    (ok "DKC")
)

;; Get decimals
(define-read-only (get-decimals)
    (ok u6)
)

;; Get balance
(define-read-only (get-balance (who principal))
    (ok (ft-get-balance duckling-coin who))
)

;; Get total supply
(define-read-only (get-total-supply)
    (ok (ft-get-supply duckling-coin))
)


;; Get token uri
(define-read-only (get-token-uri)
    (ok none)
)

;; Mint
(define-public (mint (amount uint) (recipient principal))
    (begin
        (ft-mint? duckling-coin amount recipient)
    )
)
