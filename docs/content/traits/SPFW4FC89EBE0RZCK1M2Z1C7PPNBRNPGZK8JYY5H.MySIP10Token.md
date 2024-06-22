---
title: "Trait MySIP10Token"
draft: true
---
```
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; title: Mr.Beans
;; version:
;; summary:
;; description:

;; traits
;; token definitions
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-fungible-token my-new-token)

;; constants

;; data vars

;; data maps

;; public functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)  ;;Ensure only owner can mint
    (ft-mint? my-new-token amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)  ;;Ensure sender owns tokens
    (try! (ft-transfer? my-new-token amount sender recipient))  ;;Attempt transfer
    (match memo to-print (print to-print) 0x)  ;; Handle optional memo
    (ok true)  ;; Return success
  )
)

;; read only functions
(define-read-only (get-name)
  (ok "Mr.Beans")  ;; Return token name
)

(define-read-only (get-symbol)
  (ok "$MSTX")  ;; Return token symbol
)

(define-read-only (get-decimals)
  (ok u9)  ;; Return token decimals
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance my-new-token who))  ;; Get balance of an address
)

(define-read-only (get-total-supply)
  (ok u1000000000)  ;; Return total supply
)

(define-read-only (get-token-uri)
  (ok none)  ;; No token URI defined yet
)

;; private functions


```
