(impl-trait .proposal-trait.proposal-trait)

(define-constant ONE_8 (pow u10 u8))
(define-constant BANANA_TOTAL_TICKETS u500)
(define-constant BANANA_PARAMS 
	{ 
		ido-owner: 'SP3C4AYFGG8RAXHSA15W222YMVGDW6ND9V6T15Q6J,
		ido-tokens-per-ticket: u100,
		price-per-ticket-in-fixed: (* (/ (* u33 u100) u100) ONE_8), ;; 0.33 ALEX * 100 tokens per ticket = 33 ALEX
		activation-threshold: BANANA_TOTAL_TICKETS, ;; all or nothing
		registration-start-height: u52900,
		registration-end-height: u53950,
		claim-end-height: u55000,
		apower-per-ticket-in-fixed: 
			(list
				{ apower-per-ticket-in-fixed: (* u10 ONE_8), tier-threshold: u5 } 
				{ apower-per-ticket-in-fixed: (* u50 ONE_8), tier-threshold: u10 } 
				{ apower-per-ticket-in-fixed: (* u100 ONE_8), tier-threshold: u20 } 
				{ apower-per-ticket-in-fixed: (* u150 ONE_8), tier-threshold: u30 } 
				{ apower-per-ticket-in-fixed: (* u200 ONE_8), tier-threshold: u40 } 
				{ apower-per-ticket-in-fixed: (* u250 ONE_8), tier-threshold: u50 } 
			),
		registration-max-tickets: u50
	}
)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .alex-launchpad-v1-1 create-pool .token-wban .age000-governance-token BANANA_PARAMS))
		(try! (contract-call? .alex-launchpad-v1-1 add-approved-operator 'SP3N7Y3K01Y24G9JC1XXA13RQXXCY721WAVBMMD38))
		(ok true)
	)
)
