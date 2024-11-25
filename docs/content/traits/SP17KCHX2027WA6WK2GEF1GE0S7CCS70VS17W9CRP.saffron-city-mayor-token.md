---
title: "Trait saffron-city-mayor-token"
draft: true
---
```
;; SIP10 Token Contract by AIBTC

;; Errors
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMS u400)
(define-constant ERR-NOT-ENOUGH-FUND u101)

;; SIP-010 Trait Implementation
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant MAXSUPPLY u69420000000000)

;; Variables
(define-fungible-token SCM MAXSUPPLY)
(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://example.com/scm"))
(define-data-var token-name (string-ascii 32) "Saffron City Mayor Token")
(define-data-var token-symbol (string-ascii 32) "SCM")
(define-data-var token-decimals uint u6)

;; Read-Only Functions
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance SCM owner))
)

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply SCM))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; Public Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-PARAMS))
    (asserts! (>= (ft-get-balance SCM from) amount) (err ERR-NOT-ENOUGH-FUND))
    (asserts! (not (is-eq from to)) (err ERR-INVALID-PARAMS))
    (let ((result (ft-transfer? SCM amount from to)))
      (print
        {
          event: "transfer",
          from: from,
          to: to,
          amount: amount,
          memo: memo
        }
      )
      result
    )
  )
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
    (var-set token-uri (some uri))
    (print
      {
        event: "token-metadata-update",
        uri: uri
      }
    )
    (ok true)
  )
)

(define-public (set-metadata (name (string-ascii 32)) (symbol (string-ascii 32)) (decimals uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
    (asserts! (> (len name) u0) (err ERR-INVALID-PARAMS))
    (asserts! (> (len symbol) u0) (err ERR-INVALID-PARAMS))
    (asserts! (<= decimals u18) (err ERR-INVALID-PARAMS))
    (var-set token-name name)
    (var-set token-symbol symbol)
    (var-set token-decimals decimals)
    (print
      {
        event: "token-metadata-update",
        name: name,
        symbol: symbol,
        decimals: decimals
      }
    )
    (ok true)
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-NOT-OWNER))
    (var-set contract-owner new-owner)
    (print
      {
        event: "ownership-transfer",
        new-owner: new-owner
      }
    )
    (ok true)
  )
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (begin
    (asserts! (<= (len recipients) u200) (err ERR-INVALID-PARAMS))
    (fold check-err (map send-token recipients) (ok true))
  )
)

;; Private Functions
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-INVALID-PARAMS))
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true)
  )
)

;; Mint Tokens
(begin
  (let ((result (ft-mint? SCM MAXSUPPLY (var-get contract-owner))))
    (print
      {
        event: "mint",
        to: (var-get contract-owner),
        amount: MAXSUPPLY
      }
    )
    result
  )
)

```
