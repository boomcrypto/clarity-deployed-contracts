;; SPDX-License-Identifier: BUSL-1.1
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-unknown-launch (err u2045))
(define-constant err-tenure-height-not-reached (err u2042))
(define-constant err-invalid-sequence (err u2046))
(define-constant err-invalid-launch-token-trait (err u2026))
(define-constant err-invalid-payment-token-trait (err u2047))
(define-constant err-no-more-claims (err u2031))
(define-constant err-invalid-launch-setting (err u110))
(define-constant err-invalid-input (err u2048))
(define-constant err-already-registered (err u10001))
(define-constant err-activation-threshold-not-reached (err u2036))
(define-constant err-not-authorized (err u1000))
(define-constant err-not-in-whitelist (err u2049))
(define-constant err-apower-not-enough (err u2050))
(define-constant err-total-registration-max (err u2051))
(define-constant err-principal-construct (err u2052))
(define-constant err-update-failed (err u2053))

(define-constant walk-resolution u100000)
(define-constant claim-grace-period u144)

(define-constant ONE_8 u100000000)

(define-constant lcg-a u134775813)
(define-constant lcg-c u1)
(define-constant lcg-m u4294967296)

(define-data-var fee-to-address principal 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao)
(define-map approved-operators principal bool)

(define-data-var launch-id-nonce uint u0)

(define-map offerings
	uint
	{
	launch-token: { address: principal, chain-id: (optional uint) },
	payment-token: principal,
	launch-owner: { address: (buff 128), chain-id: (optional uint) },
	launch-tokens-per-ticket: uint,
	price-per-ticket-in-fixed: uint,
	activation-threshold: uint,
	registration-start-height: uint,
	registration-end-height: uint,
	claim-end-height: uint,
	total-tickets: uint,
	apower-per-ticket-in-fixed: (list 6 {apower-per-ticket-in-fixed: uint, tier-threshold: uint}),
	registration-max-tickets: uint,
	fee-per-ticket-in-fixed: uint,
	total-registration-max: uint,
	max-size-factor: uint,
	memo: (optional (buff 512))
	}
)

(define-map total-tickets-registered uint uint)

(define-map start-indexes uint uint)

(define-map offering-ticket-bounds { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} { start: uint, end: uint })

(define-map offering-ticket-amounts { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} uint)

(define-map total-tickets-won uint uint)

(define-map tickets-won { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} uint)
(define-map tickets-dest { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} (buff 128))

(define-map claim-walk-positions uint uint)

(define-map use-whitelist uint bool)
(define-map whitelisted { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} bool)

(define-map offering-refunded { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }} bool)

;; read-only calls

(define-read-only (destruct-principal (address principal))
	(principal-destruct? address))

(define-read-only (construct-principal (hash-bytes (buff 128)))
	(principal-construct? (if (is-eq chain-id u1) 0x16 0x1a) (unwrap-panic (as-max-len? hash-bytes u20))))

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorized)))

(define-read-only (get-fee-to-address)
	(ok (var-get fee-to-address)))

(define-read-only (get-launch-id-nonce)
	(var-get launch-id-nonce))

(define-read-only (get-launch (launch-id uint))
	(map-get? offerings launch-id))

(define-read-only (get-launch-or-fail (launch-id uint))
	(ok (unwrap! (get-launch launch-id) err-unknown-launch)))

(define-read-only (calculate-max-step-size (launch-id uint))
	(let ( 
			(offering (try! (get-launch-or-fail launch-id))))
		(ok (/ (* (/ (* (get-total-tickets-registered launch-id) walk-resolution) (get total-tickets offering)) (get max-size-factor offering)) u10))))

(define-read-only (get-total-tickets-registered (launch-id uint))
	(default-to u0 (map-get? total-tickets-registered launch-id)))

(define-read-only (get-total-tickets-won (launch-id uint))
	(default-to u0 (map-get? total-tickets-won launch-id)))

(define-read-only (get-tickets-won (launch-id uint) (owner { address: (buff 128), chain-id: (optional uint) }))
	(default-to u0 (map-get? tickets-won { launch-id: launch-id, owner: owner })))

