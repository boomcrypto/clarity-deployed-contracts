---
title: "Trait agp463"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant OWNER 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8)
(define-constant LAUNCH_OWNER { address: (get hash-bytes (unwrap-panic (principal-destruct? OWNER))), chain-id: none })

(define-constant LAUNCH_TOKEN { address: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-mineticket, chain-id: (some u1002) })
(define-constant PAYMENT_TOKEN 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)

(define-constant PRICE_PER_TICKET u61175)

(define-constant REGISTRATION_PERIOD u432)
(define-constant TOKENS_PER_TICKET u2941)
(define-constant FEE_PER_TICKET u5000000)

(define-constant COMMUNITY_MAX_REGISTRATION u20)
(define-constant COMMUNITY_MAX_TICKETS u700)
(define-constant COMMUNITY_SUPPLY_TICKETS u700)

(define-constant OPEN_MAX_REGISTRATION u1300)
(define-constant OPEN_MAX_TICKETS MAX_UINT)	
(define-constant OPEN_SUPPLY_TICKETS u1300)

(define-constant COMMUNITY_APOWER_PER_TICKET (list
			{ apower-per-ticket-in-fixed: (* u10 ONE_8), tier-threshold: u2 } 
			{ apower-per-ticket-in-fixed: (* u50 ONE_8), tier-threshold: u2 } 
			{ apower-per-ticket-in-fixed: (* u100 ONE_8), tier-threshold: u2 } 
			{ apower-per-ticket-in-fixed: (* u200 ONE_8), tier-threshold: u2 } 
			{ apower-per-ticket-in-fixed: (* u300 ONE_8), tier-threshold: MAX_UINT } 
		))

(define-constant OPEN_APOWER_PER_TICKET (list { apower-per-ticket-in-fixed: u0, tier-threshold: MAX_UINT }))

(define-public (execute (sender principal))
	(let (
		(community-id (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c create-pool 
	{
		launch-token: LAUNCH_TOKEN,
		payment-token: PAYMENT_TOKEN,
		launch-owner: LAUNCH_OWNER,
		launch-tokens-per-ticket: TOKENS_PER_TICKET,
		price-per-ticket-in-fixed: PRICE_PER_TICKET,
		activation-threshold: u0,
		registration-start-height: (+ tenure-height u1),
		registration-end-height: (+ tenure-height u1 REGISTRATION_PERIOD),
		claim-end-height: (+ tenure-height u1 REGISTRATION_PERIOD REGISTRATION_PERIOD u1000),
		apower-per-ticket-in-fixed: COMMUNITY_APOWER_PER_TICKET,
		registration-max-tickets: COMMUNITY_MAX_REGISTRATION,
		fee-per-ticket-in-fixed: FEE_PER_TICKET,
		total-registration-max: COMMUNITY_MAX_TICKETS,
		memo: none
	})))
		(open-id (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c create-pool 
	{
		launch-token: LAUNCH_TOKEN,
		payment-token: PAYMENT_TOKEN,
		launch-owner: LAUNCH_OWNER,
		launch-tokens-per-ticket: TOKENS_PER_TICKET,
		price-per-ticket-in-fixed: PRICE_PER_TICKET,
		activation-threshold: u0,
		registration-start-height: (+ tenure-height u1),
		registration-end-height: (+ tenure-height u1 REGISTRATION_PERIOD),
		claim-end-height: (+ tenure-height u1 REGISTRATION_PERIOD REGISTRATION_PERIOD u1000),
		apower-per-ticket-in-fixed: OPEN_APOWER_PER_TICKET,
		registration-max-tickets: OPEN_MAX_REGISTRATION,
		fee-per-ticket-in-fixed: FEE_PER_TICKET,
		total-registration-max: OPEN_MAX_TICKETS,
		memo: none
	}))))	

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c add-to-position community-id COMMUNITY_SUPPLY_TICKETS 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-mineticket))			
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c add-to-position open-id OPEN_SUPPLY_TICKETS 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-mineticket))			
		(ok true)))


```
