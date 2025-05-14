---
title: "Trait agp433"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(let (
(launch-id (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03 create-pool 
	'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry 
	'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc
	{
		launch-owner: { address: 0x5120e5e81ad6367d947e5f32b83b77a53752d54668306ca57306595f5315808960c1, chain-id: (some u0) },
		launch-tokens-per-ticket: u1000,
		price-per-ticket-in-fixed: u600,
		activation-threshold: u0,
		registration-start-height: u181581,
		registration-end-height: u181725,
		claim-end-height: u181869,
		apower-per-ticket-in-fixed: (list { apower-per-ticket-in-fixed: u0, tier-threshold: MAX_UINT }),
		registration-max-tickets: u1,
		fee-per-ticket-in-fixed: u0,
		total-registration-max: u20,
		memo: none
	}))))
	(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.alex-launchpad-v2-03 add-to-position launch-id u20 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-hungry))
		(ok true)))



```