(define-read-only (get-tickets-dest-or-fail (launch-id uint) (owner { address: (buff 128), chain-id: (optional uint) }))
	(ok (unwrap! (map-get? tickets-dest { launch-id: launch-id, owner: owner }) err-invalid-input)))

(define-read-only (get-offering-ticket-bounds (launch-id uint) (owner { address: (buff 128), chain-id: (optional uint) }))
	(map-get? offering-ticket-bounds { launch-id: launch-id, owner: owner }))

(define-read-only (get-offering-ticket-amounts (launch-id uint) (owner { address: (buff 128), chain-id: (optional uint) }))
	(map-get? offering-ticket-amounts { launch-id: launch-id, owner: owner }))

(define-read-only (get-apower-required-in-fixed (launch-id uint) (tickets uint))
	(let (
			(tiers (get apower-per-ticket-in-fixed (try! (get-launch-or-fail launch-id)))))
		(ok (get apower-so-far (fold get-apower-required-iter tiers {remaining-tickets: tickets, apower-so-far: u0, length: (len tiers)}))))	)

(define-read-only (get-initial-walk-position (registration-end-height uint) (max-step-size uint))
	(ok (lcg-next (try! (get-vrf-uint (+ registration-end-height u1))) max-step-size)))

(define-read-only (get-last-claim-walk-position (launch-id uint) (registration-end-height uint) (max-step-size uint))
	(match (map-get? claim-walk-positions launch-id)
		position (ok position)
		(get-initial-walk-position registration-end-height max-step-size)))

(define-read-only (get-offering-walk-parameters (launch-id uint))
	(let (
			(offering (try! (get-launch-or-fail launch-id)))
			(max-step-size (try! (calculate-max-step-size launch-id)))
			(walk-position (try! (get-initial-walk-position (get registration-end-height offering) max-step-size))))
		(ok {max-step-size: max-step-size, walk-position: walk-position, total-tickets: (get total-tickets offering), activation-threshold: (get activation-threshold offering)})))

(define-read-only (lcg-next (current uint) (max-step uint))
	(mod (mod (+ (* lcg-a (mod current lcg-m)) lcg-c) lcg-m) max-step))

(define-read-only (get-vrf-uint (height uint))
	(ok (buff-to-uint-le (unwrap-panic (as-max-len? (unwrap-panic (slice? (unwrap! (get-tenure-info? vrf-seed height) err-tenure-height-not-reached) u0 u16)) u16)))))

(define-read-only (validate-register (owner { address: (buff 128), chain-id: (optional uint) }) (dest (buff 128)) (launch-id uint) (payment-amount uint) (payment-token principal))
	(let (
			(offering (try! (get-launch-or-fail launch-id)))
			(tickets (/ payment-amount (get price-per-ticket-in-fixed offering)))
			(apower-to-burn (try! (get-apower-required-in-fixed launch-id tickets)))
			(apower-bal (if (is-some (get chain-id owner)) u0 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower get-balance-fixed (unwrap! (construct-principal (get address owner)) err-principal-construct))))))
		(asserts! (or (is-ok (is-dao-or-extension)) (get-whitelisted-or-default launch-id owner)) err-not-in-whitelist)
		(asserts! (is-none (map-get? offering-ticket-bounds { launch-id: launch-id, owner: owner })) err-already-registered)
		(asserts! (and (> tickets u0) (<= tickets (get registration-max-tickets offering))) err-invalid-input)
		(asserts! (and (>= tenure-height (get registration-start-height offering)) (< tenure-height (get registration-end-height offering))) err-tenure-height-not-reached)			
		(asserts! (is-eq (get payment-token offering) payment-token) err-invalid-payment-token-trait)
		(asserts! (>= apower-bal apower-to-burn) err-apower-not-enough)
		(asserts! (<= (+ (get-total-tickets-registered launch-id) tickets) (get total-registration-max offering)) err-total-registration-max)
		(and (is-none (get chain-id owner)) (begin (unwrap! (construct-principal (get address owner)) err-principal-construct) true))
		(and (is-none (get chain-id (get launch-owner offering))) (begin (unwrap! (construct-principal dest) err-principal-construct) true))
		(ok { offering: offering, tickets: tickets, apower-to-burn: apower-to-burn })))

