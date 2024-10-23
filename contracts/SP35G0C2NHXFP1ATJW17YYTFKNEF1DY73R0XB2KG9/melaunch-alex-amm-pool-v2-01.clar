;; melaunch
;;
;; 1. user `create-pool` with token specification (name/symbol/uri) that configures a pre-approved token contract (token-x) and,
;;    a choice of base token (token-y).
;;    `listing-fee` in token-y (abs amount, e.g. 2 STX) is deducted.
;; 2. pool is created with a balance of "actual" `MAX_SUPPLY` token-x (`balance-x`) and "virtual" `initial-y` token-y (`balance-y-vir`).
;;    The pool contains zero "actual" token-y (`balance-y-act`).
;; 3. users can call `swap-x-for-y` (i.e. sell token-x buy token-y) subject to `balance-y-act` >= dy.
;;    Therefore, `swap-y-for-x` must precede `swap-x-for-y`.
;;    Swap is subject to `swap-fee` in token-y (% amount, e.g. 1%).
;; 4. `swap-y-for-x` triggers a creation of amm pool on ALEX, if the updated `balance-y` exceeds `amm-threshold`.
;;    `balance-x` and `balance-y-act` (net of amm fee) are injected into the amm pool and immediately open for trading.
;;    amm pool creation is subject to `amm fee` in token-y (abs amount, e.g. 100 STX).
;; 5. once the pool moves to ALEX amm, it no longer is available on melaunch.

(use-trait ft-trait-configurable 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010-configurable.sip-010-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-POOL-ALREADY-EXISTS (err u2000))
(define-constant ERR-INVALID-POOL (err u2001))
(define-constant ERR-INVALID-LIQUIDITY (err u2003))
(define-constant ERR-INVALID-TOKEN (err u2004))
(define-constant ERR-PERCENT-GREATER-THAN-ONE (err u2005))
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2006))
(define-constant ERR-PAUSED (err u2007))
(define-constant ERR-NO-LIQUIDITY (err u2008))
(define-constant ERR-POOL-ALREADY-LAUNCHED (err u2009))

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_SUPPLY (* u1000000000 ONE_8))

(define-data-var contract-owner principal tx-sender)
(define-data-var fee-address principal tx-sender)

(define-data-var pool-nonce uint u0)
(define-data-var paused bool true)

(define-map pools-id-map uint { token-x: principal, token-y: principal })
(define-map pools-data-map { token-x: principal, token-y: principal } { pool-id: uint, balance-x: uint, balance-y-act: uint, balance-y-vir: uint })

(define-data-var swap-fee uint u0)

(define-map approved-token-x principal bool)
(define-map approved-token-y principal { initial-y: uint, listing-fee: uint, amm-threshold: uint, amm-fee: uint })

;; read-only calls

(define-read-only (get-contract-owner)
	(var-get contract-owner))

(define-read-only (get-swap-fee)
	(var-get swap-fee))

(define-read-only (get-fee-address)
	(var-get fee-address))

(define-read-only (get-pool-details-by-id (pool-id uint))
    (ok (unwrap! (map-get? pools-id-map pool-id) ERR-INVALID-POOL)))

(define-read-only (get-pool-details (token-x principal) (token-y principal))
    (ok (unwrap! (get-pool-exists token-x token-y) ERR-INVALID-POOL)))

(define-read-only (get-pool-exists (token-x principal) (token-y principal))
    (map-get? pools-data-map { token-x: token-x, token-y: token-y }))

(define-read-only (get-approved-token-x-or-fail (token-x principal))
    (ok (unwrap! (map-get? approved-token-x token-x) ERR-INVALID-TOKEN)))

(define-read-only (get-approved-token-y-or-fail (token-y principal))
	(ok (unwrap! (map-get? approved-token-y token-y) ERR-INVALID-TOKEN)))

(define-read-only (is-paused)
	(var-get paused))

(define-read-only (get-pool-launched (token-x principal) (token-y principal))
	(match (get-pool-details token-x token-y)
		ok-value (and (is-eq u0 (get balance-x ok-value)) (is-eq u0 (get balance-y-act ok-value)) (is-eq u0 (get balance-y-vir ok-value)))
		err-value false))

(define-read-only (get-balances (token-x principal) (token-y principal))
	(let (
			(pool (try! (get-pool-details token-x token-y))))
		(ok {balance-x: (get balance-x pool), balance-y-act: (get balance-y-act pool), balance-y-vir: (get balance-y-vir pool)})))

