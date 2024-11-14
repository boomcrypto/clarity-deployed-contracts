---
title: "Trait univ2-lp-token-v1_0_0-0013"
draft: true
---
```
;;; Velar LP token

(impl-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .univ2-lp-token-trait_v1_0_0.univ2-lp-token-trait)

;; No maximum supply!
(define-fungible-token lp-token)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-check-owner (err u2001))
(define-constant err-transfer    (err u2002))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership
(define-data-var owner principal .univ2-registry_v1_0_0)
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller (var-get owner)) err-check-owner)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; storage
(define-data-var name   (string-ascii 32) "token0-token1")
(define-data-var symbol (string-ascii 32) "token0-token1")
(define-data-var initialized bool false)

(define-public (init
  (pool principal) ;; TODO: pool-trait ?
  (symbol_ (string-ascii 32)))
  (begin
    (try! (check-owner)) ;; remove for registry-free deploys
    (asserts! (not (var-get initialized)) err-check-owner)

    (var-set name symbol_)
    (var-set symbol symbol_)
    (var-set owner pool)
    (ok (var-set initialized true)) ))

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

(define-read-only (get-name)                   (ok (var-get name)))
(define-read-only (get-symbol)                 (ok (var-get symbol)))
(define-read-only (get-decimals)               (ok u0))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)	             (ok none))

;;; eof

```
