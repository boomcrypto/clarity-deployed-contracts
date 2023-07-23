;;; Template for LP Token implementation.

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .ft-plus-trait.ft-plus-trait)

(define-fungible-token lp-token)

(define-constant err-check-owner (err u1))
(define-constant err-mint        (err u2)) ;; not used
(define-constant err-burn        (err u3)) ;; not used
(define-constant err-transfer    (err u4))

(define-data-var owner principal tx-sender)

(define-read-only (get-owner) (var-get owner))

(define-private (check-owner)
  (ok (asserts! (or (is-eq tx-sender (get-owner)) (is-eq contract-caller .univ2-core)) err-check-owner)))

(define-public (set-owner (new-owner principal))
  (begin
    (try! (check-owner))
    (ok (var-set owner new-owner)) ))

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

(define-read-only (get-name)                   (ok "wstx-xusd"))
(define-read-only (get-symbol)                 (ok "wstx-xusd"))
(define-read-only (get-decimals)               (ok u0))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)	             (ok none))
