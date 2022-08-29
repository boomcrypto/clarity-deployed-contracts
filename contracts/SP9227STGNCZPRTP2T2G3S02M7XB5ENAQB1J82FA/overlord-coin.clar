;; Overlord Coin
;; Kill the Demon Overlord and receive reward!

;; IMPL

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; STORAGE

(define-fungible-token overlord-coin u1000000)

;; CONSTANTS

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u500))
(define-constant err-not-token-owner (err u501))
(define-constant err-min-transfer (err u502))

;; READ-ONLY

(define-read-only (get-name)
    (ok "Overlord Coin")
)

(define-read-only (get-symbol)
    (ok "OV")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance overlord-coin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply overlord-coin))
)

(define-read-only (get-token-uri)
    (ok none)
)

;; PUBLIC

;; Token owner transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        ;; #[filter(amount, recipient)]
        (asserts! (> amount u0) err-min-transfer)
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? overlord-coin amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

;; Only owner can mint
(define-public (mint (amount uint) (recipient principal))
    (begin
        ;; #[filter(amount, recipient)]
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? overlord-coin amount recipient)
    )
)