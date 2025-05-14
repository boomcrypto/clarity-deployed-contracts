---
title: "Trait zusdh-token"
draft: true
---
```
(use-trait ft .ft-mint-trait.ft-mint-trait)
(use-trait sip10 .ft-trait.ft-trait)

(impl-trait .ownable-trait.ownable-trait)

(define-constant ERR_UNAUTHORIZED (err u14402))

(define-constant one-8 u100000000)

(define-fungible-token zusdh)

(define-data-var token-uri (string-utf8 256) u"https://token-meta.s3.eu-central-1.amazonaws.com/zUSDh.json")
(define-data-var token-name (string-ascii 32) "Zest USDh")
(define-data-var token-symbol (string-ascii 32) "zUSDh")

(define-constant decimals u8)

(define-read-only (get-total-supply)
  (ok (ft-get-supply zusdh)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok decimals))

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri))))

(define-read-only (get-balance (account principal))
  (ft-get-balance zusdh account)
)

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-uri value))))

(define-public (set-token-name (value (string-ascii 32)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-name value))))

(define-public (set-token-symbol (value (string-ascii 32)))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (var-set token-symbol value))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (is-approved-contract contract-caller))
    (transfer-internal amount sender recipient none)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (mint-internal amount recipient)
  )
)

(define-public (burn (amount uint) (owner principal))
  (begin
    (try! (is-approved-contract contract-caller))
    (burn-internal amount owner)
  )
)

(define-private (transfer-internal (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (match (ft-transfer? zusdh amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-private (mint-internal (amount uint) (owner principal))
  (ft-mint? zusdh amount owner)
)

(define-private (burn-internal (amount uint) (owner principal))
  (ft-burn? zusdh amount owner)
)

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-zusdh", payload: owner })
    (ok (var-set contract-owner owner))))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))
  )
)

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

```
