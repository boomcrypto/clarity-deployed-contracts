---
title: "Trait pontis-bridge-controller"
draft: true
---
```
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
(use-trait bridge-trait .bridge-trait.bridge-trait)

(define-data-var bridge-owner principal tx-sender)
(define-data-var latest-bridge-instance principal tx-sender)

(define-constant ERR-NOT-OWNER (err u200))
(define-constant ERR-NOT-AUTHORIZED (err u201))

(define-read-only (get-bridge-owner)
	(ok (var-get bridge-owner))
)

(define-read-only (get-latest-bridge-instance)
	(ok (var-get latest-bridge-instance))
)

(define-public (migrate-owner (owner principal))
	(begin
		(try! (authorize-bridge-owner))
		(ok (var-set bridge-owner owner))
	)
)

(define-public (migrate-bridge-instance (bridge <bridge-trait>))
	(begin
		(try! (authorize-bridge-owner))
		(ok (var-set latest-bridge-instance (contract-of bridge)))
	)
)

(define-public (authorize-bridge-owner)
	(ok (asserts! (is-eq tx-sender (var-get bridge-owner)) ERR-NOT-OWNER))
)

(define-public (withdraw-ft (token <ft-trait>) (recipient principal) (amount uint))
		(begin
			(try! (authorize-bridge-owner))
			(as-contract (contract-call? token transfer amount tx-sender recipient none))
		)
)

(define-public (withdrawal-stx (amount uint) (recipient principal))
		(begin
			(try! (authorize-bridge-owner))
			(as-contract (stx-transfer? amount tx-sender recipient))
		)
)

(define-public (authorize-bridge-instance)
	(ok (asserts! (is-eq tx-sender (var-get latest-bridge-instance)) ERR-NOT-AUTHORIZED))
)

(var-set latest-bridge-instance .pontis-bridge-v1)

```
