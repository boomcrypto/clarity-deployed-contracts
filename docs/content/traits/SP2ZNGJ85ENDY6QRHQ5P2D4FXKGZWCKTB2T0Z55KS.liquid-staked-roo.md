---
title: "Trait liquid-staked-roo"
draft: true
---
```
;; Title: Liquid Staked Roo
;; Author: rozar.btc
;; Synopsis:
;; This contract implements a liquid staking solution for Roo.
;; It provides users with liquid tokens (sROO) that represent staked Roo. 
;; This allows users to retain liquidity while participating in staking.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.sip010-ft-trait.sip010-ft-trait)

(define-fungible-token liquid-staked-roo)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-data-var token-name (string-ascii 32) "Liquid Staked Roo")
(define-data-var token-symbol (string-ascii 10) "sROO")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/liquid-staked-roo.json"))
(define-data-var token-decimals uint u6)
(define-data-var contract-owner principal tx-sender)

;; --- Public functions

(define-public (is-owner)
	(ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-unauthorized))
)

(define-public (set-owner (new-owner principal))
	(begin
		(try! (is-owner))
		(ok (var-set contract-owner new-owner))
	)
)

(define-public (stake (amount uint))
	(begin
		(let
			(
				(inverse-rate (get-inverse-rate))
				(amount-lsr (/ (* amount inverse-rate) ONE_6))
				(sender tx-sender)
			)
			(try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer amount sender contract none))
			(try! (mint amount-lsr sender))
		)
		(ok true)
	)
)

(define-public (unstake (amount uint))
	(begin
		(let
			(
				(exchange-rate (get-exchange-rate))
				(amount-roo (/ (* amount exchange-rate) ONE_6))
				(sender tx-sender)
			)
			(try! (burn amount sender))
			(try! (as-contract (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer amount-roo contract sender none)))
		)
		(ok true)
	)
)

(define-public (deposit (amount uint))
    (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer amount tx-sender contract none)
)

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-owner))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-owner))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-owner))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-owner))
		(ok (var-set token-uri new-uri))
	)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? liquid-staked-roo amount sender recipient)
	)
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

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance liquid-staked-roo who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply liquid-staked-roo))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-read-only (get-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

(define-read-only (get-total-roo-in-pool)
	(unwrap-panic (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo get-balance contract))
)

(define-read-only (get-exchange-rate)
	(/ (* (get-total-roo-in-pool) ONE_6) (ft-get-supply liquid-staked-roo))
)

(define-read-only (get-inverse-rate)
	(/ (* (ft-get-supply liquid-staked-roo) ONE_6) (get-total-roo-in-pool))
)

;; --- Private functions

(define-private (mint (amount uint) (recipient principal))
    (ft-mint? liquid-staked-roo amount recipient)
)

(define-private (burn (amount uint) (owner principal))
    (ft-burn? liquid-staked-roo amount owner)
)

;; --- Init

(mint u1 contract)
```
