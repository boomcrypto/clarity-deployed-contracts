---
title: "Trait agp461"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(let (
			(launch-id (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c create-pool 
	{
		launch-token: { address: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry, chain-id: (some u1002) },
		payment-token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc,
		launch-owner: { address: 0x1d295335a342f39313dcb30b764140d39d68aedf, chain-id: none },
		launch-tokens-per-ticket: u1000,
		price-per-ticket-in-fixed: u6000,
		activation-threshold: u0,
		registration-start-height: (+ tenure-height u1),
		registration-end-height: (+ tenure-height u1 u36),
		claim-end-height: (+ tenure-height u1 u144 u144),
		apower-per-ticket-in-fixed: (list { apower-per-ticket-in-fixed: u0, tier-threshold: MAX_UINT }),
		registration-max-tickets: u5,
		fee-per-ticket-in-fixed: u0,
		total-registration-max: MAX_UINT,
		memo: none
	}))))

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03c add-to-position launch-id u5 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry))			

		(ok true)))


```
