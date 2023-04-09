;; sip010-token
;; A SIP010-compliant fungible token with public mint function
;; 0 initial supply | 1000000000.00 max supply | mint 100.00 MICROFI tokens at a time

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token microfi-token u100000000000)

(define-constant err-not-token-owner (err u100))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
     (asserts! (is-eq tx-sender sender) err-not-token-owner)
     (ft-transfer? microfi-token amount sender recipient)))

(define-read-only (get-name)
  (ok "MICROFI"))

(define-read-only (get-symbol)
  (ok "XMI"))

(define-read-only (get-decimals)
  (ok u2))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance microfi-token who)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply microfi-token)))

(define-read-only (get-token-uri)
  (ok none))

(define-public (mint (recipient principal))
  (ft-mint? microfi-token u100 recipient))