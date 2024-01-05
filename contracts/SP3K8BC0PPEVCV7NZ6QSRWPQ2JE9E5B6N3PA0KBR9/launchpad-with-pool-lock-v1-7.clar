(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)
(define-constant err-unknown-launch (err u2045))
(define-constant err-block-height-not-reached (err u2042))
(define-constant err-not-authorized (err u1000))
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-map locked uint { launch-owner: principal, pct: uint, period: uint, pool-id: uint })
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))
	)
)
(define-public (create-pool
	(launch-token-trait <ft-trait>)
	(payment-token-trait <ft-trait>)
	(offering
		{
		launch-owner: principal,
		launch-tokens-per-ticket: uint,
		price-per-ticket-in-fixed: uint,
		activation-threshold: uint,
		registration-start-height: uint,
		registration-end-height: uint,
		claim-end-height: uint,
		apower-per-ticket-in-fixed: (list 6 {apower-per-ticket-in-fixed: uint, tier-threshold: uint}),
		registration-max-tickets: uint,
		fee-per-ticket-in-fixed: uint,
		total-registration-max: uint
		})
	(locked-params { pct: uint, period: uint })
	)
	(let 
		(
			(launch-id (try! (contract-call? .alex-launchpad-v1-7 create-pool launch-token-trait payment-token-trait (merge offering { launch-owner: (as-contract tx-sender) }))))
		)
		(try! (contract-call? .alex-vault-v1-1 set-approved-token (contract-of launch-token-trait) true))
		(try! (contract-call? .alex-vault-v1-1 set-approved-token (contract-of payment-token-trait) true))
		(map-set locked launch-id (merge locked-params { launch-owner: (get launch-owner offering), pool-id: u0 }))
		(ok launch-id)
	)
)
(define-public (transfer-all-to-owner (token-trait <ft-trait>))
	(let 
		(
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender))))
		)
		(try! (check-is-owner))
		(ok (and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed balance tx-sender (var-get contract-owner) none)))))
	)
)
(define-public (transfer-all-semi-to-owner (token-trait <sft-trait>) (token-id uint))
	(let 
		(
			(balance (try! (contract-call? token-trait get-balance-fixed token-id (as-contract tx-sender))))
		)
		(try! (check-is-owner))		
		(ok (and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed token-id balance tx-sender (var-get contract-owner))))))
	)
)
(define-public (add-to-position (launch-id uint) (tickets uint) (launch-token-trait <ft-trait>))
	(let
		(
			(offering (try! (get-launch-or-fail launch-id)))
			(locked-details (unwrap! (get-locked-details launch-id) err-unknown-launch))
		)
		(asserts! (or (is-eq (get launch-owner locked-details) tx-sender) (is-ok (check-is-owner))) err-not-authorized)		
		(try! (contract-call? launch-token-trait transfer-fixed (* (get launch-tokens-per-ticket offering) tickets ONE_8) tx-sender (as-contract tx-sender) none))
		(as-contract (try! (contract-call? .alex-launchpad-v1-7 add-to-position launch-id tickets launch-token-trait)))
		(contract-call? launch-token-trait transfer-fixed (mul-down (* (get launch-tokens-per-ticket offering) tickets ONE_8) (get pct locked-details)) tx-sender (as-contract tx-sender) none)
	)
)
(define-read-only (get-launch-or-fail (launch-id uint))
	(contract-call? .alex-launchpad-v1-7 get-launch-or-fail launch-id))
(define-read-only (get-locked-details (launch-id uint))
	(map-get? locked launch-id)
)
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)
(define-public (claim (launch-id uint) (input (list 200 principal)) (launch-token-trait <ft-trait>) (payment-token-trait <ft-trait>))
	(let 
		(
			(offering (try! (get-launch-or-fail launch-id)))
			(launch-token (get launch-token offering))
			(payment-token (get payment-token offering))
			(locked-details (unwrap! (get-locked-details launch-id) err-unknown-launch))
			(launch-token-amount (* (get launch-tokens-per-ticket offering) (len input) (get pct locked-details)))
			(fee-per-ticket (mul-down (get price-per-ticket-in-fixed offering) (get fee-per-ticket-in-fixed offering)))
			(net-price-per-ticket (- (get price-per-ticket-in-fixed offering) fee-per-ticket))
			(payment-token-amount (mul-down (* net-price-per-ticket (len input)) (get pct locked-details)))
		)
		(try! (contract-call? .alex-launchpad-v1-7 claim launch-id input launch-token-trait payment-token-trait))
		(if (is-some (contract-call? .amm-swap-pool-v1-1 get-pool-exists payment-token launch-token ONE_8))
			(begin 
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 add-to-position payment-token-trait launch-token-trait ONE_8 payment-token-amount (some launch-token-amount))))
				true
			)
			(let
				(
					(pool-created (as-contract (try! (contract-call? .amm-swap-pool-v1-1 create-pool payment-token-trait launch-token-trait ONE_8 tx-sender payment-token-amount launch-token-amount))))
					(pool-details (unwrap-panic (contract-call? .amm-swap-pool-v1-1 get-pool-exists payment-token launch-token ONE_8)))
				)
				
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-fee-rate-x payment-token launch-token ONE_8 u500000)))
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-fee-rate-y payment-token launch-token ONE_8 u500000)))
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-max-in-ratio payment-token launch-token ONE_8 u3000000)))
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-max-out-ratio payment-token launch-token ONE_8 u3000000)))
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-oracle-enabled payment-token launch-token ONE_8 true)))
				(as-contract (try! (contract-call? .amm-swap-pool-v1-1 set-oracle-average payment-token launch-token ONE_8 u9900000)))
				(map-set locked launch-id (merge locked-details { pool-id: (get pool-id pool-details) }))
			)
		)
		(ok { dx: payment-token-amount, dy: launch-token-amount })	
	)
)
(define-public (reduce-position (launch-id uint) (launch-token-trait <ft-trait>) (payment-token-trait <ft-trait>) (percent uint))
	(let 
		(
			(offering (try! (get-launch-or-fail launch-id)))
			(locked-details (unwrap! (get-locked-details launch-id) err-unknown-launch))
			(reduced (as-contract (try! (contract-call? .amm-swap-pool-v1-1 reduce-position payment-token-trait launch-token-trait ONE_8 percent))))
		) 
		(asserts! (> block-height (+ (get registration-end-height offering) (get period locked-details))) err-block-height-not-reached)
		(as-contract (try! (contract-call? payment-token-trait transfer-fixed (get dx reduced) tx-sender (get launch-owner locked-details) none)))
		(as-contract (try! (contract-call? launch-token-trait transfer-fixed (get dy reduced) tx-sender (get launch-owner locked-details) none)))
		(ok reduced)
	)
)
(define-private (check-is-owner)
	(ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized))
)
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)
  )
)