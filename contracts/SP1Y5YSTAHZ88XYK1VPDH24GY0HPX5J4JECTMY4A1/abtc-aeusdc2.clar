;;; abtc-aeusdc2 LP token.

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .ft-plus-trait.ft-plus-trait)

;; No maximum supply!
(define-fungible-token lp-token)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-check-owner (err u1))
(define-constant err-transfer    (err u2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller .univ2-core) err-check-owner)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ft-plus-trait
(define-public (mint (amt uint) (to principal))
  (begin
    (try! (check-owner))
    (ft-mint? lp-token amt to) ))

(define-public (burn (amt uint) (from principal))
  (begin
    (try! (check-owner))
    (ft-burn? lp-token amt from) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ft-trait
(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
	(begin
	 (asserts! (is-eq tx-sender from) err-transfer)
	 (ft-transfer? lp-token amt from to)))

(define-read-only (get-name)                   (ok "abtc-aeusdc2"))
(define-read-only (get-symbol)                 (ok "abtc-aeusdc2"))
(define-read-only (get-decimals)               (ok u0))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)	             (ok none))

;;; eof
