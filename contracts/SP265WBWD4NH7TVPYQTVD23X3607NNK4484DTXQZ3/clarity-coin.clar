
;; title: clarity-coin
;; version:
;; summary:
;; description:

;; traits
;;
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; token definitions
;;
(define-fungible-token clarity-coin)
;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; data vars
;;

;; data maps
;;

;; public functions
;;
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? clarity-coin amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

;; read only functions
;;
(define-read-only (get-name)
    (ok "Clarity Coin")
)

(define-read-only (get-symbol)
    (ok "CC")
)

(define-read-only (get-decimals)
    (ok u6)
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

(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ft-mint? clarity-coin amount recipient)
    )
)

;; private functions
;;