(define-read-only (get-use-whitelist-or-default (launch-id uint))
	(default-to false (map-get? use-whitelist launch-id)))

(define-read-only (get-whitelisted-or-default (launch-id uint) (owner { address: (buff 128), chain-id: (optional uint) }))
	(if (get-use-whitelist-or-default launch-id)
		(default-to false (map-get? whitelisted { launch-id: launch-id, owner: owner }))
		true))

(define-read-only (get-offering-refuned-or-default (owner { launch-id: uint, owner: { address: (buff 128), chain-id: (optional uint) }}))
	(default-to false (map-get? offering-refunded owner)))

;; governance calls

(define-public (set-use-whitelist (launch-id uint) (new-whitelisted bool))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map-set use-whitelist launch-id new-whitelisted))))

(define-public (set-whitelisted (launch-id uint) (whitelisted-users (list 200 {owner: { address: (buff 128), chain-id: (optional uint) }, whitelisted: bool})))
	(let (
			(offering (try! (get-launch-or-fail launch-id))))
		(asserts! (or (is-ok (check-is-approved)) (is-ok (is-dao-or-extension))) err-not-authorized)
		(fold set-whitelisted-iter whitelisted-users launch-id)
		(ok true)))

(define-public (set-fee-to-address (owner principal))
	(begin 
		(try! (is-dao-or-extension))
		(ok (var-set fee-to-address owner))))

(define-public (add-approved-operator (new-approved-operator principal))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-operators new-approved-operator true))))

(define-public (create-pool
	(offering
		{	
		launch-token: { address: principal, chain-id: (optional uint) },
		payment-token: principal,
		launch-owner: { address: (buff 128), chain-id: (optional uint) },
		launch-tokens-per-ticket: uint,
		price-per-ticket-in-fixed: uint,
		activation-threshold: uint,
		registration-start-height: uint,
		registration-end-height: uint,
		claim-end-height: uint,
		apower-per-ticket-in-fixed: (list 6 {apower-per-ticket-in-fixed: uint, tier-threshold: uint}),
		registration-max-tickets: uint,
		fee-per-ticket-in-fixed: uint,
		total-registration-max: uint,
		memo: (optional (buff 512))
		})
	)
	(let (
			(launch-id (var-get launch-id-nonce)))
		(try! (is-dao-or-extension))
		(asserts!
			(and
				(< tenure-height (get registration-start-height offering))
				(< (get registration-start-height offering) (get registration-end-height offering))
				(< (get registration-end-height offering) (get claim-end-height offering))
				(<= (get fee-per-ticket-in-fixed offering) ONE_8)
				(<= (get registration-max-tickets offering) (get total-registration-max offering)))
			err-invalid-launch-setting)
		(asserts! (map-set offerings launch-id (merge offering { max-size-factor: u15, total-tickets: u0})) err-update-failed)
		(print { type: "create-pool", launch-id: launch-id, offering: offering })
		(asserts! (var-set launch-id-nonce (+ launch-id u1)) err-update-failed)
		(ok launch-id)))
	
(define-public (update-pool (launch-id uint) (offering 
	{
	launch-token: { address: principal, chain-id: (optional uint) },
	payment-token: principal,
	launch-owner: { address: (buff 128), chain-id: (optional uint) },
	launch-tokens-per-ticket: uint,
	price-per-ticket-in-fixed: uint,
	activation-threshold: uint,
	registration-start-height: uint,
	registration-end-height: uint,
	claim-end-height: uint,
	total-tickets: uint,
	apower-per-ticket-in-fixed: (list 6 {apower-per-ticket-in-fixed: uint, tier-threshold: uint}),
	registration-max-tickets: uint,
	fee-per-ticket-in-fixed: uint,
	total-registration-max: uint,
	max-size-factor: uint,
	memo: (optional (buff 512))
	}))
	(begin 
		(try! (is-dao-or-extension))
		(asserts! (map-set offerings launch-id offering) err-update-failed)
		(print { type: "update-pool", launch-id: launch-id, offering: offering })
		(ok true)))


(define-public (transfer-all-to-dao (token-trait <ft-trait>))
	(let (
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender)))))
		(try! (is-dao-or-extension))
		(and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed balance tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao none))))
		(ok true)))

