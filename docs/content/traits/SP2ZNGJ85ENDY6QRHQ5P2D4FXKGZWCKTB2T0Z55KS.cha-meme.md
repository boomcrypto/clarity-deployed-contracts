---
title: "Trait cha-meme"
draft: true
---
```
;; Charisma LP token

(impl-trait .dao-traits-v4.sip010-ft-trait)
(impl-trait .dao-traits-v4.ft-plus-trait)

;; No maximum supply
(define-fungible-token lp-token)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))

;; Configuration Variables
(define-data-var token-name (string-ascii 32) "Mecha Meme")
(define-data-var token-symbol (string-ascii 10) "MECHA")
(define-data-var token-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/sip10/cha-meme/metadata.json"))
(define-data-var token-decimals uint u6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-check-owner  (err u1))
(define-constant err-transfer     (err u2))
(define-constant err-unauthorized (err u401))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ownership
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller .univ2-core) err-check-owner)))

(define-private (is-deployer)
  (is-eq tx-sender DEPLOYER))

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
    (asserts! (is-deployer) err-unauthorized)
    (ok (var-set token-name new-name))))

(define-public (set-token-symbol (new-symbol (string-ascii 10)))
  (begin
    (asserts! (is-deployer) err-unauthorized)
    (ok (var-set token-symbol new-symbol))))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-deployer) err-unauthorized)
    (var-set token-uri new-uri)
    (ok (print {
      notification: "token-metadata-update", 
      payload: { token-class: "ft", contract-id: CONTRACT }
    }))))

(define-public (set-decimals (new-decimals uint))
  (begin
    (asserts! (is-deployer) err-unauthorized)
    (ok (var-set token-decimals new-decimals))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Functions

(define-read-only (get-name)                   (ok (var-get token-name)))
(define-read-only (get-symbol)                 (ok (var-get token-symbol)))
(define-read-only (get-decimals)               (ok (var-get token-decimals)))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)              (ok (var-get token-uri)))
(define-read-only (get-deployer)               (ok DEPLOYER))
```
