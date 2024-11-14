---
title: "Trait meta-bridge-registry-v2-01"
draft: true
---
```
(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-pair-not-found (err u1001))
(define-constant err-request-not-found (err u1002))
(define-data-var request-claim-grace-period uint u144)
(define-data-var request-revoke-grace-period uint u432)
(define-data-var request-nonce uint u0)
(define-map approved-peg-in-address (buff 128) bool)
(define-map approved-pairs 
	{ tick: (string-utf8 256), token: principal } 
	{ 
		approved: bool, 
		peg-in-paused: bool, 
		peg-out-paused: bool, 
		peg-in-fee: uint, 
		peg-out-fee: uint, 
		peg-out-gas-fee: uint,
		no-burn: bool
	})
(define-map requests uint {
	requested-by: principal,
	peg-out-address: (buff 128),
	tick: (string-utf8 256),
	token: principal,
	amount-net: uint,
	fee: uint,
	gas-fee: uint,
	claimed: uint,
	claimed-by: principal,
	fulfilled-by: (buff 128),
	revoked: bool,
	finalized: bool,
	requested-at: uint,
	requested-at-burn-height: uint})
(define-map peg-in-sent { tx: (buff 32768), output: uint, offset: uint } bool)
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised)))
(define-read-only (get-request-nonce)
	(var-get request-nonce))
(define-read-only (get-request-revoke-grace-period)
	(var-get request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(var-get request-claim-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(default-to false (map-get? approved-peg-in-address address)))
(define-read-only (get-pair-details-or-fail (pair { tick: (string-utf8 256), token: principal }))
	(ok (unwrap! (map-get? approved-pairs pair) err-pair-not-found)))
(define-read-only (is-approved-pair (pair { tick: (string-utf8 256), token: principal }))
	(match (get-pair-details-or-fail pair) ok-value (get approved ok-value) err-value false))
(define-read-only (get-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? requests request-id) err-request-not-found)))
(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 32768)) (output uint) (offset uint))
	(default-to false (map-get? peg-in-sent { tx: bitcoin-tx, output: output, offset: offset })))
(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set request-revoke-grace-period grace-period))))
(define-public (set-request-claim-grace-period (grace-period uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set request-claim-grace-period grace-period))))
(define-public (pause-peg-in (pair { tick: (string-utf8 256), token: principal }) (paused bool))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-paused: paused })))))
(define-public (pause-peg-out (pair { tick: (string-utf8 256), token: principal }) (paused bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-paused: paused })))))
(define-public (set-peg-in-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-in-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-fee: new-peg-in-fee })))))
(define-public (set-peg-out-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-out-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-fee: new-peg-out-fee })))))
(define-public (set-peg-out-gas-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-out-gas-fee uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-gas-fee: new-peg-out-gas-fee })))))
(define-public (set-token-no-burn (pair { tick: (string-utf8 256), token: principal }) (no-burn bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { no-burn: no-burn })))))
(define-public (approve-pair (pair { tick: (string-utf8 256), token: principal }) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (match (map-get? approved-pairs pair)
			token-details (map-set approved-pairs pair (merge token-details { approved: approved }))
			(map-set approved-pairs pair { approved: approved, peg-in-paused: true, peg-out-paused: true, peg-in-fee: u0, peg-out-fee: u0, peg-out-gas-fee: u0, no-burn: false })))))
(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-peg-in-address address approved))))
(define-public (set-peg-in-sent (peg-in-tx { tx: (buff 32768), output: uint, offset: uint }) (sent bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set peg-in-sent peg-in-tx sent))))
(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), tick: (string-utf8 256), token: principal, amount-net: uint, fee: uint, gas-fee: uint, claimed: uint, claimed-by: principal, fulfilled-by: (buff 128), revoked: bool, finalized: bool, requested-at: uint, requested-at-burn-height: uint}))
	(let (
			(id (if (is-some (map-get? requests request-id)) request-id (begin (var-set request-nonce (+ (var-get request-nonce) u1)) (var-get request-nonce)))))
		(try! (is-dao-or-extension))
		(map-set requests id details)
		(ok id)))
		
```
