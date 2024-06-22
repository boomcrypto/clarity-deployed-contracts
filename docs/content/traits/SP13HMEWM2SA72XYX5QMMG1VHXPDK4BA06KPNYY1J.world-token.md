---
title: "Trait world-token"
draft: true
---
```
;; traits
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


;; token definition
(define-fungible-token world-token)

;; constants
(define-constant contract-owner tx-sender)
(define-constant init-dev-tax u200) ;; 0.5% dev tax

;; Errors
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-tax-not-lower (err u105))

;; data variables
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)
(define-data-var dev-tax uint u200)


;; public functions
;;
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
   (let (
           (tax-amount (/ amount (var-get dev-tax)))
           (amount-after-tax (- amount tax-amount))
       )
       (begin
           (asserts! (is-eq tx-sender sender) err-not-token-owner)
           ;; Check if the transaction sender is the dev wallet
           (if (is-eq tx-sender contract-owner)
               ;; Sender is the dev-wallet, so no tax
               (begin
                   (try! (ft-transfer? world-token amount tx-sender recipient))
                   (match memo to-print (print to-print) 0x)
                   (ok true)
               )
               ;; Send is not dev-wallet, so process with tax and transfer
               (begin
                   (try! (ft-transfer? world-token tax-amount tx-sender contract-owner))
                   ;; Transfer the remaining amount to the recipient
                   (try! (ft-transfer? world-token amount-after-tax tx-sender recipient))
                   (match memo to-print (print to-print) 0x)
                   (ok true)
               )
           )
       )
   )
)


(define-public (burn (amount uint) (sender principal))
   (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-burn? world-token amount sender))
        (ok true)
   )
)

(define-public (set-token-uri (value (string-utf8 256)))
   (begin
       (asserts! (is-eq tx-sender contract-owner) err-owner-only)
       (ok (var-set token-uri (some value)))
   )
)


(define-public (lower-tax (value uint))
   (begin
       (asserts! (is-eq tx-sender contract-owner) err-owner-only)
       (asserts! (> value init-dev-tax) err-tax-not-lower)
       (ok (var-set dev-tax value))
   )
)


;; read only functions
;;
(define-read-only (get-name)
   (ok "World Coin"))


(define-read-only (get-symbol)
   (ok "WORLD"))


(define-read-only (get-decimals)
   (ok u6))


(define-read-only (get-total-supply)
   (ok (ft-get-supply world-token)))


;; Get the token balance of the specified owner in base units
(define-read-only (get-balance (owner principal))
 (ok (ft-get-balance world-token owner)))


(define-read-only (get-token-uri)
   (ok (var-get token-uri)))


(define-read-only (get-contract-owner)
   (ok contract-owner)
)


;; INITIALIZATION
(begin
   (try! (ft-mint? world-token u12500000000000000 tx-sender)) ;; Mint initial supply to deployer's wallet
   (var-set total-supply u12500000000000000)
   (ok true)
)

```
