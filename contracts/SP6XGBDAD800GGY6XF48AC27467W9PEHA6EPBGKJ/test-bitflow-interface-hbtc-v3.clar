;; @contract Bitflow Interface
;; @version 0.1

(use-trait ft 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait xyk-pool 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait stableswap-core .test-bitflow-traits-v1.stableswap-core-trait)
(use-trait xyk-core .test-bitflow-traits-v1.xyk-core-trait)
(use-trait swap-helper .test-bitflow-traits-v1.swap-helper-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_XYK_DISABLED (err u113001))
(define-constant ERR_STALE_PRICE (err u113002))
(define-constant ERR_SWAP_DISABLED (err u113003))
(define-constant ERR_INVALID_AMOUNT (err u113004))
(define-constant ERR_INSUFFICIENT_BALANCE (err u113005))

(define-constant bps-base (pow u10 u4))
(define-constant price-base (pow u10 u8))

(define-constant this-contract (as-contract tx-sender))
(define-constant reserve .test-reserve-hbtc-v3)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var swap-active bool false)
(define-data-var xyk-active bool false)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-xyk-active)
  (var-get xyk-active)
)

(define-read-only (get-swap-active)
  (var-get swap-active)
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-xyk-active)
  (begin
    (asserts! (var-get swap-active) ERR_SWAP_DISABLED)
    (ok (asserts! (var-get xyk-active) ERR_XYK_DISABLED))
  )
)

(define-read-only (check-is-swap-active)
  (ok (asserts! (var-get swap-active) ERR_SWAP_DISABLED))
)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (bitflow-stable-swap-x-for-y
  (core-trait <stableswap-core>)
  (pool-trait <stableswap-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (x-amount uint) (min-dy-input uint)
  )
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (check-is-swap-active))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of core-trait) (some (contract-of pool-trait)) (some (contract-of x-token-trait)) (some (contract-of y-token-trait))))

    (try! (contract-call? .test-reserve-hbtc-v3 transfer x-token-trait x-amount this-contract))
    (let (
      (min-dy (calculate-min-output-stableswap x-token-trait y-token-trait x-amount min-dy-input))
      (dy (try! (as-contract (contract-call? core-trait swap-x-for-y pool-trait x-token-trait y-token-trait x-amount min-dy))))
    )
      (try! (as-contract (contract-call? y-token-trait transfer dy this-contract reserve none)))
      (print { action: "bitflow-stable-swap-x-for-y", user: contract-caller, data: { core: core-trait, pool: pool-trait, x-token: x-token-trait, y-token: y-token-trait, x-amount: x-amount, min-dy: min-dy, dy-returned: dy } })
      (ok dy)
    )
  )
)

(define-public (bitflow-stable-swap-y-for-x
  (core-trait <stableswap-core>)
  (pool-trait <stableswap-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (y-amount uint) (min-dx-input uint)
  )
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (check-is-swap-active))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of core-trait) (some (contract-of pool-trait)) (some (contract-of x-token-trait)) (some (contract-of y-token-trait))))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer y-token-trait y-amount this-contract))
    (let (
      (min-dx (calculate-min-output-stableswap y-token-trait x-token-trait y-amount min-dx-input))
      (dx (try! (as-contract (contract-call? core-trait swap-y-for-x pool-trait x-token-trait y-token-trait y-amount min-dx))))
    )
      (try! (as-contract (contract-call? x-token-trait transfer dx this-contract reserve none)))
      (print { action: "bitflow-stable-swap-y-for-x", user: contract-caller, data: { core: core-trait, pool: pool-trait, x-token: x-token-trait, y-token: y-token-trait, y-amount: y-amount, min-dx: min-dx, dx-returned: dx } })
      (ok dx)
    )
  )
)