(define-read-only (get-price (token-x principal) (token-y principal))
	(let (
			(pool (try! (get-pool-details token-x token-y))))
		(ok (get-price-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool))))))

(define-read-only (get-y-given-x (token-x principal) (token-y principal) (dx uint))
	(let (
			(pool (try! (get-pool-details token-x token-y)))
			(dy (get-y-given-x-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) dx)))
		;; (asserts! (< dx (get balance-x pool)) ERR-INVALID-LIQUIDITY)
		(asserts! (< dy (get balance-y-act pool)) ERR-INVALID-LIQUIDITY)
		(ok dy)))

(define-read-only (get-x-given-y (token-x principal) (token-y principal) (dy uint))
	(let (
			(pool (try! (get-pool-details token-x token-y)))
			(dx (get-x-given-y-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) dy)))
		;; (asserts! (< dy (+ (get balance-y-act pool) (get balance-y-vir pool))) ERR-INVALID-LIQUIDITY)
		(asserts! (< dx (get balance-x pool)) ERR-INVALID-LIQUIDITY)
		(ok dx)))

(define-read-only (get-y-in-given-x-out (token-x principal) (token-y principal) (dx uint))
	(let (
			(pool (try! (get-pool-details token-x token-y)))
			(dy (get-y-in-given-x-out-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) dx)))
		;; (asserts! (< dy (+ (get balance-y-act pool) (get balance-y-vir pool))) ERR-INVALID-LIQUIDITY)
		(asserts! (< dx (get balance-x pool)) ERR-INVALID-LIQUIDITY)
		(ok dy)))

(define-read-only (get-x-in-given-y-out (token-x principal) (token-y principal) (dy uint))
	(let (
			(pool (try! (get-pool-details token-x token-y)))
			(dx (get-x-in-given-y-out-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) dy)))
		;; (asserts! (< dx (get balance-x pool)) ERR-INVALID-LIQUIDITY)
		(asserts! (< dy (get balance-y-act pool)) ERR-INVALID-LIQUIDITY)
		(ok dx)))

(define-read-only (get-x-given-price (token-x principal) (token-y principal) (price uint))
	(let (
			(pool (try! (get-pool-details token-x token-y))))
		(asserts! (< price (get-price-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)))) ERR-NO-LIQUIDITY)
		(ok (get-x-given-price-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) price))))

(define-read-only (get-y-given-price (token-x principal) (token-y principal) (price uint))
	(let (
			(pool (try! (get-pool-details token-x token-y))))
		(asserts! (> price (get-price-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)))) ERR-NO-LIQUIDITY)
		(ok (get-y-given-price-internal (get balance-x pool) (+ (get balance-y-act pool) (get balance-y-vir pool)) price))))

(define-read-only (get-helper (token-x principal) (token-y principal) (dx uint))
	(if (is-some (get-pool-exists token-x token-y))
		(get-y-given-x token-x token-y dx)
		(get-x-given-y token-y token-x dx)))

;; governance calls

(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set contract-owner new-contract-owner))))

(define-public (pause (new-paused bool))
	(begin
		(try! (check-is-owner))
		(ok (var-set paused new-paused))))

(define-public (set-swap-fee (new-swap-fee uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= new-swap-fee ONE_8) ERR-PERCENT-GREATER-THAN-ONE)
		(ok (var-set swap-fee new-swap-fee))))

(define-public (set-fee-address (new-fee-address principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set fee-address new-fee-address))))

(define-public (set-approved-token-y (token-y principal) (approved bool) (details { initial-y: uint, listing-fee: uint, amm-threshold: uint, amm-fee: uint }))
    (begin
        (try! (check-is-owner))
        (if approved
            (ok (map-set approved-token-y token-y details))
            (ok (map-delete approved-token-y token-y)))))

(define-public (set-approved-token-x (token { token-x: principal, approved: bool }))
    (begin
        (try! (check-is-owner))
		(print {object: "pool", action: "set-approved-token-x", token: token})
        (ok (map-set approved-token-x (get token-x token) (get approved token)))))

(define-public (set-approved-token-x-many (tokens (list 1000 { token-x: principal, approved: bool })))
	(ok (map set-approved-token-x tokens)))

;; priviliged calls

;; public calls

(define-public (create-pool-and-buy (token-x-trait <ft-trait-configurable>) (token-x-name (string-ascii 32)) (token-x-symbol (string-ascii 10)) (token-x-uri (optional (string-utf8 256))) (token-y-trait <ft-trait>) (dy uint))
	(begin
		(try! (create-pool token-x-trait token-x-name token-x-symbol token-x-uri token-y-trait))
		(swap-y-for-x token-x-trait token-y-trait dy none)))

