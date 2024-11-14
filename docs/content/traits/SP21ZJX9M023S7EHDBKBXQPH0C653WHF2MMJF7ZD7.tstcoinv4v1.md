---
title: "Trait tstcoinv4v1"
draft: true
---
```
;; fngble tkn smrt cntrct tmplt v1

;; community standard fungible token trait
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; error codes
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMS u400)
(define-constant ERR-NOT-ENOUGH-FUND u101)

;; token definites
(define-constant MAXSUPPLY u1)
(define-fungible-token tstcoinv4 MAXSUPPLY)
(define-data-var contract-owner principal tx-sender)

;; metadata
(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://QmbqqVpcziqgbajEmGJYLD671czuZhbUNVU4hFedTzjo5y"))
(define-data-var token-name (string-ascii 32) "tstcoinv4")
(define-data-var token-symbol (string-ascii 32) "TSTV4")
(define-data-var token-decimals uint u12)

;; public functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR-UNAUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-PARAMS))
    (asserts! (>= (ft-get-balance tstcoinv4 from) amount) (err ERR-NOT-ENOUGH-FUND))
    (asserts! (not (is-eq from to)) (err ERR-INVALID-PARAMS))
    (let ((result (ft-transfer? tstcoinv4 amount from to)))
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

(define-public
  (set-metadata
    (uri (optional (string-utf8 256)))
    (name (string-ascii 32))
    (symbol (string-ascii 32))
    (decimals uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
    (asserts!
      (and
        (is-some uri)
        (> (len name) u0)
        (> (len symbol) u0)
        (<= decimals u18))
      (err ERR-INVALID-PARAMS))
    (var-set token-uri uri)
    (var-set token-name name)
    (var-set token-symbol symbol)
    (var-set token-decimals decimals)
    (print
      {
        event: "token-metadata-update",
        uri: uri,
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
    (if (is-eq tx-sender (var-get contract-owner))
      (begin
        (var-set contract-owner new-owner)
        (ok "transfered ownership"))
      (err ERR-NOT-OWNER)))
)

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (begin
    (asserts! (<= (len recipients) u200) (err ERR-INVALID-PARAMS))
    (fold check-err (map send-token recipients) (ok true))
  )
)

;; private functions
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (begin
    (asserts! (> (get amount recipient) u0) (err ERR-INVALID-PARAMS))
    (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
  )
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; read-only functions
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance tstcoinv4 owner))
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
  (ok (ft-get-supply tstcoinv4))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; offclly coind!

(begin
  (let ((result (ft-mint? tstcoinv4 MAXSUPPLY (var-get contract-owner))))
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