(define-public (bitflow-xyk-swap-x-for-y
  (core-trait <xyk-core>)
  (pool-trait <xyk-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (x-amount uint) (min-dy-input uint)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192)))
  )
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (check-is-xyk-active))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of core-trait) (some (contract-of pool-trait)) (some (contract-of x-token-trait)) (some (contract-of y-token-trait))))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer x-token-trait x-amount this-contract))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (let (
      (min-dy (try! (calculate-min-output-xyk x-token-trait y-token-trait x-amount min-dy-input)))
      (dy (try! (as-contract (contract-call? core-trait swap-x-for-y pool-trait x-token-trait y-token-trait x-amount min-dy))))
    )
      (try! (as-contract (contract-call? y-token-trait transfer dy this-contract reserve none)))
      (print { action: "bitflow-xyk-swap-x-for-y", user: contract-caller, data: { core: core-trait, pool: pool-trait, x-token: x-token-trait, y-token: y-token-trait, x-amount: x-amount, min-dy: min-dy, dy-returned: dy } })
      (ok dy)
    )
  )
)

(define-public (bitflow-xyk-swap-y-for-x
  (core-trait <xyk-core>)
  (pool-trait <xyk-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (y-amount uint) (min-dx-input uint)
  (price-feed-1 (optional (buff 8192)))
  (price-feed-2 (optional (buff 8192)))
  )
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (check-is-xyk-active))
    (try! (contract-call? .test-state-hbtc-v3 check-trading-auth (contract-of core-trait) (some (contract-of pool-trait)) (some (contract-of x-token-trait)) (some (contract-of y-token-trait))))
    (try! (contract-call? .test-reserve-hbtc-v3 transfer y-token-trait y-amount this-contract))
    (try! (write-feed price-feed-1))
    (try! (write-feed price-feed-2))
    (let (
      (min-dx (try! (calculate-min-output-xyk y-token-trait x-token-trait y-amount min-dx-input)))
      (dx (try! (as-contract (contract-call? core-trait swap-y-for-x pool-trait x-token-trait y-token-trait y-amount min-dx))))
    )
      (try! (as-contract (contract-call? x-token-trait transfer dx this-contract reserve none)))
      (print { action: "bitflow-xyk-swap-y-for-x", user: contract-caller, data: { core: core-trait, pool: pool-trait, x-token: x-token-trait, y-token: y-token-trait, y-amount: y-amount, min-dx: min-dx, dx-returned: dx } })
      (ok dx)
    )
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

;; Private function to calculate minimum output amount for stable swaps using direct token ratio without Pyth
(define-private (calculate-min-output-stableswap
  (input-token-trait <ft>) (output-token-trait <ft>)
  (input-amount uint)
  (min-output-arg uint))
  (let (
    (input-token-data (contract-call? .test-state-hbtc-v3 get-asset (contract-of input-token-trait)))
    (max-slippage (get max-slippage input-token-data))
    (output-token-base (get token-base (contract-call? .test-state-hbtc-v3 get-asset (contract-of output-token-trait))))
    (expected-output-amount (/ (* input-amount output-token-base) (get token-base input-token-data)))
    (min-output-calc (/ (* expected-output-amount (- bps-base max-slippage)) bps-base))
  )
    (if (> min-output-calc min-output-arg) min-output-calc min-output-arg)
  )
)

;; Helper function to get price data - returns mock data for stablecoins or real Pyth data
(define-private (get-price-data (is-stablecoin bool) (price-feed-id (buff 32)))
  (if is-stablecoin
    ;; Return fixed $1.00 price for stablecoins
    (ok {
      price: 100000000,               ;; $1.00 with 8 decimal places
      conf: u0,                       ;; No confidence interval for fixed price
      expo: -8,                       ;; 8 decimal places
      ema-price: 100000000,           ;; Same as price for stablecoins
      ema-conf: u0,                   ;; No confidence for fixed price
      publish-time: (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))), ;; last stacks timestamp to bypass staleness check
      prev-publish-time: u0           ;; Not relevant for fixed price
    })
    ;; Use real Pyth oracle data for other assets
    (contract-call? 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-storage-v4 get-price price-feed-id)
  )
)

