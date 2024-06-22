---
title: "Trait contract-ZVNRnJom"
draft: true
---
```
;; Deploy with Foundry by Hashhavoc
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMS u400)
(define-constant ERR-NOT-ENOUGH-FUND u101)
(define-constant MAXSUPPLY u21000000)

(define-fungible-token Meatloaf MAXSUPPLY)

(define-data-var contract-owner principal tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) (some u""))
(define-data-var token-name (string-ascii 32) "Mom_Wheres_The_Meatloaf")
(define-data-var token-symbol (string-ascii 32) "Meatloaf")
(define-data-var token-decimals uint u5)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance Meatloaf owner))
)

(define-read-only (get-name)
  (ok "Mom_Wheres_The_Meatloaf")
)

(define-read-only (get-symbol)
  (ok "Meatloaf")
)

(define-read-only (get-decimals)
  (ok u5)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply Meatloaf))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))
        (ft-transfer? Meatloaf amount from to)
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
                (<= decimals u6))
            (err ERR-INVALID-PARAMS))
        (var-set token-uri uri)
        (var-set token-name name)
        (var-set token-symbol symbol)
        (var-set token-decimals decimals)
        (print
            {
                notification: "token-metadata-update",
                payload: {
                    token-class: "ft",
                    contract-id: (as-contract tx-sender)
                }
            })
(ok true)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

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
    (try! (stx-transfer? amount tx-sender (as-contract recipient)))
    (ok true)
  )
)

(begin
    (try! (ft-mint? Meatloaf MAXSUPPLY (var-get contract-owner)))
)
```
