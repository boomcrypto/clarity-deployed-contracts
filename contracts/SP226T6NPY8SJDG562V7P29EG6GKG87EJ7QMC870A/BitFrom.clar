(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; No maximum supply!
(define-fungible-token BitFrom)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? BitFrom amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (harvest (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (ft-transfer? BitFrom amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
    (ok "BitFrom")
)

(define-read-only (get-symbol)
    (ok "FR")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance BitFrom who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply BitFrom))
)


(define-read-only (get-token-uri)
    (ok none)
)


(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? BitFrom amount recipient)
    )
)