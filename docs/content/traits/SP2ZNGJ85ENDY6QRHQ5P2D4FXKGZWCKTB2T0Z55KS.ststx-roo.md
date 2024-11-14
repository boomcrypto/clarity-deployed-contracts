---
title: "Trait ststx-roo"
draft: true
---
```
;; Roo Community Pool
;; stSTX-ROO LP token with configurable metadata

(impl-trait .dao-traits-v4.sip010-ft-trait)
(impl-trait .dao-traits-v4.ft-plus-trait)

;; No maximum supply!
(define-fungible-token lp-token)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant contract (as-contract tx-sender))

;; Configuration Variables
(define-data-var token-name (string-ascii 32) "Roo Community Pool")
(define-data-var token-symbol (string-ascii 10) "stSTX-ROO")
(define-data-var token-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/sip10/ststx-roo/metadata.json"))
(define-data-var token-decimals uint u8)

;; Rest of implementation remains the same as template
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-check-owner  (err u1))
(define-constant err-transfer     (err u2))
(define-constant err-unauthorized (err u401))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ownership
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller .univ2-core) err-check-owner)))

(define-private (is-owner)
  (is-eq tx-sender CONTRACT_OWNER))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ft-plus-trait
(define-public (mint (amt uint) (to principal))
  (begin
    (try! (check-owner))
    (ft-mint? lp-token amt to) ))

(define-public (burn (amt uint) (from principal))
  (begin
    (try! (check-owner))
    (ft-burn? lp-token amt from) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ft-trait
(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
  (begin
   (asserts! (is-eq tx-sender from) err-transfer)
   (ft-transfer? lp-token amt from to)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration Functions

(define-public (set-token-name (new-name (string-ascii 32)))
  (begin
    (asserts! (is-owner) err-unauthorized)
    (ok (var-set token-name new-name))))

(define-public (set-token-symbol (new-symbol (string-ascii 10)))
  (begin
    (asserts! (is-owner) err-unauthorized)
    (ok (var-set token-symbol new-symbol))))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-owner) err-unauthorized)
    (var-set token-uri new-uri)
    (ok (print { notification: "token-metadata-update", 
                 payload: { token-class: "ft", 
                           contract-id: contract }}))))

(define-public (set-decimals (new-decimals uint))
  (begin
    (asserts! (is-owner) err-unauthorized)
    (ok (var-set token-decimals new-decimals))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Functions

(define-read-only (get-name)                   (ok (var-get token-name)))
(define-read-only (get-symbol)                 (ok (var-get token-symbol)))
(define-read-only (get-decimals)               (ok (var-get token-decimals)))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)              (ok (var-get token-uri)))
(define-read-only (get-owner)                  (ok CONTRACT_OWNER))
```
