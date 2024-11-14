---
title: "Trait up-dog"
draft: true
---
```
;; WELSH-DOG LP token.

(impl-trait .dao-traits-v4.sip010-ft-trait)
(impl-trait .dao-traits-v4.ft-plus-trait)

;; No maximum supply!
(define-fungible-token lp-token)

;; creative extras
(define-constant contract (as-contract tx-sender))
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/sip10/up-dog/metadata.json"))
(define-data-var token-decimals uint u6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-check-owner  (err u1))
(define-constant err-transfer     (err u2))
(define-constant err-unauthorized (err u3))

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

(define-private (is-dao-or-extension)
  (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)))

(define-private (is-authorized)
	(ok (asserts! (is-dao-or-extension) err-unauthorized)))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-authorized))
		(var-set token-uri new-uri)
		(ok (print { notification: "token-metadata-update",	payload: { token-class: "ft",	contract-id: contract	}}))))

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-authorized))
		(ok (var-set token-decimals new-decimals))))

(define-read-only (get-name)                   (ok "Up Dog"))
(define-read-only (get-symbol)                 (ok "UPDOG"))
(define-read-only (get-decimals)               (ok (var-get token-decimals)))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)	             (ok (var-get token-uri)))

;;; eof
```
