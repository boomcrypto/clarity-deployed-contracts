(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant ERR-UNKNOWN-LOTTERY (err u2045))
(define-constant ERR-UNKNOWN-LOTTERY-ROUND (err u2047))
(define-constant ERR-BLOCK-HEIGHT-NOT-REACHED (err u2042))
(define-constant ERR-INVALID-SEQUENCE (err u2046))
(define-constant ERR-INVALID-LOTTERY-TOKEN (err u2026))
(define-constant ERR-INVALID-LOTTERY-SETTING (err u110))
(define-constant ERR-ALREADY-REGISTERED (err u10001))
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-LOTTERY-ROUND-ALREADY-CLAIMED (err u2048))
(define-constant ERR-BONUS-TICKETS-EXCEED-MAX (err u2049))
(define-constant ERR-NOT-REGISTERED (err u2050))
(define-constant walk-resolution u100000)
(define-constant ONE_8 u100000000)
(define-data-var contract-owner principal tx-sender)
(define-map approved-operators principal bool)
(define-data-var lottery-id-nonce uint u0)
(define-data-var apower-per-bonus-in-fixed uint (* u50 ONE_8))
(define-data-var bonus-thresholds (list 5 uint) (list u5 u15 u25 u35 u45))
(define-data-var bonus-max (list 5 uint) (list u1 u3 u6 u10 u15))
(define-map lottery
	uint
	{
		token: principal,
		tokens-per-ticket-in-fixed: uint,
		registration-start-height: uint,
		registration-end-height: uint,
	}
)
(define-map lottery-round
	{ lottery-id: uint, round-id: uint }
	{ 
		draw-height: uint,
		percent: uint,
		total-tickets: uint,
		payout-rate: uint,
		play: bool
	}	
)
(define-map total-tickets-registered uint uint)
(define-map total-bonus-tickets-registered uint uint)
(define-map start-indexes uint uint)
(define-map ticket-bounds
	{lottery-id: uint, owner: principal}
	{start: uint, end: uint}
)
(define-public (create-pool (token principal) (tokens-per-ticket-in-fixed uint) (registration-start-height uint) (registration-end-height uint))
	(let 
		(
			(lottery-id (var-get lottery-id-nonce))
		)
		(asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
		(asserts! (and (< block-height registration-end-height) (< registration-start-height registration-end-height)) ERR-INVALID-LOTTERY-SETTING)
		(map-set lottery lottery-id 
			{ 
				token: token, 
				tokens-per-ticket-in-fixed: tokens-per-ticket-in-fixed, 
				registration-start-height: registration-start-height, 
				registration-end-height: registration-end-height 
			}
		)
		(var-set lottery-id-nonce (+ lottery-id u1))
		(ok lottery-id)
	)
)
(define-public (set-lottery-round (lottery-id uint) (round-id uint) (draw-height uint) (percent uint) (total-tickets uint) (payout-rate uint))
	(begin 
		(asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
		(ok (map-set lottery-round { lottery-id: lottery-id, round-id: round-id } { draw-height: draw-height, percent: percent, total-tickets: total-tickets, payout-rate: payout-rate, play: true }))
	)
)
(define-read-only (is-lottery-round-claimable (lottery-id uint) (round-id uint))
	(ok (get play (try! (get-lottery-round-or-fail lottery-id round-id))))
)
(define-private (calculate-max-step-size (tickets-registered uint) (total-tickets uint))
	(/ (* tickets-registered walk-resolution) total-tickets)
)
(define-private (next-bounds (lottery-id uint) (tickets uint))
	(let
		(
			(start (default-to u0 (map-get? start-indexes lottery-id)))
			(end (+ start (* tickets walk-resolution)))
		)
		(map-set start-indexes lottery-id end)
		{start: start, end: end}
	)
)
(define-read-only (get-lottery-id-nonce)
	(var-get lottery-id-nonce)
)
(define-read-only (get-lottery-or-fail (lottery-id uint))
	(ok (unwrap! (map-get? lottery lottery-id) ERR-UNKNOWN-LOTTERY))
)
(define-read-only (get-lottery-round-or-fail (lottery-id uint) (round-id uint))
	(ok (unwrap! (map-get? lottery-round { lottery-id: lottery-id, round-id: round-id }) ERR-UNKNOWN-LOTTERY-ROUND))
)
(define-read-only (get-total-tickets-registered-or-default (lottery-id uint))
	(default-to u0 (map-get? total-tickets-registered lottery-id))
)
(define-read-only (get-total-bonus-tickets-registered-or-default (lottery-id uint))
	(default-to u0 (map-get? total-bonus-tickets-registered lottery-id))
)
(define-read-only (get-ticket-bounds-or-fail (lottery-id uint) (owner principal))
	(ok (unwrap! (map-get? ticket-bounds {lottery-id: lottery-id, owner: owner}) ERR-NOT-REGISTERED))
)
(define-read-only (get-bonus-thresholds-or-default (index uint))
	(default-to u340282366920938463463374607431768211455 (element-at (var-get bonus-thresholds) index))
)
(define-read-only (get-bonus-max-or-default (index uint))
	(default-to u0 (element-at (var-get bonus-max) index))
)
(define-read-only (get-apower-per-bonus-in-fixed)
	(var-get apower-per-bonus-in-fixed)
)
(define-public (set-apower-per-bonus-in-fixed (new-amount uint))
	(begin 
		(try! (check-is-owner))
		(ok (var-set apower-per-bonus-in-fixed new-amount))
	)
)
(define-public (set-bonus-thresholds (new-thresholds (list 5 uint)))
	(begin 
		(try! (check-is-owner))
		(ok (var-set bonus-thresholds new-thresholds))
	)
)
(define-public (set-bonus-max (new-max (list 5 uint)))
	(begin 
		(try! (check-is-owner))
		(ok (var-set bonus-max new-max))
	)
)
(define-read-only (get-max-bonus-for-tickets (tickets uint))
	(if (>= tickets (get-bonus-thresholds-or-default u4))
		(get-bonus-max-or-default u4)
		(if (>= tickets (get-bonus-thresholds-or-default u3))
			(get-bonus-max-or-default u3)
			(if (>= tickets (get-bonus-thresholds-or-default u2))
				(get-bonus-max-or-default u2)
				(if (>= tickets (get-bonus-thresholds-or-default u1))
					(get-bonus-max-or-default u1)
					(if (>= tickets (get-bonus-thresholds-or-default u0))
						(get-bonus-max-or-default u0)
						u0
					)
				)
			)
		)
	)
)
(define-read-only (get-total-pot-in-fixed (lottery-id uint))
	(ok (* (get-total-tickets-registered-or-default lottery-id) (get tokens-per-ticket-in-fixed (try! (get-lottery-or-fail lottery-id)))))
)
(define-read-only (get-total-bonus-in-fixed (lottery-id uint))
	(ok (* (get-total-bonus-tickets-registered-or-default lottery-id) (get tokens-per-ticket-in-fixed (try! (get-lottery-or-fail lottery-id)))))
)
(define-public (register (lottery-id uint) (tickets uint) (token-trait <ft-trait>) (bonus-tickets uint))
	(let
		(
			(lotto (try! (get-lottery-or-fail lottery-id)))
			(bounds (next-bounds lottery-id (+ tickets bonus-tickets)))
			(sender tx-sender)
		)
		(asserts! (is-err (get-ticket-bounds-or-fail lottery-id sender)) ERR-ALREADY-REGISTERED)
		(asserts! (and (>= block-height (get registration-start-height lotto)) (< block-height (get registration-end-height lotto))) ERR-BLOCK-HEIGHT-NOT-REACHED)	
		(asserts! (is-eq (get token lotto) (contract-of token-trait)) ERR-INVALID-LOTTERY-TOKEN)		
		(asserts! (<= bonus-tickets (get-max-bonus-for-tickets tickets)) ERR-BONUS-TICKETS-EXCEED-MAX)
		(try! (contract-call? token-trait transfer-fixed (* (get tokens-per-ticket-in-fixed lotto) tickets) sender (as-contract tx-sender) none))
		(and 
			(> bonus-tickets u0) 
			(as-contract (try! (contract-call? .token-apower burn-fixed (* (var-get apower-per-bonus-in-fixed) bonus-tickets) sender)))
			(as-contract (try! (contract-call? token-trait mint-fixed (* (get tokens-per-ticket-in-fixed lotto) bonus-tickets) tx-sender)))
		)
		(map-set ticket-bounds {lottery-id: lottery-id, owner: sender} bounds)
		(map-set total-tickets-registered lottery-id (+ (get-total-tickets-registered-or-default lottery-id) (+ tickets bonus-tickets)))
		(map-set total-bonus-tickets-registered lottery-id (+ (get-total-bonus-tickets-registered-or-default lottery-id) bonus-tickets))
		(ok bounds)
	)
)
(define-read-only (get-lottery-walk-parameters (lottery-id uint) (round-id uint))
	(let
		(
			(round (try! (get-lottery-round-or-fail lottery-id round-id)))
			(max-step-size (calculate-max-step-size (get-total-tickets-registered-or-default lottery-id) (get total-tickets round)))
			(walk-position (lcg-next (try! (get-vrf-uint (get draw-height round))) max-step-size))
		)
		(ok {max-step-size: max-step-size, walk-position: walk-position, total-tickets: (get total-tickets round)})
	)
)
(define-private (verify-winner-iter (owner principal) (prior (response {owner: (optional principal), lottery-id: uint, bounds: {start: uint, end: uint}, walk-position: uint, max-step-size: uint} uint)))
	(let
		(
			(p (try! prior))
			(k {lottery-id: (get lottery-id p), owner: owner})
			(b (if (and (is-some (get owner p)) (is-eq (unwrap-panic (get owner p)) owner)) (get bounds p) (unwrap! (map-get? ticket-bounds k) ERR-NOT-REGISTERED)))
			(w (+ (* (+ u1 (/ (get walk-position p) walk-resolution)) walk-resolution) (lcg-next (get walk-position p) (get max-step-size p))))
		)
		(asserts! (and (>= (get walk-position p) (get start b)) (< (get walk-position p) (get end b))) ERR-INVALID-SEQUENCE)
		(ok (merge p { owner: (some owner), bounds: b, walk-position: w }))
	)
)
(define-public (claim (lottery-id uint) (round-id uint) (winners (list 200 principal)) (token-trait <ft-trait>))
	(let 
		(
			(lotto (try! (get-lottery-or-fail lottery-id)))
			(round (try! (get-lottery-round-or-fail lottery-id round-id)))
			(tickets-registered (get-total-tickets-registered-or-default lottery-id))
			(payout-gross (mul-down (* (get percent round) tickets-registered) (get tokens-per-ticket-in-fixed lotto)))
			(payout-net (mul-down payout-gross (get payout-rate round)))
			(max-step-size (calculate-max-step-size tickets-registered (get total-tickets round)))			
			(walk-position (lcg-next (try! (get-vrf-uint (get draw-height round))) max-step-size))
			(result (try! (fold verify-winner-iter winners (ok {owner: none, lottery-id: lottery-id, bounds: {start: u0, end: u0}, walk-position: walk-position, max-step-size: max-step-size}))))			
		)
		(asserts! (or (is-ok (check-is-owner)) (is-ok (check-is-approved))) ERR-NOT-AUTHORIZED)
		(asserts! (is-eq (get token lotto) (contract-of token-trait)) ERR-INVALID-LOTTERY-TOKEN)
		(asserts! (>= block-height (get registration-end-height lotto)) ERR-BLOCK-HEIGHT-NOT-REACHED)
		(asserts! (get play round) ERR-LOTTERY-ROUND-ALREADY-CLAIMED)
		(var-set tm-amount (/ payout-net (len winners)))
		(as-contract (try! (contract-call? token-trait transfer-fixed (- payout-gross payout-net) tx-sender (var-get contract-owner) none)))
		(fold transfer-many-iter winners token-trait)
		(map-set lottery-round { lottery-id: lottery-id, round-id: round-id } (merge round { play: false }))
		(ok { gross: payout-gross, net: payout-net, tax: (- payout-gross payout-net), payout: (var-get tm-amount) })
	)
)
(define-data-var tm-amount uint u0)
(define-private (transfer-many-iter (recipient principal) (token-trait <ft-trait>))
	(begin
		(unwrap-panic (as-contract (contract-call? token-trait transfer-fixed (var-get tm-amount) tx-sender recipient none)))
		token-trait
	)
)
(define-public (transfer-all-to-owner (token-trait <ft-trait>))
	(let 
		(
			(balance (try! (contract-call? token-trait get-balance-fixed (as-contract tx-sender))))
		)
		(try! (check-is-owner))
		(and (> balance u0) (as-contract (try! (contract-call? token-trait transfer-fixed balance tx-sender (var-get contract-owner) none))))
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
	(ok (buff-to-uint64 (unwrap! (get-block-info? vrf-seed height) ERR-BLOCK-HEIGHT-NOT-REACHED)))
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
(define-public (set-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner owner))
	)
)
(define-private (check-is-owner)
	(ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-private (check-is-approved)
	(ok (asserts! (default-to false (map-get? approved-operators tx-sender)) ERR-NOT-AUTHORIZED))
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
(set-contract-owner .executor-dao)