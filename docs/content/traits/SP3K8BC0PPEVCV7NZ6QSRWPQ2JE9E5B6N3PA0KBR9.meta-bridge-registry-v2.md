---
title: "Trait meta-bridge-registry-v2"
draft: true
---
```
(use-trait sip010-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-pair-not-found (err u1001))
(define-constant err-request-not-found (err u1002))
(define-data-var contract-owner principal tx-sender)
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
(define-data-var request-nonce uint u10000)
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
(define-public (set-contract-owner-legacy (new-owner principal))
	(begin 
		(try! (is-contract-owner))
		(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-contract-owner new-owner))))
(define-public (approve-operator (operator principal) (approved bool))
	(begin
		(try! (is-contract-owner))
		(as-contract (contract-call? .brc20-bridge-registry-v1-03 approve-operator operator approved))))
(define-public (set-request-nonce (new-nonce uint))
	(begin 
		(try! (is-contract-owner))
		(ok (var-set request-nonce new-nonce))))
(define-public (set-request-revoke-grace-period (grace-period uint))
	(begin
		(try! (is-contract-owner))
		(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-request-revoke-grace-period grace-period))))
(define-public (set-request-claim-grace-period (grace-period uint))
	(begin
		(try! (is-contract-owner))
		(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-request-claim-grace-period grace-period))))
(define-public (pause-peg-in (pair { tick: (string-utf8 256), token: principal }) (paused bool))
	(begin 
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 pause-peg-in (unwrap-panic (as-max-len? (get tick pair) u4)) paused))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-paused: paused }))))))
(define-public (pause-peg-out (pair { tick: (string-utf8 256), token: principal }) (paused bool))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 pause-peg-out (unwrap-panic (as-max-len? (get tick pair) u4)) paused))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-paused: paused }))))))		
(define-public (set-peg-in-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-in-fee uint))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-peg-in-fee (unwrap-panic (as-max-len? (get tick pair) u4)) new-peg-in-fee))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-in-fee: new-peg-in-fee }))))))
(define-public (set-peg-out-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-out-fee uint))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-peg-out-fee (unwrap-panic (as-max-len? (get tick pair) u4)) new-peg-out-fee))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-fee: new-peg-out-fee }))))))
(define-public (set-peg-out-gas-fee (pair { tick: (string-utf8 256), token: principal }) (new-peg-out-gas-fee uint))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-peg-out-gas-fee (unwrap-panic (as-max-len? (get tick pair) u4)) new-peg-out-gas-fee))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { peg-out-gas-fee: new-peg-out-gas-fee }))))))
(define-public (set-token-no-burn (pair { tick: (string-utf8 256), token: principal }) (no-burn bool))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 set-token-no-burn (unwrap-panic (as-max-len? (get tick pair) u4)) no-burn))
			(ok (map-set approved-pairs pair (merge (try! (get-pair-details-or-fail pair)) { no-burn: no-burn }))))))
(define-public (approve-pair (pair { tick: (string-utf8 256), token: principal }) (approved bool))
	(begin
		(try! (is-contract-owner))
		(if (is-legacy-brc20-pair pair)
			(as-contract (contract-call? .brc20-bridge-registry-v1-03 approve-token (unwrap-panic (as-max-len? (get tick pair) u4)) (get token pair) approved))
			(ok
				(match (map-get? approved-pairs pair)
					token-details (map-set approved-pairs pair (merge token-details { approved: approved }))
					(map-set approved-pairs pair { approved: approved, peg-in-paused: true, peg-out-paused: true, peg-in-fee: u0, peg-out-fee: u0, peg-out-gas-fee: u0, no-burn: false }))))))			
(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-contract-owner))
		(as-contract (contract-call? .brc20-bridge-registry-v1-03 approve-peg-in-address address approved))))
(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(ok (var-set contract-owner new-contract-owner))))
(define-read-only (get-request-nonce)
	(var-get request-nonce))
(define-read-only (is-legacy-brc20-pair (pair { tick: (string-utf8 256), token: principal }))
	(match (contract-call? .brc20-bridge-registry-v1-03 get-token-to-tick-or-fail (get token pair))
		ok-value (is-eq ok-value (get tick pair))
		err-value false))
(define-read-only (get-request-revoke-grace-period)
	(contract-call? .brc20-bridge-registry-v1-03 get-request-revoke-grace-period))
(define-read-only (get-request-claim-grace-period)
	(contract-call? .brc20-bridge-registry-v1-03 get-request-claim-grace-period))
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(contract-call? .brc20-bridge-registry-v1-03 is-peg-in-address-approved address))
(define-read-only (get-pair-details-or-fail (pair { tick: (string-utf8 256), token: principal }))
	(if (is-legacy-brc20-pair pair)
		(let (
				(token-details (try! (contract-call? .brc20-bridge-registry-v1-03 get-token-details-or-fail (unwrap-panic (as-max-len? (get tick pair) u4))))))
				(ok { 
					approved: (get approved token-details),
					peg-in-paused: (get peg-in-paused token-details),
					peg-out-paused: (get peg-out-paused token-details),
					peg-in-fee: (get peg-in-fee token-details),
					peg-out-fee: (get peg-out-fee token-details),
					peg-out-gas-fee: (get peg-out-gas-fee token-details),
					no-burn: (get no-burn token-details)
				}))
		(ok (unwrap! (map-get? approved-pairs pair) err-pair-not-found))))
(define-read-only (is-approved-pair (pair { tick: (string-utf8 256), token: principal }))
	(if (is-legacy-brc20-pair pair)	
		(contract-call? .brc20-bridge-registry-v1-03 is-approved-token (unwrap-panic (as-max-len? (get tick pair) u4)))
		(match (get-pair-details-or-fail pair) ok-value (get approved ok-value) err-value false)))
(define-read-only (get-request-or-fail (request-id uint))
	(match (contract-call? .brc20-bridge-registry-v1-03 get-request-or-fail request-id)
		ok-value (ok (merge ok-value { token: (get token (try! (contract-call? .brc20-bridge-registry-v1-03 get-token-details-or-fail (get tick ok-value)))) }))
		err-value (ok (unwrap! (map-get? requests request-id) err-request-not-found))))
(define-read-only (get-approved-operator-or-default (operator principal))
	(contract-call? .brc20-bridge-registry-v1-03 get-approved-operator-or-default operator))
(define-read-only (get-peg-in-sent-or-default (bitcoin-tx (buff 8192)) (output uint) (offset uint))
	(contract-call? .brc20-bridge-registry-v1-03 get-peg-in-sent-or-default bitcoin-tx output offset))
(define-read-only (is-approved-operator)
	(contract-call? .brc20-bridge-registry-v1-03 is-approved-operator))
(define-public (set-peg-in-sent (peg-in-tx { tx: (buff 8192), output: uint, offset: uint }) (sent bool))
	(begin
		(try! (is-approved-operator))
		(contract-call? .brc20-bridge-registry-v1-03 set-peg-in-sent peg-in-tx sent)))
(define-public (set-request (request-id uint) (details { requested-by: principal, peg-out-address: (buff 128), tick: (string-utf8 256), token: principal, amount-net: uint, fee: uint, gas-fee: uint, claimed: uint, claimed-by: principal, fulfilled-by: (buff 128), revoked: bool, finalized: bool, requested-at: uint, requested-at-burn-height: uint}))
	(begin
		(try! (is-approved-operator))
		(if (is-ok (contract-call? .brc20-bridge-registry-v1-03 get-request-or-fail request-id))
			(contract-call? .brc20-bridge-registry-v1-03 set-request request-id 
				{ 
					requested-by: (get requested-by details), 
					peg-out-address: (get peg-out-address details), 
					tick: (unwrap-panic (as-max-len? (get tick details) u4)), 
					amount-net: (get amount-net details), 
					fee: (get fee details), 
					gas-fee: (get gas-fee details), 
					claimed: (get claimed details), 
					claimed-by: (get claimed-by details), 
					fulfilled-by: (get fulfilled-by details), 
					revoked: (get revoked details), 
					finalized: (get finalized details), 
					requested-at: (get requested-at details), 
					requested-at-burn-height: (get requested-at-burn-height details) })
			(let (
					(id (if (is-some (map-get? requests request-id)) request-id (begin (var-set request-nonce (+ (var-get request-nonce) u1)) (var-get request-nonce)))))
				(map-set requests id details)
				(ok id)))))		
		
(define-private (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) tx-sender) err-unauthorised)))
```