(define-public (set-max-size-factor (launch-id uint) (new-factor uint))
	(let ( 
			(offering (try! (get-launch-or-fail launch-id))))
		(try! (is-dao-or-extension))
		(ok (map-set offerings launch-id (merge offering { max-size-factor: new-factor })))))

;; privilidged calls

(define-public (add-to-position (launch-id uint) (tickets uint) (launch-token-trait <ft-trait>))
	(let (
			(offering (try! (get-launch-or-fail launch-id)))
			(launch-token-amount (* (get launch-tokens-per-ticket offering) tickets ONE_8)))
		(asserts! (< tenure-height (get registration-start-height offering)) err-tenure-height-not-reached)
		(asserts! (or (is-ok (is-dao-or-extension))) err-not-authorized)
		(asserts! (is-eq (contract-of launch-token-trait) (get address (get launch-token offering))) err-invalid-launch-token-trait)
		(try! (contract-call? launch-token-trait transfer-fixed launch-token-amount tx-sender (as-contract tx-sender) none))
		(asserts! (map-set offerings launch-id (merge offering { total-tickets: (+ (get total-tickets offering) tickets) })) err-update-failed)
		(print { type: "add-to-position", launch-id: launch-id, ticket-amount: tickets, launch-token-amount: launch-token-amount })
		(ok true)))

(define-public (claim (launch-id uint) (input (list 200 { address: (buff 128), chain-id: (optional uint) })) (launch-token-trait <ft-trait>) (payment-token-trait <ft-trait>) (memo (optional (buff 512))))
	(let (
			(offering (try! (get-launch-or-fail launch-id)))
			(total-won (default-to u0 (map-get? total-tickets-won launch-id)))
			(max-step-size (try! (calculate-max-step-size launch-id)))
			(walk-position (try! (get-last-claim-walk-position launch-id (get registration-end-height offering) max-step-size)))
			(result (try! (fold verify-winner-iter input (ok {owner: none, launch-id: launch-id, tickets-won-so-far: u0, bounds: {start: u0, end: u0}, walk-position: walk-position, max-step-size: max-step-size, length: (len input)}))))
			(fee-per-ticket (mul-down (get price-per-ticket-in-fixed offering) (get fee-per-ticket-in-fixed offering)))
			(net-price-per-ticket (- (get price-per-ticket-in-fixed offering) fee-per-ticket))
			(tm-amount (* ONE_8 (get launch-tokens-per-ticket offering))))
 		(asserts! (is-eq (get address (get launch-token offering)) (contract-of launch-token-trait)) err-invalid-launch-token-trait)
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)		
		(asserts! (>= tenure-height (get registration-end-height offering)) err-tenure-height-not-reached)		
		(asserts! (and (< total-won (get total-tickets offering)) (< walk-position (unwrap-panic (map-get? start-indexes launch-id)))) err-no-more-claims)
		(asserts! (<= (get activation-threshold offering) (get-total-tickets-registered launch-id)) err-activation-threshold-not-reached)
		(asserts! (or (>= tenure-height (+ (get claim-end-height offering) claim-grace-period)) (is-ok (is-dao-or-extension)) (is-ok (check-is-approved))) err-not-authorized)
		(asserts! (map-set claim-walk-positions launch-id (get walk-position result)) err-update-failed)
		(asserts! (map-set total-tickets-won launch-id (+ (len input) total-won)) err-update-failed)

		(and (> fee-per-ticket u0) (try! (as-contract (contract-call? payment-token-trait transfer-fixed (* (len input) fee-per-ticket) tx-sender (var-get fee-to-address) none))))
		(as-contract (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 route (* (len input) net-price-per-ticket) (list payment-token-trait) (list ) payment-token-trait none (get launch-owner offering))))			
		(fold claim-iter input { launch-id: launch-id, chain-id: (get chain-id (get launch-token offering)), token-trait: launch-token-trait, memo: memo, tm-amount: tm-amount } )
		(print { type: "claim", launch-id: launch-id, input: input, tm-amount: tm-amount })
		(ok true)))