(define-public (create-pool (token-x-trait <ft-trait-configurable>) (token-x-name (string-ascii 32)) (token-x-symbol (string-ascii 10)) (token-x-uri (optional (string-utf8 256))) (token-y-trait <ft-trait>))
    (let (
            (pool-id (+ (var-get pool-nonce) u1))
            (token-x (contract-of token-x-trait))
            (token-y (contract-of token-y-trait))
            (token-x-approved (try! (get-approved-token-x-or-fail token-x)))
            (token-y-details (try! (get-approved-token-y-or-fail token-y)))
            (pool-data { pool-id: pool-id, balance-x: MAX_SUPPLY, balance-y-act: u0, balance-y-vir: (get initial-y token-y-details) }))
		(asserts! (not (is-paused)) ERR-PAUSED)
        (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-data)
        (map-set pools-id-map pool-id { token-x: token-x, token-y: token-y })
        (var-set pool-nonce pool-id)
		(as-contract (try! (contract-call? token-x-trait initialize token-x-name token-x-symbol token-x-uri MAX_SUPPLY)))
		(and (> (get listing-fee token-y-details) u0) (try! (contract-call? token-y-trait transfer-fixed (get listing-fee token-y-details) tx-sender (var-get fee-address) none)))

        (print { object: "pool", action: "created", data: pool-data, token-x: token-x, token-y: token-y, token-x-name: token-x-name, token-x-symbol: token-x-symbol, token-x-uri: token-x-uri })
        (ok true)))

(define-public (swap-x-for-y (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
    (let (
            (token-x (contract-of token-x-trait))
            (token-y (contract-of token-y-trait))
            (pool (try! (get-pool-details token-x token-y)))
            (balance-x (get balance-x pool))
            (balance-y (+ (get balance-y-act pool) (get balance-y-vir pool)))
            (dy (try! (get-y-given-x token-x token-y dx)))
			(fee (mul-down dy (var-get swap-fee)))
			(dy-net-fees (- dy fee))
            (pool-updated (merge pool { balance-x: (+ balance-x dx), balance-y-act: (- (get balance-y-act pool) dy) }))
            (sender tx-sender))
        (asserts! (not (is-paused)) ERR-PAUSED)
		(asserts! (not (get-pool-launched token-x token-y)) ERR-POOL-ALREADY-LAUNCHED)
        (asserts! (> dx u0) ERR-INVALID-LIQUIDITY)
        (asserts! (<= (div-down dy dx) (get-price-internal balance-x balance-y)) ERR-INVALID-LIQUIDITY)
        (asserts! (<= (default-to u0 min-dy) dy-net-fees) ERR-EXCEEDS-MAX-SLIPPAGE)
        (try! (contract-call? token-x-trait transfer-fixed dx sender (as-contract tx-sender) none))
        (and (> dy-net-fees u0) (as-contract (try! (contract-call? token-y-trait transfer-fixed dy-net-fees tx-sender sender none))))
		(and (> fee u0) (as-contract (try! (contract-call? token-y-trait transfer-fixed fee tx-sender (var-get fee-address) none))))
        (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-updated)
        (print { object: "pool", action: "swap-x-for-y", data: pool-updated, dx: dx, dy: dy, token-x: token-x, token-y: token-y, sender: sender, fee: fee, dy-net-fees: dy-net-fees })
        (ok {dx: dx, dy: dy-net-fees})))

(define-public (swap-y-for-x (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dy uint) (min-dx (optional uint)))
    (let (
            (token-x (contract-of token-x-trait))
            (token-y (contract-of token-y-trait))
            (pool (try! (get-pool-details token-x token-y)))
            (balance-x (get balance-x pool))
            (balance-y (+ (get balance-y-act pool) (get balance-y-vir pool)))
            (fee (mul-up dy (var-get swap-fee)))
            (dy-net-fees (- dy fee))
            (dx (try! (get-x-given-y token-x token-y dy-net-fees)))
            (pool-updated (merge pool { balance-x: (- balance-x dx), balance-y-act: (+ (get balance-y-act pool) dy-net-fees) }))
            (sender tx-sender)
			(token-y-details (try! (get-approved-token-y-or-fail token-y))))
        (asserts! (not (is-paused)) ERR-PAUSED)
		(asserts! (not (get-pool-launched token-x token-y)) ERR-POOL-ALREADY-LAUNCHED)
        (asserts! (> dy u0) ERR-INVALID-LIQUIDITY)
        (asserts! (>= (div-down dy dx) (get-price-internal balance-x balance-y)) ERR-INVALID-LIQUIDITY)
        (asserts! (<= (default-to u0 min-dx) dx) ERR-EXCEEDS-MAX-SLIPPAGE)
		(and (> dx u0) (as-contract (try! (contract-call? token-x-trait transfer-fixed dx tx-sender sender none))))
        (and (> dy-net-fees u0) (try! (contract-call? token-y-trait transfer-fixed dy-net-fees sender (as-contract tx-sender) none)))
		(and (> fee u0) (try! (contract-call? token-y-trait transfer-fixed fee sender (var-get fee-address) none)))
        (map-set pools-data-map { token-x: token-x, token-y: token-y } pool-updated)
        (print { object: "pool", action: "swap-y-for-x", data: pool-updated, dx: dx, dy: dy, token-x: token-x, token-y: token-y, sender: sender, fee: fee, dy-net-fees: dy-net-fees })
		(and
			(< (get amm-threshold token-y-details) (+ (get balance-y-act pool-updated) (get balance-y-vir pool-updated)))
			(begin
				(and (> (get amm-fee token-y-details) u0) (as-contract (try! (contract-call? token-y-trait transfer-fixed (get amm-fee token-y-details) tx-sender (var-get fee-address) none))))
				(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-02 request-create-and-finalize
					{
						token-x: token-y, token-y: token-x, factor: ONE_8,
						bal-x: (- (get balance-y-act pool-updated) (get amm-fee token-y-details)), bal-y: (get balance-x pool-updated),
						fee-rate-x: u500000, fee-rate-y: u500000,
						max-in-ratio: u60000000, max-out-ratio: u60000000,
						threshold-x: u0, threshold-y: u0,
						oracle-enabled: true, oracle-average: u99000000,
						start-block: u0,
						memo: none
					}
					token-y-trait token-x-trait)))
				(print { object: "pool", action: "move-to-amm", pool-id: (get pool-id pool-updated)})
				(map-set pools-data-map { token-x: token-x, token-y: token-y } (merge pool-updated { balance-x: u0, balance-y-act: u0, balance-y-vir: u0 }))))
				
        (ok {dx: dx, dy: dy-net-fees})))

