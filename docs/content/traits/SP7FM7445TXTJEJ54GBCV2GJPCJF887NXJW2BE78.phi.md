---
title: "Trait phi"
draft: true
---
```
;; title: PHI
;; version: 1.0.0
;; summary: $PHI is a fungible token with a fixed supply for funding R&D and community-driven initiatives.
;; description: The PHI token is designed to support decentralized applications by providing a standardized unit of value for transactions within its ecosystem. It is specifically intended for use in the Sphinx DANA. The token has 8 decimals, a total supply of 7,777,777, and the smallest unit is called an 'OXY'. This contract follows the SIP-010 standard without external imports.

(define-trait sip-010-trait
    (
        ;; Read-only functions
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-decimals () (response uint uint))
        (get-symbol () (response (string-ascii 12) uint))
        (get-name () (response (string-ascii 32) uint))
        (get-token-uri () (response (optional (string-ascii 256)) uint))
        
        ;; Public functions
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (mint (uint principal) (response bool uint))
    )
)

(define-fungible-token phi)

;; Error Constants
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_INVALID_RECIPIENT (err u103))
(define-constant ERR_MAX_SUPPLY_EXCEEDED (err u104))
(define-constant ERR_INVALID_OWNER (err u105))

;; Contract Variables and Constants
(define-data-var contract-owner principal tx-sender)
(define-data-var total-minted uint u0)
(define-constant TOKEN_URI u"https://cyan-rational-cuckoo-19.mypinata.cloud/ipfs/QmTvJFrHc9AB4rPNkVD64tYJx1pdwMhDX45K3RL29cg2ww")
(define-constant TOKEN_NAME "PHI")
(define-constant TOKEN_SYMBOL "PHI")
(define-constant TOKEN_DECIMALS u8)
(define-constant MAX_SUPPLY u777777777777777)
(define-constant BURN_ADDRESS 'SP000000000000000000002Q6VF78)

;; Read-Only Functions
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance phi who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply phi))
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-token-uri)
  (ok (some TOKEN_URI))
)

;; Public Functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-eq recipient BURN_ADDRESS)) ERR_INVALID_RECIPIENT)
    (let (
      (current-minted (var-get total-minted))
      (new-total (+ current-minted amount))
    )
      (asserts! (<= new-total MAX_SUPPLY) ERR_MAX_SUPPLY_EXCEEDED)
      (try! (ft-mint? phi amount recipient))
      (var-set total-minted new-total)
      (ok true)
    )
  )
)

(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) 
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER) 
    (asserts! (not (is-eq recipient BURN_ADDRESS)) ERR_INVALID_RECIPIENT) 
    (try! (ft-transfer? phi amount sender recipient))
    (ok true)
  )
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_OWNER_ONLY)
    (asserts! (not (is-eq new-owner BURN_ADDRESS)) ERR_INVALID_OWNER)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Contract Initialization
(begin
    (try! (ft-mint? phi MAX_SUPPLY tx-sender))
    (var-set total-minted MAX_SUPPLY)
)

```