(define-public (refund (launch-id uint) (input (list 200 {recipient: { address: (buff 128), chain-id: (optional uint) }, amount: uint})) (payment-token-trait <ft-trait>))
	(let (
			(offering (try! (get-launch-or-fail launch-id)))
			(upper-bound (try! (max-upper-refund-bound launch-id (get total-tickets offering) (get-total-tickets-registered launch-id) (get registration-end-height offering) (get activation-threshold offering))))
			(price-per-ticket (unwrap! (get price-per-ticket-in-fixed (map-get? offerings launch-id)) err-unknown-launch)))
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)
		(asserts! (>= tenure-height (get registration-end-height offering)) err-tenure-height-not-reached)
		(asserts! (or (>= tenure-height (+ (get claim-end-height offering) claim-grace-period)) (is-ok (is-dao-or-extension)) (is-ok (check-is-approved))) err-not-authorized)		
		(try! (fold verify-refund-iter input (ok { launch-id: launch-id, upper-bound: upper-bound, price-per-ticket: price-per-ticket })))
		(print { type: "refund", launch-id: launch-id, input: input, price-per-ticket: price-per-ticket })
		(fold refund-iter input payment-token-trait)
		(ok true)))

;; public calls

(define-public (register (owner { address: (buff 128), chain-id: (optional uint) }) (dest (buff 128)) (launch-id uint) (payment-amount uint) (payment-token-trait <ft-trait>))
	(let (
			(offering-details (try! (validate-register owner dest launch-id payment-amount (contract-of payment-token-trait))))
			(tickets (get tickets offering-details))
			(offering (get offering offering-details))
			(apower-to-burn (get apower-to-burn offering-details))
			(bounds (try! (next-bounds launch-id tickets)))
			(sender tx-sender))
		(try! (contract-call? payment-token-trait transfer-fixed payment-amount sender (as-contract tx-sender) none))				
		(and (> apower-to-burn u0) (as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower burn-fixed apower-to-burn (unwrap! (construct-principal (get address owner)) err-principal-construct)))))
		(asserts! (map-set offering-ticket-bounds { launch-id: launch-id, owner: owner } bounds) err-update-failed)
		(asserts! (map-set offering-ticket-amounts { launch-id: launch-id, owner: owner } tickets) err-update-failed)
		(asserts! (map-set total-tickets-registered launch-id (+ (get-total-tickets-registered launch-id) tickets)) err-update-failed)
		(asserts! (map-set tickets-dest { launch-id: launch-id, owner: owner } dest) err-update-failed)
		(print { type: "register", launch-id: launch-id, owner: owner, dest: dest, payment-token: (contract-of payment-token-trait), payment-amount: payment-amount, tickets: tickets, bounds: bounds, sender: sender, apower-to-burn: apower-to-burn })
		(ok bounds)))

;; private calls

(define-private (claim-iter (recipient { address: (buff 128), chain-id: (optional uint) }) (details { launch-id: uint, chain-id: (optional uint), token-trait: <ft-trait>, memo: (optional (buff 512)), tm-amount: uint }))
	(begin
		(as-contract (unwrap-panic (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 route (get tm-amount details) (list (get token-trait details)) (list ) (get token-trait details) none { address: (unwrap-panic (get-tickets-dest-or-fail (get launch-id details) recipient)), chain-id: (get chain-id details) })))
		details))

(define-private (refund-iter (e { recipient: { address: (buff 128), chain-id: (optional uint) }, amount: uint }) (payment-token-trait <ft-trait>))
	(begin 
		(as-contract (unwrap-panic (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 route (get amount e) (list payment-token-trait) (list ) payment-token-trait none (get recipient e))))
		payment-token-trait))

;; Calculate the maximum upper bound allowed to be refunded. It is either set to the maximum launch bound
;; in case all tickets have been won, or to the last walk position in case the claim walk is still
;; in progress. Participants whose upper bound is larger than this value cannot yet get a refund.
(define-private (max-upper-refund-bound (launch-id uint) (total-tickets uint) (total-tickets-register uint) (registration-end-height uint) (activation-threshold uint))
	;; either we sold all, or we failed
	(if (or (is-eq (default-to u0 (map-get? total-tickets-won launch-id)) total-tickets) (> activation-threshold (get-total-tickets-registered launch-id)))
		(ok (* total-tickets-register walk-resolution))
		(get-last-claim-walk-position launch-id registration-end-height (try! (calculate-max-step-size launch-id)))))

