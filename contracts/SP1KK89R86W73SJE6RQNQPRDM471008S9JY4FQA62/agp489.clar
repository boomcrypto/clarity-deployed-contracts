;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant MAX_TICKETS u80000)
(define-constant SUPPLY_TICKETS u80000)

(define-constant LAUNCH_ID u2)

(define-public (execute (sender principal))
	(let (
		(pool-details (try! (contract-call? .alex-launchpad-v2-03f get-launch-or-fail LAUNCH_ID))))
(try! (contract-call? .alex-launchpad-v2-03f update-pool LAUNCH_ID
	{
		launch-token: (get launch-token pool-details),
		payment-token: (get payment-token pool-details),
		launch-owner: (get launch-owner pool-details),
		launch-tokens-per-ticket-in-fixed: (get launch-tokens-per-ticket-in-fixed pool-details),
		price-per-ticket-in-fixed: (get price-per-ticket-in-fixed pool-details),
		activation-threshold: (get activation-threshold pool-details),
		registration-start-height: (get registration-start-height pool-details),
		registration-end-height: (get registration-end-height pool-details),
		total-tickets: (get total-tickets pool-details),
		claim-end-height: (get claim-end-height pool-details),
		apower-per-ticket-in-fixed: (get apower-per-ticket-in-fixed pool-details),
		registration-max-tickets: (get registration-max-tickets pool-details),
		fee-per-ticket-in-fixed: (get fee-per-ticket-in-fixed pool-details),
		total-registration-max: MAX_TICKETS,
		memo: (get memo pool-details),
		max-size-factor: (get max-size-factor pool-details)
	}))
(try! (contract-call? .alex-launchpad-v2-03f add-to-position LAUNCH_ID (- SUPPLY_TICKETS (get total-tickets pool-details)) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))			

(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v3a approve-token-x 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc true u1000000))
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v3a approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u1000000))
		(ok true)))
