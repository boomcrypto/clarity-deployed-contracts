---
title: "Trait reap-stx-usda-token-v2-1"
draft: true
---
```
(impl-trait .trait-ownable.ownable-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))

(define-fungible-token reap-stx-usda-token)

(define-data-var contract-owner principal tx-sender)

(define-data-var token-name (string-ascii 32) "Reap STX-USDA Token")
(define-data-var token-symbol (string-ascii 10) "REAP_SU")
(define-data-var token-uri (optional (string-utf8 256)) (some u""))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved)
  (ok (asserts! (is-eq contract-caller .arkadiko-stx-usda-pool-v2-1) ERR-NOT-AUTHORIZED))
)

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-uri new-uri))
	)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin 
		(asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
		(ft-transfer? reap-stx-usda-token amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok u6)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance reap-stx-usda-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply reap-stx-usda-token))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-public (mint (amount uint) (recipient principal))
	(begin		
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-mint? reap-stx-usda-token amount recipient)
	)
)

(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-burn? reap-stx-usda-token amount sender)
	)
)

```