(define-private (set-whitelisted-iter (e {owner: { address: (buff 128), chain-id: (optional uint) }, whitelisted: bool}) (launch-id uint))
	(begin 
		(map-set whitelisted {launch-id: launch-id, owner: (get owner e)} (get whitelisted e))
		launch-id))

(define-private (verify-refund-iter (e {recipient: { address: (buff 128), chain-id: (optional uint) }, amount: uint}) (prior (response {launch-id: uint, upper-bound: uint, price-per-ticket: uint} uint)))
	(let (
			(p (try! prior))
			(k {launch-id: (get launch-id p), owner: (get recipient e)})
			(bounds (unwrap! (map-get? offering-ticket-bounds k) err-invalid-input)))		
		(asserts! (not (get-offering-refuned-or-default k)) err-invalid-sequence)
		(asserts! (map-set offering-refunded k true) err-update-failed)
		(asserts! 
			(and 
				(<= (get end bounds) (get upper-bound p)) 
				(is-eq (* (- (/ (- (get end bounds) (get start bounds)) walk-resolution) (default-to u0 (map-get? tickets-won k))) (get price-per-ticket p)) (get amount e)))
			err-invalid-sequence)
		(ok {launch-id: (get launch-id p), upper-bound: (get upper-bound p), price-per-ticket: (get price-per-ticket p)})))

(define-private (check-is-approved)
	(ok (asserts! (default-to false (map-get? approved-operators tx-sender)) err-not-authorized)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (next-bounds (launch-id uint) (tickets uint))
	(let (
			(start (default-to u0 (map-get? start-indexes launch-id)))
			(end (+ start (* tickets walk-resolution))))
		(asserts! (map-set start-indexes launch-id end) err-update-failed)
		(ok {start: start, end: end})))

(define-private (get-apower-required-iter (bracket {apower-per-ticket-in-fixed: uint, tier-threshold: uint}) (prior {remaining-tickets: uint, apower-so-far: uint, length: uint}))
	(let ( 
			(tickets-to-process 
				(if (or (is-eq (get length prior) u1) (< (get remaining-tickets prior) (get tier-threshold bracket))) 
					(get remaining-tickets prior)
					(get tier-threshold bracket))))
		{ remaining-tickets: (- (get remaining-tickets prior) tickets-to-process), 
			apower-so-far: (+ (get apower-so-far prior) (* tickets-to-process (get apower-per-ticket-in-fixed bracket))), 
			length: (- (get length prior) u1) }))

(define-private (verify-winner-iter (owner { address: (buff 128), chain-id: (optional uint) }) (prior (response {owner: (optional { address: (buff 128), chain-id: (optional uint) }), launch-id: uint, tickets-won-so-far: uint, bounds: {start: uint, end: uint}, walk-position: uint, max-step-size: uint, length: uint} uint)))
	(let (
			(p (try! prior))
			(bounds (if (and (is-some (get owner p)) (is-eq (unwrap-panic (get owner p)) owner)) (get bounds p) (unwrap! (map-get? offering-ticket-bounds { launch-id: (get launch-id p), owner: owner }) err-invalid-input)))
			(tickets-won-so-far (+ u1 (if (and (is-some (get owner p)) (is-eq (unwrap-panic (get owner p)) owner)) (get tickets-won-so-far p) (get-tickets-won (get launch-id p) owner))))
			(new-walk-position (+ (* (+ u1 (/ (get walk-position p) walk-resolution)) walk-resolution) (lcg-next (get walk-position p) (get max-step-size p)))))
		(asserts! (and (>= (get walk-position p) (get start bounds)) (< (get walk-position p) (get end bounds))) err-invalid-sequence)
		(asserts! (and (or (>= new-walk-position (get end bounds)) (is-eq (get length p) u1)) (map-set tickets-won { launch-id: (get launch-id p), owner: owner } tickets-won-so-far)) err-update-failed)
		(ok (merge p { owner: (some owner), tickets-won-so-far: tickets-won-so-far, bounds: bounds, walk-position: new-walk-position, length: (- (get length p) u1)}))))
