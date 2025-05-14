---
title: "Trait shrooms-token"
draft: true
---
```
;; SHROOMS Token - SIP-010 Fungible Token
;; Contract implements the SIP-010 standard for fungible tokens in Stacks
;; Version: Clarity 2.15
;;
;; "Big Shroom is Watching You"
;;
;; Constants
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))

;; Data
(define-fungible-token shrooms-token)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var contract-owner-address principal tx-sender)
(define-data-var is-initialized bool false)

;; Initialize token supply
(define-public (initialize-supply)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) ERR-OWNER-ONLY)
    (asserts! (not (var-get is-initialized)) (err u103)) ;; Can only be initialized once
    (try! (ft-mint? shrooms-token u123456789000000 (var-get contract-owner-address)))
    (var-set is-initialized true)
    (ok true)))

;; SIP-010 Standard Functions
;; Returns the token name
(define-read-only (get-name)
  (ok "SHROOMS"))

;; Returns the token symbol
(define-read-only (get-symbol)
  (ok "SHROOMS"))

;; Returns the number of decimals
(define-read-only (get-decimals)
  (ok u6))

;; Returns the token balance for a specified address
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance shrooms-token owner)))

;; Returns the total token supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply shrooms-token)))

;; Returns the token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;; Token transfer function
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-TOKEN-OWNER)
    (asserts! (>= (ft-get-balance shrooms-token sender) amount) ERR-INSUFFICIENT-BALANCE)
    (try! (ft-transfer? shrooms-token amount sender recipient))
    (match memo
      m (begin (print m) (ok true))
      (ok true))))

;; Function to send tokens to multiple recipients 
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold send-many-fold recipients (ok true)))

(define-private (send-many-fold (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }) (result (response bool uint)))
  (if (is-err result)
      result
      (transfer (get amount recipient) tx-sender (get to recipient) (get memo recipient))))

;; Token burn function
(define-public (burn (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) ERR-OWNER-ONLY)
    (try! (ft-burn? shrooms-token amount tx-sender))
    (ok true)))

;; Administrative functions
;; Change contract owner
(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) ERR-OWNER-ONLY)
    (var-set contract-owner-address new-owner)
    (ok true)))

;; Set token URI
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) ERR-OWNER-ONLY)
    (var-set token-uri new-uri)
    (ok true)))

;; Function to check if caller is owner
(define-read-only (is-owner (caller principal))
  (is-eq caller (var-get contract-owner-address)))

;; Function to get owner
(define-read-only (get-owner)
  (ok (var-get contract-owner-address)))

;; Function to check initialization status
(define-read-only (is-token-initialized)
  (ok (var-get is-initialized)))

;; Function to allow users to burn their own tokens
(define-public (burn-own (amount uint))
  (begin
    (asserts! (>= (ft-get-balance shrooms-token tx-sender) amount) ERR-INSUFFICIENT-BALANCE)
    (try! (ft-burn? shrooms-token amount tx-sender))
    (ok true)))

;; Additional safety functions
;; Allow owner to recover tokens sent to the contract by mistake
(define-public (recover-tokens (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) ERR-OWNER-ONLY)
    (asserts! (>= (ft-get-balance shrooms-token (as-contract tx-sender)) amount) ERR-INSUFFICIENT-BALANCE)
    (as-contract (try! (transfer amount (as-contract tx-sender) recipient none)))
    (ok true)))
```