;; Helper function to check if price data is stale
(define-private (check-is-price-stale (publish-time uint))
  (let (
    (block-delay (contract-call? .test-state-hbtc-v3 get-block-delay))
    (min-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height block-delay))))
  )
    (ok (asserts! (>= publish-time min-timestamp) ERR_STALE_PRICE))
  )
)

;; Private function to calculate minimum output amount with Pyth-based slippage protection
(define-private (calculate-min-output-xyk
  (input-token-trait <ft>) (output-token-trait <ft>)
  (input-amount uint)
  (min-output-arg uint))
  (let (
    (input-token-data (contract-call? .test-state-hbtc-v3 get-asset (contract-of input-token-trait)))
    (output-token-data (contract-call? .test-state-hbtc-v3 get-asset (contract-of output-token-trait)))
    (max-slippage (get max-slippage input-token-data))
    (input-price-data (try! (get-price-data (get is-stablecoin input-token-data) (get price-feed-id input-token-data))))
    (output-price-data (try! (get-price-data (get is-stablecoin output-token-data) (get price-feed-id output-token-data))))
    (input-ema-price (to-uint (get ema-price input-price-data)))
    (output-ema-price (to-uint (get ema-price output-price-data)))
    (input-price-base (pow u10 (to-uint (* -1 (get expo input-price-data)))))
    (output-price-base (pow u10 (to-uint (* -1 (get expo output-price-data)))))
    ;; Normalize prices to 8 decimals for USD price calculation
    (normalized-input-price (/ (* input-ema-price price-base) input-price-base))
    (normalized-output-price (/ (* output-ema-price price-base) output-price-base))
    ;; Calculate expected output based on USD prices with slippage protection
    (input-amount-usd (/ (* input-amount normalized-input-price) (get token-base input-token-data)))
    (expected-output-amount (/ (* input-amount-usd (get token-base output-token-data)) normalized-output-price))
    (min-output-calc (/ (* expected-output-amount (- bps-base max-slippage)) bps-base))
  )
    (try! (check-is-price-stale (get publish-time input-price-data)))
    (try! (check-is-price-stale (get publish-time output-price-data)))
    (ok (if (> min-output-calc min-output-arg) min-output-calc min-output-arg))
  )
)

(define-private (write-feed (price-feed (optional (buff 8192))))
  (match price-feed bytes 
    (begin
      (try! (contract-call? 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-oracle-v4 verify-and-update-price-feeds
        bytes
        {
          pyth-storage-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-storage-v4,
          pyth-decoder-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.pyth-pnau-decoder-v3,
          wormhole-core-contract: 'SP1CGXWEAMG6P6FT04W66NVGJ7PQWMDAC19R7PJ0Y.wormhole-core-v4,
        }
      ))
      (ok true)
    )
    ;; do nothing if none
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-xyk-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-xyk-active", user: contract-caller, data: { old-value: (get-xyk-active), new-value: active } })
    (ok (var-set xyk-active active))
  )
)

(define-public (disable-xyk)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-xyk", user: contract-caller, data: { old-value: (get-xyk-active), new-value: false } })
    (ok (var-set xyk-active false))
  )
)

(define-public (set-swap-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-swap-active", user: contract-caller, data: { old-value: (get-swap-active), new-value: active } })
    (ok (var-set swap-active active))
  )
)

(define-public (disable-swap)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-swap", user: contract-caller, data: { old-value: (get-swap-active), new-value: false } })
    (ok (var-set swap-active false))
  )
)

;; @desc - sweeps any leftover tokens from interface contract to reserve
;; @param - asset-trait: the token to sweep
;; @param - amount: the amount to sweep
(define-public (sweep (asset-trait <ft>) (amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-is-asset (contract-of asset-trait)))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= amount (unwrap-panic (contract-call? asset-trait get-balance this-contract))) ERR_INSUFFICIENT_BALANCE)
    (try! (as-contract (contract-call? asset-trait transfer amount this-contract reserve none)))
    (print { action: "sweep", user: contract-caller, data: { asset: asset-trait, amount: amount, sender: this-contract, recipient: reserve } })
    (ok amount)
  )
)