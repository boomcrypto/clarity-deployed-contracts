;; sip010-token
;; A SIP010-compliant fungible token with a mint function

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant contract-owner tx-sender)

;; 10000000.000000 max-supply

(define-fungible-token anomaly-token u10000000000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u102))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
     (asserts! (is-eq tx-sender sender) err-not-token-owner)
     (ft-transfer? anomaly-token amount sender recipient)))

(define-read-only (get-name)
  (ok "ANOMALY Token"))

(define-read-only (get-symbol)
  (ok "XAY"))

(define-read-only (get-decimals)
  (ok u6))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance anomaly-token who)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply anomaly-token)))

(define-read-only (get-token-uri)
  (ok none))

(define-public (mint (amount uint) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender contract-owner) err-owner-only)
     (ft-mint? anomaly-token amount recipient)))