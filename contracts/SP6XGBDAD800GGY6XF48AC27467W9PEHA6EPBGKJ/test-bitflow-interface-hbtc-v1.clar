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

(define-constant ERR_XYK_DISABLED (err u110001))
(define-constant ERR_STALE_PRICE (err u110002))

(define-constant bps-base (pow u10 u4))
(define-constant price-base (pow u10 u8))

(define-constant this-contract (as-contract tx-sender))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var xyk-enabled bool false)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-xyk-enabled)
  (var-get xyk-enabled)
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-xyk-enabled)
  (ok (asserts! (var-get xyk-enabled) ERR_XYK_DISABLED))
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
  (let (
    (core-contract (contract-of core-trait))
    (pool-contract (contract-of pool-trait))
    (x-token (contract-of x-token-trait))
    (y-token (contract-of y-token-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets core-contract (some pool-contract) (some x-token) (some y-token)))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer x-token-trait x-amount this-contract))
    (let (
      (min-dy (calculate-min-output-stableswap x-token y-token x-amount min-dy-input))
      (dy (try! (as-contract (contract-call? core-trait swap-x-for-y pool-trait x-token-trait y-token-trait x-amount min-dy))))
    )
      (let (
        (x-balance (unwrap-panic (contract-call? x-token-trait get-balance this-contract)))
        (y-balance (unwrap-panic (contract-call? y-token-trait get-balance this-contract)))
      )
        (if (> x-balance u0)
          (try! (as-contract (contract-call? x-token-trait transfer x-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? y-token-trait transfer y-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-stable-swap-x-for-y", user: contract-caller, data: { core-contract: core-contract, pool: pool-trait, x-token: x-token, y-token: y-token, x-amount: x-amount, min-dy: min-dy, dy-returned: dy, y-returned: y-balance, x-returned: x-balance } })
        (ok y-balance)
      )
    )
  )
)

(define-public (bitflow-stable-swap-y-for-x
  (core-trait <stableswap-core>)
  (pool-trait <stableswap-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (y-amount uint) (min-dx-input uint)
  )
  (let (
    (core-contract (contract-of core-trait))
    (pool-contract (contract-of pool-trait))
    (x-token (contract-of x-token-trait))
    (y-token (contract-of y-token-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets core-contract (some pool-contract) (some x-token) (some y-token)))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer y-token-trait y-amount this-contract))
    (let (
      (min-dx (calculate-min-output-stableswap y-token x-token y-amount min-dx-input))
      (dx (try! (as-contract (contract-call? core-trait swap-y-for-x pool-trait x-token-trait y-token-trait y-amount min-dx))))
    )
      (let (
        (y-balance (unwrap-panic (contract-call? y-token-trait get-balance this-contract)))
        (x-balance (unwrap-panic (contract-call? x-token-trait get-balance this-contract)))
      )
        (if (> y-balance u0)
          (try! (as-contract (contract-call? y-token-trait transfer y-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? x-token-trait transfer x-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-stable-swap-y-for-x", user: contract-caller, data: { core-contract: core-contract, pool: pool-trait, x-token: x-token, y-token: y-token, y-amount: y-amount, min-dx: min-dx, dx-returned: dx, x-returned: x-balance, y-returned: y-balance } })
        (ok x-balance)
      )
    )
  )
)

(define-public (bitflow-xyk-swap-x-for-y
  (core-trait <xyk-core>)
  (pool-trait <xyk-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (x-amount uint) (min-dy-input uint)
  (price-feed-bytes-one (optional (buff 8192)))
  (price-feed-bytes-two (optional (buff 8192)))
  )
  (let (
    (core-contract (contract-of core-trait))
    (pool-contract (contract-of pool-trait))
    (x-token (contract-of x-token-trait))
    (y-token (contract-of y-token-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (check-is-xyk-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets core-contract (some pool-contract) (some x-token) (some y-token)))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer x-token-trait x-amount this-contract))
    (try! (write-feed price-feed-bytes-one))
    (try! (write-feed price-feed-bytes-two))
    (let (
      (min-dy (try! (calculate-min-output-xyk x-token y-token x-amount min-dy-input)))
      (dy (try! (as-contract (contract-call? core-trait swap-x-for-y pool-trait x-token-trait y-token-trait x-amount min-dy))))
    )
      (let (
        (x-balance (unwrap-panic (contract-call? x-token-trait get-balance this-contract)))
        (y-balance (unwrap-panic (contract-call? y-token-trait get-balance this-contract)))
      )
        (if (> x-balance u0)
          (try! (as-contract (contract-call? x-token-trait transfer x-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? y-token-trait transfer y-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-xyk-swap-x-for-y", user: contract-caller, data: { core-contract: core-contract, pool: pool-trait, x-token: x-token, y-token: y-token, x-amount: x-amount, min-dy: min-dy, dy-returned: dy, y-returned: y-balance, x-returned: x-balance } })
        (ok y-balance)
      )
    )
  )
)

(define-public (bitflow-xyk-swap-y-for-x
  (core-trait <xyk-core>)
  (pool-trait <xyk-pool>)
  (x-token-trait <ft>) (y-token-trait <ft>)
  (y-amount uint) (min-dx-input uint)
  (price-feed-bytes-one (optional (buff 8192)))
  (price-feed-bytes-two (optional (buff 8192)))
  )
  (let (
    (core-contract (contract-of core-trait))
    (pool-contract (contract-of pool-trait))
    (x-token (contract-of x-token-trait))
    (y-token (contract-of y-token-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (check-is-xyk-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets core-contract (some pool-contract) (some x-token) (some y-token)))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer y-token-trait y-amount this-contract))
    (try! (write-feed price-feed-bytes-one))
    (try! (write-feed price-feed-bytes-two))
    (let (
      (min-dx (try! (calculate-min-output-xyk y-token x-token y-amount min-dx-input)))
      (dx (try! (as-contract (contract-call? core-trait swap-y-for-x pool-trait x-token-trait y-token-trait y-amount min-dx))))
    )
      (let (
        (y-balance (unwrap-panic (contract-call? y-token-trait get-balance this-contract)))
        (x-balance (unwrap-panic (contract-call? x-token-trait get-balance this-contract)))
      )
        (if (> y-balance u0)
          (try! (as-contract (contract-call? y-token-trait transfer y-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? x-token-trait transfer x-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-xyk-swap-y-for-x", user: contract-caller, data: { core-contract: core-contract, pool: pool-trait, x-token: x-token, y-token: y-token, y-amount: y-amount, min-dx: min-dx, dx-returned: dx, x-returned: x-balance, y-returned: y-balance } })
        (ok x-balance)
      )
    )
  )
)

;; Swap via 1 XYK pool
(define-public (bitflow-swap-helper-a
  (swap-helper-trait <swap-helper>)
  (amount uint) (min-received-input uint) (provider (optional principal))
  (xyk-token-a-trait <ft>) (xyk-token-b-trait <ft>)
  (xyk-pool-trait <xyk-pool>)
  (price-feed-bytes-one (optional (buff 8192)))
  (price-feed-bytes-two (optional (buff 8192)))
  )
  (let (
    (xyk-tokens-trait { a: xyk-token-a-trait, b: xyk-token-b-trait })
    (xyk-pools-trait { a: xyk-pool-trait })
    (swap-helper-contract (contract-of swap-helper-trait))
    (xyk-token-a (contract-of xyk-token-a-trait))
    (xyk-token-b (contract-of xyk-token-b-trait))
    (pool-contract (contract-of xyk-pool-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (check-is-xyk-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets swap-helper-contract (some pool-contract) (some xyk-token-a) (some xyk-token-b)))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer xyk-token-a-trait amount this-contract))
    (try! (write-feed price-feed-bytes-one))
    (try! (write-feed price-feed-bytes-two))
    (let (
      (min-received (try! (calculate-min-output-xyk xyk-token-a xyk-token-b amount min-received-input)))
      (amount-b (try! (as-contract (contract-call? swap-helper-trait swap-helper-a amount min-received provider xyk-tokens-trait xyk-pools-trait))))
    )
      (let (
        (token-a-balance (unwrap-panic (contract-call? xyk-token-a-trait get-balance this-contract)))
        (token-b-balance (unwrap-panic (contract-call? xyk-token-b-trait get-balance this-contract)))
      )
        (if (> token-a-balance u0)
          (try! (as-contract (contract-call? xyk-token-a-trait transfer token-a-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? xyk-token-b-trait transfer token-b-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-swap-helper-a", user: contract-caller, data: { swap-helper: swap-helper-contract, pool: xyk-pools-trait, amount: amount, min-received: min-received, received-returned: amount-b, token-b-returned: token-b-balance, token-a-returned: token-a-balance, provider: provider, xyk-tokens: xyk-tokens-trait } })
        (ok token-b-balance)
      )
    )
  )
)

;; Swap via 2 XYK pools
(define-public (bitflow-swap-helper-b
  (swap-helper-trait <swap-helper>)
  (amount uint) (min-received-input uint) (provider (optional principal))
  (xyk-token-a-trait <ft>) (xyk-token-b-trait <ft>) (xyk-token-c-trait <ft>) (xyk-token-d-trait <ft>)
  (xyk-pool-a-trait <xyk-pool>) (xyk-pool-b-trait <xyk-pool>)
  (price-feed-bytes-one (optional (buff 8192)))
  (price-feed-bytes-two (optional (buff 8192)))
  )
  (let (
    (xyk-tokens-trait { a: xyk-token-a-trait, b: xyk-token-b-trait, c: xyk-token-c-trait, d: xyk-token-d-trait })
    (xyk-pools-trait { a: xyk-pool-a-trait, b: xyk-pool-b-trait })
    (swap-helper-contract (contract-of swap-helper-trait))
    (xyk-token-a (contract-of xyk-token-a-trait))
    (xyk-token-d (contract-of xyk-token-d-trait))
    (pool-a-contract (contract-of xyk-pool-a-trait))
    (pool-b-contract (contract-of xyk-pool-b-trait))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-trader contract-caller))
    (try! (check-is-xyk-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-is-trading-enabled))
    (try! (contract-call? .test-state-hbtc-v1 check-connections-and-assets swap-helper-contract (some pool-a-contract) (some xyk-token-a) (some xyk-token-d)))
    (try! (contract-call? .test-state-hbtc-v1 check-is-connection pool-b-contract))
    (try! (contract-call? .test-reserve-hbtc-v1 transfer xyk-token-a-trait amount this-contract))
    (try! (write-feed price-feed-bytes-one))
    (try! (write-feed price-feed-bytes-two))
    (let (
      (min-received (try! (calculate-min-output-xyk xyk-token-a xyk-token-d amount min-received-input)))
      (amount-d (try! (as-contract (contract-call? swap-helper-trait swap-helper-b amount min-received provider xyk-tokens-trait xyk-pools-trait))))
    )
      (let (
        (token-a-balance (unwrap-panic (contract-call? xyk-token-a-trait get-balance this-contract)))
        (token-d-balance (unwrap-panic (contract-call? xyk-token-d-trait get-balance this-contract)))
      )
        (if (> token-a-balance u0)
          (try! (as-contract (contract-call? xyk-token-a-trait transfer token-a-balance this-contract .test-reserve-hbtc-v1 none)))
          true)

        (try! (as-contract (contract-call? xyk-token-d-trait transfer token-d-balance this-contract .test-reserve-hbtc-v1 none)))

        (print { action: "bitflow-swap-helper-b", user: contract-caller, data: { swap-helper: swap-helper-contract, pool: xyk-pools-trait, amount: amount, min-received: min-received, received-returned: amount-d, token-d-returned: token-d-balance, token-a-returned: token-a-balance, provider: provider, xyk-tokens: xyk-tokens-trait } })
        (ok token-d-balance)
      )
    )
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

;; Private function to calculate minimum output amount for stable swaps using direct token ratio without Pyth
(define-private (calculate-min-output-stableswap
  (input-token principal) (output-token principal)
  (input-amount uint)
  (min-output-arg uint))
  (let (
    (input-token-data (contract-call? .test-state-hbtc-v1 get-trading-asset input-token))
    (max-slippage (get max-slippage input-token-data))
    (output-token-base (get token-base (contract-call? .test-state-hbtc-v1 get-trading-asset output-token)))
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
    (block-delay (contract-call? .test-state-hbtc-v1 get-block-delay))
    (min-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height block-delay))))
  )
    (ok (asserts! (>= publish-time min-timestamp) ERR_STALE_PRICE))
  )
)

;; Private function to calculate minimum output amount with Pyth-based slippage protection
(define-private (calculate-min-output-xyk
  (input-token principal) (output-token principal)
  (input-amount uint)
  (min-output-arg uint))
  (let (
    (input-token-data (contract-call? .test-state-hbtc-v1 get-trading-asset input-token))
    (output-token-data (contract-call? .test-state-hbtc-v1 get-trading-asset output-token))
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

(define-private (write-feed (price-feed-bytes (optional (buff 8192))))
  (match price-feed-bytes bytes 
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

(define-public (set-xyk-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-xyk-enabled", user: contract-caller, data: { old-value: (get-xyk-enabled), new-value: enabled } })
    (ok (var-set xyk-enabled enabled))
  )
)

(define-public (disable-xyk)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-xyk", user: contract-caller, data: { old-value: (get-xyk-enabled), new-value: false } })
    (ok (var-set xyk-enabled false))
  )
)