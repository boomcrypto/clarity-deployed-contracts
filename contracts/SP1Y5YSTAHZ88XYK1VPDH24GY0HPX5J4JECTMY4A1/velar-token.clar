;;; Velar SIP010 token.

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant DECIMALS (pow u10 u6))

(define-fungible-token velar (* u1000000000 DECIMALS)) ;;1 billion

(define-constant err-check-owner (err u1))
(define-constant err-transfer    (err u4))

(define-data-var owner principal tx-sender)

(define-private (check-owner)
  (ok (asserts! (is-eq tx-sender (var-get owner)) err-check-owner)))

(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender from) err-transfer)
    (ft-transfer? velar amt from to)))


(define-public (mint (amt uint) (to principal))
	(begin
    (try! (check-owner))
	  (ft-mint? velar amt to) ))

(define-read-only (get-name)                   (ok "Velar"))
(define-read-only (get-symbol)                 (ok "VELAR"))
(define-read-only (get-decimals)               (ok u6))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance velar of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply velar)))
(define-read-only (get-token-uri)              (ok (some u"https://velar.co/metadata/velar-token.json")))

;;; eof
