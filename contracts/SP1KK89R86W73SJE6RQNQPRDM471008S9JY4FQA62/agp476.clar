;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant OWNER 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8)
(define-constant LAUNCH_OWNER { address: (get hash-bytes (unwrap-panic (principal-destruct? OWNER))), chain-id: none })

(define-constant LAUNCH_TOKEN { address: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: (some u0) })
(define-constant PAYMENT_TOKEN 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc)

(define-constant PRICE_PER_TICKET u100) ;; 0.000001 BTC or $0.1

(define-constant REGISTRATION_PERIOD u144) ;; 1 day
(define-constant TOKENS_PER_TICKET u1100) ;; 0.000011 BTC or $1.1
(define-constant FEE_PER_TICKET u0)

(define-constant MAX_REGISTRATION u250)
(define-constant MAX_TICKETS u387)
(define-constant SUPPLY_TICKETS u387)

(define-constant WHITELIST (list
	{ owner: { address: 0x0055797647eA5aE4977bB8CB444E8D7ac1b20fB3, chain-id: (some u1) }, whitelisted: u250 }
	{ owner: { address: 0x321f7d116f980fac4415262e50f674effd5ff58d, chain-id: (some u2) }, whitelisted: u50 }
	{ owner: { address: (get hash-bytes (unwrap-panic (principal-destruct? 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ))), chain-id: none }, whitelisted: u50 }
	{ owner: { address: 0xf289bbc3207322bb5531b041540ad2119c01adc2, chain-id: (some u16) }, whitelisted: u25 }
	{ owner: { address: 0x0014aa6558c31522e6684369f4581481b259a39681ee, chain-id: (some u0) }, whitelisted: u12 }
))

(define-public (execute (sender principal))
	(let (
		(distribution-id (try! (contract-call? .alex-launchpad-v2-03d create-pool 
	{
		launch-token: LAUNCH_TOKEN,
		payment-token: PAYMENT_TOKEN,
		launch-owner: LAUNCH_OWNER,
		launch-tokens-per-ticket-in-fixed: TOKENS_PER_TICKET,
		price-per-ticket-in-fixed: PRICE_PER_TICKET,
		activation-threshold: u0,
		registration-start-height: (+ tenure-height u1),
		registration-end-height: (+ tenure-height u1 REGISTRATION_PERIOD),
		claim-end-height: (+ tenure-height u1 REGISTRATION_PERIOD REGISTRATION_PERIOD u1000),
		apower-per-ticket-in-fixed: (list { apower-per-ticket-in-fixed: u0, tier-threshold: MAX_UINT }),
		registration-max-tickets: MAX_REGISTRATION,
		fee-per-ticket-in-fixed: FEE_PER_TICKET,
		total-registration-max: MAX_TICKETS,
		memo: none
	}))))
(try! (contract-call? .alex-launchpad-v2-03d set-use-whitelist distribution-id true))
(try! (contract-call? .alex-launchpad-v2-03d set-whitelisted distribution-id WHITELIST))
(try! (contract-call? .alex-launchpad-v2-03d add-to-position distribution-id SUPPLY_TICKETS 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))			

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower add-approved-contract .alex-launchpad-v2-03d))

		(ok true)))