(define-public (swap-helper (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (dx uint) (min-dy (optional uint)))
	(if (is-some (get-pool-exists (contract-of token-x-trait) (contract-of token-y-trait)))
		(ok (get dy (try! (swap-x-for-y token-x-trait token-y-trait dx min-dy))))
		(ok (get dx (try! (swap-y-for-x token-y-trait token-x-trait dx min-dy))))))

;; private calls

(define-private (check-is-owner)
    (ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED)))

(define-private (get-price-internal (balance-x uint) (balance-y uint))
    (div-down balance-y balance-x))

(define-private (get-y-given-x-internal (balance-x uint) (balance-y uint) (dx uint))
    (div-down (mul-down dx balance-y) (+ balance-x dx)))

(define-private (get-x-given-y-internal (balance-x uint) (balance-y uint) (dy uint))
    (div-down (mul-down dy balance-x) (+ balance-y dy)))

(define-private (get-y-in-given-x-out-internal (balance-x uint) (balance-y uint) (dx uint))
    (div-down (mul-down dx balance-y) (- balance-x dx)))

(define-private (get-x-in-given-y-out-internal (balance-x uint) (balance-y uint) (dy uint))
    (div-down (mul-down dy balance-x) (- balance-y dy)))

(define-private (get-x-given-price-internal (balance-x uint) (balance-y uint) (price uint))
    (let (
            (power (pow-down (div-down (get-price-internal balance-x balance-y) price) u50000000)))
        (mul-down balance-x (if (<= power ONE_8) u0 (- power ONE_8)))))

(define-private (get-y-given-price-internal (balance-x uint) (balance-y uint) (price uint))
    (let (
            (power (pow-down (div-down price (get-price-internal balance-x balance-y)) u50000000)))
        (mul-down balance-y (if (<= power ONE_8) u0 (- power ONE_8)))))

(define-constant MAX_POW_RELATIVE_ERROR u4)

(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))

(define-private (mul-up (a uint) (b uint))
	(let (
			(product (* a b))
		)
		(if (is-eq product u0) u0 (+ u1 (/ (- product u1) ONE_8)))))

