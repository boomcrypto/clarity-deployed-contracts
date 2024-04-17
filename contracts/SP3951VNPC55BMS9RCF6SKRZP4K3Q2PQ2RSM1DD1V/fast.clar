;; ---------------------------------------------------------
;; FAST - SIP-10 Fungible Token Contract
;; ---------------------------------------------------------
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token fast)

;; ---------------------------------------------------------
;; Constants/Variables
;; ---------------------------------------------------------
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var contract-owner principal tx-sender)

;; ---------------------------------------------------------
;; Errors
;; ---------------------------------------------------------
(define-constant ERR_UNAUTHORIZED (err u100))

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_UNAUTHORIZED)
        (try! (ft-transfer? fast amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-balance (owner principal))
    (ok (ft-get-balance fast owner))
)

(define-read-only (get-name)
    (ok "Fast")
)

(define-read-only (get-symbol)
    (ok "FAST")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply fast))
)

(define-read-only (get-token-uri)
        (ok (var-get token-uri))
)

;; ---------------------------------------------------------
;; Privileged Functions
;; ---------------------------------------------------------

(define-public (set-token-uri (value (string-utf8 256)))
    (if (is-eq tx-sender (var-get contract-owner))
        (ok (var-set token-uri (some value)))
        (err ERR_UNAUTHORIZED)
    )
)

(define-public (set-contract-owner (new-owner principal))
    (if (is-eq tx-sender (var-get contract-owner))
        (ok (var-set contract-owner new-owner))
        (err ERR_UNAUTHORIZED)
    )
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 1000 { to: principal, amount: uint, memo: (optional (buff 34)) })))
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

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(begin
    (try! (ft-mint? fast u10000000000000000 tx-sender))
)
