---
title: "Trait memegoat-vault"
draft: true
---
```
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-semi-fungible.semi-fungible-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-INVALID-BALANCE (err u1002))
(define-constant ERR-INVALID-TOKEN (err u2026))
(define-constant ERR-AMOUNT-EXCEED-RESERVE (err u2024))

;; STORAGE
(define-map approved-tokens principal bool)
(define-data-var paused bool false)

;; READ ONLY CALLS
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

(define-read-only (is-paused)
	(var-get paused)
)

;; DAO CALLS
(define-public (pause (new-paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set paused new-paused))
  )
)

(define-public (set-approval-status (token-trait principal) (id uint) (status bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-tokens token-trait status))
  )
)

(define-public (transfer-ft (token-trait <ft-trait>) (amount uint) (recipient principal))
	(begin
		(asserts! (not (is-paused)) ERR-PAUSED)
		(asserts! (and (is-ok (is-dao-or-extension)) (is-ok (check-is-approved-token (contract-of token-trait)))) ERR-NOT-AUTHORIZED)
		(as-contract (contract-call? token-trait transfer amount tx-sender recipient none))
  )
)

(define-public (transfer-ft-two (token-x-trait <ft-trait>) (dx uint) (token-y-trait <ft-trait>) (dy uint) (recipient principal))
	(begin
		(try! (transfer-ft token-x-trait dx recipient))
		(transfer-ft token-y-trait dy recipient)
  )
)

(define-public (transfer-sft (token-trait <sft-trait>) (token-id uint) (amount uint) (recipient principal))
	(begin
		(asserts! (not (is-paused)) ERR-PAUSED)
		(asserts! (and (is-ok (is-dao-or-extension)) (is-ok (check-is-approved-token (contract-of token-trait)))) ERR-NOT-AUTHORIZED)
		(as-contract (contract-call? token-trait transfer token-id amount tx-sender recipient))
  )
)

(define-private (check-is-approved-token (token principal))
	(ok (asserts! (default-to false (map-get? approved-tokens token)) ERR-NOT-AUTHORIZED))
)
```