(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (div-up (a uint) (b uint))
	(if (is-eq a u0) u0 (+ u1 (/ (- (* a ONE_8) u1) b))))

(define-private (pow-down (a uint) (b uint))
	(let (
			(raw (unwrap-panic (pow-fixed a b)))
			(max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
		)
		(if (< raw max-error) u0 (- raw max-error))))

(define-private (pow-up (a uint) (b uint))
	(let (
			(raw (unwrap-panic (pow-fixed a b)))
			(max-error (+ u1 (mul-up raw MAX_POW_RELATIVE_ERROR)))
		)
		(+ raw max-error)))

(define-constant UNSIGNED_ONE_8 (pow 10 8))
(define-constant MAX_NATURAL_EXPONENT (* 69 UNSIGNED_ONE_8))
(define-constant MIN_NATURAL_EXPONENT (* -18 UNSIGNED_ONE_8))
(define-constant MILD_EXPONENT_BOUND (/ (pow u2 u126) (to-uint UNSIGNED_ONE_8)))
(define-constant x_a_list_no_deci (list {x_pre: 6400000000, a_pre: 62351490808116168829, use_deci: false} ))

(define-constant x_a_list (list
	{x_pre: 3200000000, a_pre: 78962960182680695161, use_deci: true} ;; x2 = 2^5, a2 = e^(x2)
	{x_pre: 1600000000, a_pre: 888611052050787, use_deci: true} ;; x3 = 2^4, a3 = e^(x3)
	{x_pre: 800000000, a_pre: 298095798704, use_deci: true} ;; x4 = 2^3, a4 = e^(x4)
	{x_pre: 400000000, a_pre: 5459815003, use_deci: true} ;; x5 = 2^2, a5 = e^(x5)
	{x_pre: 200000000, a_pre: 738905610, use_deci: true} ;; x6 = 2^1, a6 = e^(x6)
	{x_pre: 100000000, a_pre: 271828183, use_deci: true} ;; x7 = 2^0, a7 = e^(x7)
	{x_pre: 50000000, a_pre: 164872127, use_deci: true} ;; x8 = 2^-1, a8 = e^(x8)
	{x_pre: 25000000, a_pre: 128402542, use_deci: true} ;; x9 = 2^-2, a9 = e^(x9)
	{x_pre: 12500000, a_pre: 113314845, use_deci: true} ;; x10 = 2^-3, a10 = e^(x10)
	{x_pre: 6250000, a_pre: 106449446, use_deci: true} ;; x11 = 2^-4, a11 = e^x(11)
))

(define-constant ERR-X-OUT-OF-BOUNDS (err u5009))
(define-constant ERR-Y-OUT-OF-BOUNDS (err u5010))
(define-constant ERR-PRODUCT-OUT-OF-BOUNDS (err u5011))
(define-constant ERR-INVALID-EXPONENT (err u5012))
(define-constant ERR-OUT-OF-BOUNDS (err u5013))

(define-private (ln-priv (a int))
	(let (
			(a_sum_no_deci (fold accumulate_division x_a_list_no_deci {a: a, sum: 0}))
			(a_sum (fold accumulate_division x_a_list {a: (get a a_sum_no_deci), sum: (get sum a_sum_no_deci)}))
			(out_a (get a a_sum))
			(out_sum (get sum a_sum))
			(z (/ (* (- out_a UNSIGNED_ONE_8) UNSIGNED_ONE_8) (+ out_a UNSIGNED_ONE_8)))
			(z_squared (/ (* z z) UNSIGNED_ONE_8))
			(div_list (list 3 5 7 9 11))
			(num_sum_zsq (fold rolling_sum_div div_list {num: z, seriesSum: z, z_squared: z_squared}))
			(seriesSum (get seriesSum num_sum_zsq))
		)
		(+ out_sum (* seriesSum 2))))

(define-private (accumulate_division (x_a_pre (tuple (x_pre int) (a_pre int) (use_deci bool))) (rolling_a_sum (tuple (a int) (sum int))))
	(let (
			(a_pre (get a_pre x_a_pre))
			(x_pre (get x_pre x_a_pre))
			(use_deci (get use_deci x_a_pre))
			(rolling_a (get a rolling_a_sum))
			(rolling_sum (get sum rolling_a_sum))
		)
		(if (>= rolling_a (if use_deci a_pre (* a_pre UNSIGNED_ONE_8)))
				{a: (/ (* rolling_a (if use_deci UNSIGNED_ONE_8 1)) a_pre), sum: (+ rolling_sum x_pre)}
				{a: rolling_a, sum: rolling_sum})))

(define-private (rolling_sum_div (n int) (rolling (tuple (num int) (seriesSum int) (z_squared int))))
	(let (
			(rolling_num (get num rolling))
			(rolling_sum (get seriesSum rolling))
			(z_squared (get z_squared rolling))
			(next_num (/ (* rolling_num z_squared) UNSIGNED_ONE_8))
			(next_sum (+ rolling_sum (/ next_num n)))
		)
		{num: next_num, seriesSum: next_sum, z_squared: z_squared}))

(define-private (pow-priv (x uint) (y uint))
    (let (
            (x-int (to-int x))
            (y-int (to-int y))
            (lnx (ln-priv x-int))
            (logx-times-y (/ (* lnx y-int) UNSIGNED_ONE_8)))
        (asserts! (and (<= MIN_NATURAL_EXPONENT logx-times-y) (<= logx-times-y MAX_NATURAL_EXPONENT)) ERR-PRODUCT-OUT-OF-BOUNDS)
        (ok (to-uint (try! (exp-fixed logx-times-y))))))

(define-private (exp-pos (x int))
	(begin
		(asserts! (and (<= 0 x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
		(let (
				(x_product_no_deci (fold accumulate_product x_a_list_no_deci {x: x, product: 1}))
				(x_adj (get x x_product_no_deci))
				(firstAN (get product x_product_no_deci))
				(x_product (fold accumulate_product x_a_list {x: x_adj, product: UNSIGNED_ONE_8}))
				(product_out (get product x_product))
				(x_out (get x x_product))
				(seriesSum (+ UNSIGNED_ONE_8 x_out))
				(div_list (list 2 3 4 5 6 7 8 9 10 11 12))
				(term_sum_x (fold rolling_div_sum div_list {term: x_out, seriesSum: seriesSum, x: x_out}))
				(sum (get seriesSum term_sum_x)))
			(ok (* (/ (* product_out sum) UNSIGNED_ONE_8) firstAN)))))

(define-private (accumulate_product (x_a_pre (tuple (x_pre int) (a_pre int) (use_deci bool))) (rolling_x_p (tuple (x int) (product int))))
	(let (
			(x_pre (get x_pre x_a_pre))
			(a_pre (get a_pre x_a_pre))
			(use_deci (get use_deci x_a_pre))
			(rolling_x (get x rolling_x_p))
			(rolling_product (get product rolling_x_p)))
		(if (>= rolling_x x_pre)
			{x: (- rolling_x x_pre), product: (/ (* rolling_product a_pre) (if use_deci UNSIGNED_ONE_8 1))}
			{x: rolling_x, product: rolling_product})))

(define-private (rolling_div_sum (n int) (rolling (tuple (term int) (seriesSum int) (x int))))
	(let (
			(rolling_term (get term rolling))
			(rolling_sum (get seriesSum rolling))
			(x (get x rolling))
			(next_term (/ (/ (* rolling_term x) UNSIGNED_ONE_8) n))
			(next_sum (+ rolling_sum next_term))
		)
		{term: next_term, seriesSum: next_sum, x: x}))

(define-private (pow-fixed (x uint) (y uint))
	(begin
		(asserts! (< x (pow u2 u127)) ERR-X-OUT-OF-BOUNDS)
		(asserts! (< y MILD_EXPONENT_BOUND) ERR-Y-OUT-OF-BOUNDS)
		(if (is-eq y u0)
			(ok (to-uint UNSIGNED_ONE_8))
			(if (is-eq x u0) (ok u0) (pow-priv x y)))))

(define-private (exp-fixed (x int))
	(begin
		(asserts! (and (<= MIN_NATURAL_EXPONENT x) (<= x MAX_NATURAL_EXPONENT)) ERR-INVALID-EXPONENT)
		(if (< x 0) (ok (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) (try! (exp-pos (* -1 x))))) (exp-pos x))))

(define-private (log-fixed (arg int) (base int))
	(let (
			(logBase (* (ln-priv base) UNSIGNED_ONE_8))
			(logArg (* (ln-priv arg) UNSIGNED_ONE_8)))
		(ok (/ (* logArg UNSIGNED_ONE_8) logBase))))

(define-private (ln-fixed (a int))
	(begin
		(asserts! (> a 0) ERR-OUT-OF-BOUNDS)
		(if (< a UNSIGNED_ONE_8) (ok (- 0 (ln-priv (/ (* UNSIGNED_ONE_8 UNSIGNED_ONE_8) a)))) (ok (ln-priv a)))))
