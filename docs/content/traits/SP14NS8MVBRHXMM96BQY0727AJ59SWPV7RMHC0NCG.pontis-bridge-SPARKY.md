---
title: "Trait pontis-bridge-SPARKY"
draft: true
---
```
(impl-trait .trait-ownable.ownable-trait)
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .bridge-ft-trait.bridge-ft-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-SAME-OWNER (err u1001))

(define-fungible-token bridge-token)

(define-data-var contract-owner principal tx-sender)
(define-data-var proposed-owner principal tx-sender)

(define-data-var token-name (string-ascii 32) "SPARKY.RUNEDOG")
(define-data-var token-symbol (string-ascii 10) "SPARKY")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://ipfs.io/ipfs/QmNiM8fumGobVKyYESxgaUQixryWkbgDz6vK9tZfKP1wHg"))
;; 840000:357
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)

(define-public (propose-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set proposed-owner owner))
	)
)

(define-public (claim-ownership)
	(begin
		(asserts! (not (is-eq (var-get contract-owner) (var-get proposed-owner))) ERR-SAME-OWNER)
		(try! (check-is-proposed-owner))
		(ok (var-set contract-owner tx-sender))
	)
)

(define-private (check-is-owner)
	(ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-proposed-owner)
	(ok (asserts! (is-eq contract-caller (var-get proposed-owner)) ERR-NOT-AUTHORIZED))
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
		(ft-transfer? bridge-token amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok u0)
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance bridge-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply bridge-token))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-public (mint (amount uint) (recipient principal))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-instance))
		(ft-mint? bridge-token amount recipient)
	)
)

(define-public (burn (amount uint) (sender principal))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-instance))
		(ft-burn? bridge-token amount sender)
	)
)
```
