(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait launch-ft-trait .trait-ido-ft.ido-ft-trait)
(define-constant err-unknown-launch (err u2045))
(define-constant err-block-height-not-reached (err u2042))
(define-constant err-invalid-sequence (err u2046))
(define-constant err-invalid-launch-token-trait (err u2026))
(define-constant err-invalid-payment-token-trait (err u2047))
(define-constant err-no-more-claims (err u2031))
(define-constant err-invalid-launch-setting (err u110))
(define-constant err-invalid-input (err u2048))
(define-constant err-already-registered (err u10001))
(define-constant err-activation-threshold-not-reached (err u2036))
(define-constant err-not-authorized (err u1000))
(define-constant walk-resolution u100000)
(define-constant claim-grace-period u144)
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-data-var fee-to-address principal tx-sender)
(define-map approved-operators principal bool)
(define-data-var launch-id-nonce uint u0)
(define-data-var max-size-factor uint u15)
(define-map offerings
	uint
	{
	launch-token: principal,
	payment-token: principal,
	launch-owner: principal,
	launch-tokens-per-ticket: uint,
	price-per-ticket-in-fixed: uint,
	activation-threshold: uint,
	registration-start-height: uint,
	registration-end-height: uint,
	claim-end-height: uint,
	total-tickets: uint,
	apower-per-ticket-in-fixed: (list 6 {apower-per-ticket-in-fixed: uint, tier-threshold: uint}),
	registration-max-tickets: uint,
	fee-per-ticket-in-fixed: uint
	}
)
(define-map total-tickets-registered uint uint)
(define-map start-indexes uint uint)
(define-map offering-ticket-bounds
	{launch-id: uint, owner: principal}
	{start: uint, end: uint}
)
(define-map offering-ticket-amounts
	{launch-id: uint, owner: principal}
	uint
)
(define-map total-tickets-won uint uint)
(define-map tickets-won
	{launch-id: uint, owner: principal}
	uint
)
(define-map claim-walk-positions uint uint)
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
		fee-per-ticket-in-fixed: uint
		})
	)
	(let 
		(
			(launch-id (var-get launch-id-nonce))
		)
		(try! (check-is-owner))
		(asserts!
			(and
				(< block-height (get registration-start-height offering))
				(< (get registration-start-height offering) (get registration-end-height offering))
				(< (get registration-end-height offering) (get claim-end-height offering))
				(<= (get fee-per-ticket-in-fixed offering) ONE_8)
			)
			err-invalid-launch-setting
		)
		(map-set offerings launch-id (merge offering
			{
				launch-token: (contract-of launch-token-trait),
				payment-token: (contract-of payment-token-trait),
				total-tickets: u0
			})
		)
		(var-set launch-id-nonce (+ launch-id u1))
		(ok launch-id)
	)
)
(define-read-only (get-launch-id-nonce)
	(ok (var-get launch-id-nonce))
)
(define-read-only (get-launch (launch-id uint))
	(ok (map-get? offerings launch-id))
)
(define-public (add-to-position (launch-id uint) (tickets uint) (launch-token-trait <ft-trait>))
	(let
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
		)
		(asserts! (< block-height (get registration-start-height offering)) err-block-height-not-reached)
		(asserts! 
			(or 
				(is-eq (get launch-owner offering) tx-sender) 
				(is-ok (check-is-approved)) 
				(is-ok (check-is-owner))
			) 
			err-not-authorized
		)
		(asserts! (is-eq (contract-of launch-token-trait) (get launch-token offering)) err-invalid-launch-token-trait)
		(try! (contract-call? launch-token-trait transfer-fixed (* (get launch-tokens-per-ticket offering) tickets ONE_8) tx-sender (as-contract tx-sender) none))
		(map-set offerings launch-id (merge offering {total-tickets: (+ (get total-tickets offering) tickets)}))
		(ok true)
	)
)
(define-read-only (get-max-size-factor)
	(var-get max-size-factor)
)
(define-public (set-max-size-factor (factor uint))
	(begin 
		(try! (check-is-owner))
		(ok (var-set max-size-factor factor))
	)
)
(define-read-only (calculate-max-step-size (tickets-registered uint) (total-tickets uint))
	(/ (* (/ (* tickets-registered walk-resolution) total-tickets) (var-get max-size-factor)) u10)
)
(define-private (next-bounds (launch-id uint) (tickets uint))
	(let
		(
			(start (default-to u0 (map-get? start-indexes launch-id)))
			(end (+ start (* tickets walk-resolution)))
		)
		(map-set start-indexes launch-id end)
		{start: start, end: end}
	)
)
(define-read-only (get-total-tickets-registered (launch-id uint))
	(default-to u0 (map-get? total-tickets-registered launch-id))
)
(define-read-only (get-total-tickets-won (launch-id uint))
	(default-to u0 (map-get? total-tickets-won launch-id))
)
(define-read-only (get-tickets-won (launch-id uint) (owner principal))
	(default-to u0 (map-get? tickets-won {launch-id: launch-id, owner: owner}))
)
(define-read-only (get-offering-ticket-bounds (launch-id uint) (owner principal))
	(map-get? offering-ticket-bounds {launch-id: launch-id, owner: owner})
)
(define-read-only (get-offering-ticket-amounts (launch-id uint) (owner principal))
	(map-get? offering-ticket-amounts {launch-id: launch-id, owner: owner})
)
(define-private (get-apower-required-iter (bracket {apower-per-ticket-in-fixed: uint, tier-threshold: uint}) (prior {remaining-tickets: uint, apower-so-far: uint, length: uint}))
	(let
		( 
			(tickets-to-process 
				(if (or (is-eq (get length prior) u1) (< (get remaining-tickets prior) (get tier-threshold bracket))) 
					(get remaining-tickets prior)
					(get tier-threshold bracket)
				)
			)
		)
		{ 
			remaining-tickets: (- (get remaining-tickets prior) tickets-to-process), 
			apower-so-far: (+ (get apower-so-far prior) (* tickets-to-process (get apower-per-ticket-in-fixed bracket))), 
			length: (- (get length prior) u1)
		}
	)	
)
(define-read-only (get-apower-required-in-fixed (launch-id uint) (tickets uint))
	(let 
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
			(tiers (get apower-per-ticket-in-fixed offering))
		)
		(ok (get apower-so-far (fold get-apower-required-iter tiers {remaining-tickets: tickets, apower-so-far: u0, length: (len tiers)})))
	)	
)
(define-public (register (launch-id uint) (tickets uint) (payment-token-trait <ft-trait>))
	(let
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
			(apower-to-burn (try! (get-apower-required-in-fixed launch-id tickets)))
			(bounds (next-bounds launch-id tickets))
			(sender tx-sender)
		)
		(asserts! (is-none (map-get? offering-ticket-bounds {launch-id: launch-id, owner: tx-sender})) err-already-registered)
		(asserts! (and (> tickets u0) (<= tickets (get registration-max-tickets offering))) err-invalid-input)
		(asserts! (and (>= block-height (get registration-start-height offering)) (< block-height (get registration-end-height offering))) err-block-height-not-reached)	
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)		
		(try! (contract-call? payment-token-trait transfer-fixed (* (get price-per-ticket-in-fixed offering) tickets) sender (as-contract tx-sender) none))		
		(as-contract (try! (contract-call? .token-apower burn-fixed apower-to-burn sender)))
		(map-set offering-ticket-bounds {launch-id: launch-id, owner: tx-sender} bounds)
		(map-set offering-ticket-amounts {launch-id: launch-id, owner: tx-sender} tickets)
		(map-set total-tickets-registered launch-id (+ (get-total-tickets-registered launch-id) tickets))
		(ok bounds)
	)
)
(define-read-only (get-initial-walk-position (registration-end-height uint) (max-step-size uint))
	(ok (lcg-next (try! (get-vrf-uint (+ registration-end-height u1))) max-step-size))
)
(define-read-only (get-last-claim-walk-position (launch-id uint) (registration-end-height uint) (max-step-size uint))
	(match (map-get? claim-walk-positions launch-id)
		position (ok position)
		(get-initial-walk-position registration-end-height max-step-size)
	)
)
(define-read-only (get-offering-walk-parameters (launch-id uint))
	(let
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
			(max-step-size (calculate-max-step-size (get-total-tickets-registered launch-id) (get total-tickets offering)))
			(walk-position (try! (get-initial-walk-position (get registration-end-height offering) max-step-size)))
		)
		(ok {max-step-size: max-step-size, walk-position: walk-position, total-tickets: (get total-tickets offering), activation-threshold: (get activation-threshold offering)})
	)
)
(define-private (verify-winner-iter (owner principal) (prior (response {owner: (optional principal), launch-id: uint, tickets-won-so-far: uint, bounds: {start: uint, end: uint}, walk-position: uint, max-step-size: uint, length: uint} uint)))
	(let
		(
			(p (try! prior))
			(k {launch-id: (get launch-id p), owner: owner})
			(bounds (if (and (is-some (get owner p)) (is-eq (unwrap-panic (get owner p)) owner)) (get bounds p) (unwrap! (map-get? offering-ticket-bounds k) err-invalid-input)))
			(tickets-won-so-far (+ u1 (if (and (is-some (get owner p)) (is-eq (unwrap-panic (get owner p)) owner)) (get tickets-won-so-far p) (default-to u0 (map-get? tickets-won k)))))
			(new-walk-position (+ (* (+ u1 (/ (get walk-position p) walk-resolution)) walk-resolution) (lcg-next (get walk-position p) (get max-step-size p))))
		)
		(asserts! (and (>= (get walk-position p) (get start bounds)) (< (get walk-position p) (get end bounds))) err-invalid-sequence)
		(and (or (>= new-walk-position (get end bounds)) (is-eq (get length p) u1)) (map-set tickets-won k tickets-won-so-far))
		(ok (merge p { owner: (some owner), tickets-won-so-far: tickets-won-so-far, bounds: bounds, walk-position: new-walk-position, length: (- (get length p) u1)}))
	)
)
(define-private (claim-process (launch-id uint) (input (list 200 principal)) (launch-token-trait principal) (payment-token-trait <ft-trait>))
	(let
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
			(total-won (default-to u0 (map-get? total-tickets-won launch-id)))
			(max-step-size (calculate-max-step-size (get-total-tickets-registered launch-id) (get total-tickets offering)))
			(walk-position (try! (get-last-claim-walk-position launch-id (get registration-end-height offering) max-step-size)))
			(result (try! (fold verify-winner-iter input (ok {owner: none, launch-id: launch-id, tickets-won-so-far: u0, bounds: {start: u0, end: u0}, walk-position: walk-position, max-step-size: max-step-size, length: (len input)}))))
			(fee-per-ticket (mul-down (get price-per-ticket-in-fixed offering) (get fee-per-ticket-in-fixed offering)))
			(net-price-per-ticket (- (get price-per-ticket-in-fixed offering) fee-per-ticket))
		)
 		(asserts! (is-eq (get launch-token offering) launch-token-trait) err-invalid-launch-token-trait)
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)		
		(asserts! (>= block-height (get registration-end-height offering)) err-block-height-not-reached)		
		(asserts! (and (< total-won (get total-tickets offering)) (< walk-position (unwrap-panic (map-get? start-indexes launch-id)))) err-no-more-claims)
		(asserts! (<= (get activation-threshold offering) (get-total-tickets-registered launch-id)) err-activation-threshold-not-reached)
		(asserts!
			(or
				(>= block-height (+ (get claim-end-height offering) claim-grace-period))
				(is-eq (get launch-owner offering) tx-sender)
				(is-ok (check-is-owner))
				(is-ok (check-is-approved))
			)
			err-not-authorized
		)
		(map-set claim-walk-positions launch-id (get walk-position result))
		(map-set total-tickets-won launch-id (+ (len input) total-won))
		(and (> fee-per-ticket u0) (try! (as-contract (contract-call? payment-token-trait transfer-fixed (* (len input) fee-per-ticket) tx-sender (var-get fee-to-address) none))))
		(try! (as-contract (contract-call? payment-token-trait transfer-fixed (* (len input) net-price-per-ticket) tx-sender (get launch-owner offering) none)))
		
		(ok (get launch-tokens-per-ticket offering))
	)
)
(define-public (claim (launch-id uint) (input (list 200 principal)) (launch-token-trait <ft-trait>) (payment-token-trait <ft-trait>))
	(begin
		(var-set tm-amount (* ONE_8 (try! (claim-process launch-id input (contract-of launch-token-trait) payment-token-trait))))
		(fold transfer-many-iter input launch-token-trait)
		(ok true)
	)
)
(define-data-var tm-amount uint u0)
(define-private (transfer-many-iter (recipient principal) (launch-token-trait <ft-trait>))
	(begin
		(unwrap-panic (as-contract (contract-call? launch-token-trait transfer-fixed (var-get tm-amount) tx-sender recipient none)))
		launch-token-trait
	)
)
(define-private (transfer-many-amounts-iter (e {recipient: principal, amount: uint}) (payment-token-trait <ft-trait>))
	(begin
		(unwrap-panic (as-contract (contract-call? payment-token-trait transfer-fixed (get amount e) tx-sender (get recipient e) none)))
		payment-token-trait
	)
)
(define-private (max-upper-refund-bound (launch-id uint) (total-tickets uint) (total-tickets-register uint) (registration-end-height uint) (activation-threshold uint))
	(if 
		(or 
			;; either we sold all, or we failed
			(is-eq (default-to u0 (map-get? total-tickets-won launch-id)) total-tickets)
			(> activation-threshold (get-total-tickets-registered launch-id))
		)
		(ok (* total-tickets-register walk-resolution))
		(get-last-claim-walk-position launch-id registration-end-height (calculate-max-step-size total-tickets-register total-tickets))
	)
)
(define-private (refund-iter (e {recipient: principal, amount: uint}) (prior (response {launch-id: uint, upper-bound: uint, price-per-ticket: uint} uint)))
	(let
		(
			(p (try! prior))
			(k {launch-id: (get launch-id p), owner: (get recipient e)})
			(bounds (unwrap! (map-get? offering-ticket-bounds k) err-invalid-input))
		)		
		(map-delete offering-ticket-bounds k)
		(asserts! 
			(and 
				(<= (get end bounds) (get upper-bound p)) 
				(is-eq (* (- (/ (- (get end bounds) (get start bounds)) walk-resolution) (default-to u0 (map-get? tickets-won k))) (get price-per-ticket p)) (get amount e))
			)
			err-invalid-sequence
		)
		(ok {launch-id: (get launch-id p), upper-bound: (get upper-bound p), price-per-ticket: (get price-per-ticket p)})
	)
)
(define-public (refund (launch-id uint) (input (list 200 {recipient: principal, amount: uint})) (payment-token-trait <ft-trait>))
	(let 
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
		)
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)
		(asserts! (>= block-height (get registration-end-height offering)) err-block-height-not-reached)
		(asserts!
			(or
				(>= block-height (+ (get claim-end-height offering) claim-grace-period))
				(is-eq (get launch-owner offering) tx-sender)
				(is-ok (check-is-owner))
				(is-ok (check-is-approved))
			)
			err-not-authorized
		)		
		(try! 
			(fold 
				refund-iter 
				input
				(ok 
					{
						launch-id: launch-id,
						upper-bound: (try! (max-upper-refund-bound launch-id (get total-tickets offering) (get-total-tickets-registered launch-id) (get registration-end-height offering) (get activation-threshold offering))),
						price-per-ticket: (unwrap! (get price-per-ticket-in-fixed (map-get? offerings launch-id)) err-unknown-launch),
					}
				)
			)
		)
		(fold transfer-many-amounts-iter input payment-token-trait)
		(ok true)
	)
)
(define-public (claim-optimal (launch-id uint) (input (list 200 principal)) (launch-token-trait <launch-ft-trait>) (payment-token-trait <ft-trait>))
	(let
		(
			(launch-tokens-per-ticket (* ONE_8 (try! (claim-process launch-id input (contract-of launch-token-trait) payment-token-trait))))
		)
		(as-contract (contract-call? launch-token-trait transfer-many-ido launch-tokens-per-ticket input))
	)
)
(define-public (refund-optimal (launch-id uint) (input (list 200 {recipient: principal, amount: uint})) (payment-token-trait <launch-ft-trait>))
	(let 
		(
			(offering (unwrap! (map-get? offerings launch-id) err-unknown-launch))
		)
		(asserts! (is-eq (get payment-token offering) (contract-of payment-token-trait)) err-invalid-payment-token-trait)
		(asserts!
			(or
				(>= block-height (+ (get claim-end-height offering) claim-grace-period))
				(is-eq (get launch-owner offering) tx-sender)
				(is-ok (check-is-owner))
				(is-ok (check-is-approved))
			)
			err-not-authorized
		)		
		(asserts! (get s
			(fold refund-optimal-iter input
				{
					i: launch-id,
					u: (try! (max-upper-refund-bound launch-id (get total-tickets offering) (get-total-tickets-registered launch-id) (get registration-end-height offering) (get activation-threshold offering))),
					p: (unwrap! (get price-per-ticket-in-fixed (map-get? offerings launch-id)) err-unknown-launch),
					s: true
				}))
			err-invalid-sequence
		)
		(as-contract (contract-call? payment-token-trait transfer-many-amounts-ido input))
	)
)
(define-private (refund-optimal-iter (e {recipient: principal, amount: uint}) (p {i: uint, u: uint, p: uint, s: bool}))
	(let
		(
			(k {launch-id: (get i p), owner: (get recipient e)})
			(b (unwrap! (map-get? offering-ticket-bounds k) (merge p {s: false})))
		)
		(asserts! (get s p) p)
		(map-delete offering-ticket-bounds k)
		{
			i: (get i p),
			u: (get u p),
			p: (get p p),
			s: (and (<= (get end b) (get u p)) (is-eq (* (- (/ (- (get end b) (get start b)) walk-resolution) (default-to u0 (map-get? tickets-won k))) (get p p)) (get amount e)))
		}
	)
)
(define-public (transfer-all-to-owner (token-trait <ft-trait>))
	(let 
		(
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender))))
		)
		(try! (check-is-owner))
		(and 
			(> balance u0) 
			(as-contract 
				(try!
					(contract-call? 
						token-trait 
						transfer-fixed 
				 		balance
						tx-sender 
						(var-get contract-owner) 
						none
					)
				)
			)
		)
		(ok true)
	)
)
(define-constant lcg-a u134775813)
(define-constant lcg-c u1)
(define-constant lcg-m u4294967296)
(define-read-only (lcg-next (current uint) (max-step uint))
	(mod (mod (+ (* lcg-a current) lcg-c) lcg-m) max-step)
)
(define-read-only (get-vrf-uint (height uint))
	(ok (buff-to-uint64 (unwrap! (get-block-info? vrf-seed height) err-block-height-not-reached)))
)
(define-constant byte-list
	(list
		0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
		0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
		0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
		0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
		0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
		0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
		0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
		0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
		0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
		0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
		0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
		0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
		0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
		0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
		0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
		0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
	)
)
(define-read-only (byte-to-uint (byte (buff 1)))
	(unwrap-panic (index-of byte-list byte))
)
(define-read-only (buff-to-uint64 (bytes (buff 32)))
	(+
		(match (element-at bytes u0) byte (byte-to-uint byte) u0)
		(match (element-at bytes u1) byte (* (byte-to-uint byte) u256) u0)
		(match (element-at bytes u2) byte (* (byte-to-uint byte) u65536) u0)
		(match (element-at bytes u3) byte (* (byte-to-uint byte) u16777216) u0)
		(match (element-at bytes u4) byte (* (byte-to-uint byte) u4294967296) u0)
		(match (element-at bytes u5) byte (* (byte-to-uint byte) u1099511627776) u0)
		(match (element-at bytes u6) byte (* (byte-to-uint byte) u281474976710656) u0)
		(match (element-at bytes u7) byte (* (byte-to-uint byte) u72057594037927936) u0)
	)
)
(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)
(define-read-only (get-fee-to-address)
	(ok (var-get fee-to-address))
)
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))
	)
)
(define-public (set-fee-to-address (owner principal))
	(begin 
		(try! (check-is-owner))
		(ok (var-set fee-to-address owner))
	)
)
(define-private (check-is-owner)
	(ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized))
)
(define-private (check-is-approved)
	(ok (asserts! (default-to false (map-get? approved-operators tx-sender)) err-not-authorized))
)
(define-public (add-approved-operator (new-approved-operator principal))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-operators new-approved-operator true))
	)
)
(define-read-only (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)
(define-read-only (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)
  )
)