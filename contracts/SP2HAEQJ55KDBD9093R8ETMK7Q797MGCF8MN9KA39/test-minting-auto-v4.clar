;; @contract Minting Auto
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(use-trait pyth-storage-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-traits-v1.core-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_TRADING_DISABLED (err u2301))
(define-constant ERR_NOT_SUPPORTED_ASSET (err u2302))
(define-constant ERR_PRICE_FEED_MISMATCH (err u2303))
(define-constant ERR_STALE_DATA (err u2304))
(define-constant ERR_MINT_LIMIT_EXCEEDED (err u2305))
(define-constant ERR_ABOVE_MAX (err u2306))
(define-constant ERR_BELOW_MIN (err u2307))
(define-constant ERR_NOT_WHITELISTED (err u2308))
(define-constant ERR_PRICE_SLIPPAGE_TOO_HIGH (err u2309))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u2310))
(define-constant ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO (err u2311))
(define-constant ERR_MAX_CONF_TOO_HIGH (err u2312))
(define-constant ERR_ORACLE_CONF_TOO_LOW (err u2313))

(define-constant bps-base (pow u10 u4))
(define-constant usdh-base (pow u10 u8))

(define-constant max-price-slippage u1000)
(define-constant max-block-delay u10)
(define-constant max-mint-limit (* u1000000 usdh-base))
(define-constant min-mint-limit-reset-window u1200)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var mint-limit uint (* u100000 usdh-base))
(define-data-var current-mint-limit uint (* u100000 usdh-base))
(define-data-var mint-limit-reset-window uint u3600)
(define-data-var last-mint-limit-reset uint u0)

(define-data-var custody-address principal tx-sender)
(define-data-var block-delay uint u1)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map whitelist
  {
    address: principal,
    asset: principal
  }
  {
    minter: bool,
    redeemer: bool,
  }
)

(define-map supported-assets
  {
    contract: principal 
  }
  {
    active: bool,
    price-feed-id: (buff 32),
    token-base: uint,
    price-slippage: uint,
    conf-tolerance-bps: uint
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-whitelist (address principal) (asset principal))
  (default-to 
    { minter: false, redeemer: false }
    (map-get? whitelist { address: address, asset: asset })
  )
)

(define-read-only (get-custody-address)
  (var-get custody-address)
)

(define-read-only (get-supported-asset (contract principal))
  (ok (unwrap! (map-get? supported-assets { contract: contract }) ERR_NOT_SUPPORTED_ASSET))
)

(define-read-only (get-mint-limit)
  (var-get mint-limit)
)

(define-read-only (get-current-mint-limit)
  (var-get current-mint-limit)
)

(define-read-only (get-last-mint-limit-reset)
  (var-get last-mint-limit-reset)
)

(define-read-only (get-mint-limit-reset-window)
  (var-get mint-limit-reset-window)
)

(define-read-only (get-block-delay)
  (var-get block-delay)
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-supported-asset (contract principal))
  (get active
    (default-to
      { active: false }
      (map-get? supported-assets { contract: contract })
    )
  )
)

(define-private (check-confidence (price uint) (conf uint) (conf-tolerance-bps uint))
  (ok (asserts! (or (is-eq u0 price) (<= conf (/ (* price conf-tolerance-bps) bps-base))) ERR_ORACLE_CONF_TOO_LOW)))

;;-------------------------------------
;; Minter
;;-------------------------------------

(define-public (mint
  (minting-asset <sip-010-trait>)
  (amount-usdh-requested uint)
  (price-slippage-tolerance uint)
  (memo (optional (buff 34)))
  (price-feed-bytes (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (minting-asset-contract (contract-of minting-asset))
    (supported-asset-data (try! (get-supported-asset minting-asset-contract)))
    (token-base (get token-base supported-asset-data))
    (price-slippage-bps (get price-slippage supported-asset-data))
    (conf-tolerance-bps (get conf-tolerance-bps supported-asset-data))
    (state (contract-call? .test-minting-state get-confirm-mint-state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (decoded-data
      (match price-feed-bytes value
        (element-at (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3 decode-price-feeds value execution-plan)) u0)
        (some { conf: u0, ema-conf: u0, ema-price: 0, expo: -8, prev-publish-time: u0, price: (to-int (pow u10 u8)), price-identifier: 0x00, publish-time: (+ block-timestamp u1)})
      )
    )
    (decoded-price-base (pow u10 (to-uint (* -1 (unwrap-panic (get expo decoded-data))))))
    (decoded-price (to-uint (unwrap-panic (get price decoded-data))))
    (decoded-price-conf (unwrap-panic (get conf decoded-data)))
    (timestamp (unwrap-panic (get publish-time decoded-data)))
    (slippage-amount (/ (* decoded-price price-slippage-bps) bps-base))
    (amount-asset-required (/ (* amount-usdh-requested decoded-price-base token-base) (- decoded-price slippage-amount) usdh-base))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (asserts! (get mint-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get minter (get-whitelist contract-caller minting-asset-contract)) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset minting-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (try! (check-confidence decoded-price decoded-price-conf conf-tolerance-bps))
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= price-slippage-bps price-slippage-tolerance ) ERR_PRICE_SLIPPAGE_TOO_HIGH)
    (asserts! (> amount-usdh-requested u0) ERR_BELOW_MIN)
    (asserts! (> amount-asset-required u0) ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO)
    (asserts! (is-eq (unwrap-panic (get price-identifier decoded-data)) (get price-feed-id supported-asset-data)) ERR_PRICE_FEED_MISMATCH)

    (if (>= timestamp (+ (get-last-mint-limit-reset) (get-mint-limit-reset-window)))
      (begin
        (var-set current-mint-limit (get-mint-limit))
        (var-set last-mint-limit-reset timestamp)
      )
      true
    )

    (asserts! (<= amount-usdh-requested (get-current-mint-limit)) ERR_MINT_LIMIT_EXCEEDED)

    (try! (contract-call? .test-usdh-token-final mint-for-protocol amount-usdh-requested contract-caller))
    (try! (contract-call? minting-asset transfer amount-asset-required contract-caller (get-custody-address) memo))

    (print { price: decoded-price, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-amount: slippage-amount, minting-asset: minting-asset-contract })
    (ok (var-set current-mint-limit (- (get-current-mint-limit) amount-usdh-requested)))
  )
)

;;-------------------------------------
;; Redeemer
;;-------------------------------------

(define-public (redeem
  (redeeming-asset <sip-010-trait>)
  (amount-usdh-requested uint)
  (price-slippage-tolerance uint)
  (memo (optional (buff 34)))
  (price-feed-bytes (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (redeeming-asset-contract (contract-of redeeming-asset))
    (supported-asset-data (try! (get-supported-asset redeeming-asset-contract)))
    (token-base (get token-base supported-asset-data))
    (price-slippage-bps (get price-slippage supported-asset-data))
    (conf-tolerance-bps (get conf-tolerance-bps supported-asset-data))
    (state (contract-call? .test-minting-state get-confirm-redeem-state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (decoded-data
      (match price-feed-bytes value
        (element-at (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3 decode-price-feeds value execution-plan)) u0)
        (some { conf: u0, ema-conf: u0, ema-price: 0, expo: -8, prev-publish-time: u0, price: (to-int (pow u10 u8)), price-identifier: 0x00, publish-time: (+ block-timestamp u1)})
      )
    )
    (decoded-price-base (pow u10 (to-uint (* -1 (unwrap-panic (get expo decoded-data))))))
    (decoded-price (to-uint (unwrap-panic (get price decoded-data))))
    (decoded-price-conf (unwrap-panic (get conf decoded-data)))
    (timestamp (unwrap-panic (get publish-time decoded-data)))
    (slippage-amount (/ (* decoded-price price-slippage-bps) bps-base))
    (amount-asset-required (/ (* amount-usdh-requested decoded-price-base token-base) (+ decoded-price slippage-amount) usdh-base))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (asserts! (get redeem-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get redeemer (get-whitelist contract-caller redeeming-asset-contract)) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset redeeming-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (is-eq (unwrap-panic (get price-identifier decoded-data)) (get price-feed-id supported-asset-data)) ERR_PRICE_FEED_MISMATCH)
    (try! (check-confidence decoded-price decoded-price-conf conf-tolerance-bps))
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= price-slippage-bps price-slippage-tolerance ) ERR_PRICE_SLIPPAGE_TOO_HIGH)
    (asserts! (> amount-usdh-requested u0) ERR_BELOW_MIN)
    (asserts! (> amount-asset-required u0) ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO)

    (try! (contract-call? .test-usdh-token-final burn-for-protocol amount-usdh-requested contract-caller))
    (try! (contract-call? .test-redeeming-reserve-v2 transfer amount-asset-required contract-caller redeeming-asset memo))

    (print { price: decoded-price, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-amount: slippage-amount, redeeming-asset: redeeming-asset-contract })
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-mint-limit (new-mint-limit uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (<= new-mint-limit max-mint-limit) ERR_ABOVE_MAX)
    (print { old-value: (get-mint-limit), new-value: new-mint-limit })
    (ok (var-set mint-limit new-mint-limit)))
)

(define-public (set-mint-limit-reset-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (>= new-window min-mint-limit-reset-window) ERR_BELOW_MIN)
    (print { old-value: (get-mint-limit-reset-window), new-value: new-window })
    (ok (var-set mint-limit-reset-window new-window)))
)

(define-public (set-block-delay (new-amount uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (<= new-amount max-block-delay) ERR_ABOVE_MAX)
    (asserts! (> new-amount u0) ERR_BELOW_MIN)
    (print { old-value: (get-block-delay), new-value: new-amount })
    (ok (var-set block-delay new-amount))
  )
)

(define-public (set-whitelist (address principal) (asset principal) (minter bool) (redeemer bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (asserts! (is-standard asset) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, asset: asset, old-values: (get-whitelist address asset),  new-values: { minter: minter, redeemer: redeemer } })
    (ok (map-set whitelist { address: address, asset: asset } { minter: minter, redeemer: redeemer }))
  )
)

(define-public (set-custody-address (new-custody-address principal))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (is-standard new-custody-address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { old-value: (get-custody-address), new-value: new-custody-address })
    (ok (var-set custody-address new-custody-address))
  )
)

(define-public (set-supported-asset (token <sip-010-trait>) (active bool) (price-feed-id (buff 32)) (price-slippage uint) (conf-tolerance-bps uint))
  (let (
    (token-address (contract-of token))
    (token-base (pow u10 (unwrap-panic (contract-call? token get-decimals))))
  )
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (<= price-slippage max-price-slippage) ERR_ABOVE_MAX)
    (asserts! (<= conf-tolerance-bps bps-base) ERR_MAX_CONF_TOO_HIGH)
    (if (check-is-supported-asset token-address)
      (print { 
        contract: token-address, 
        old-values: (some (unwrap-panic (get-supported-asset token-address))), 
        new-values: { active: active, price-feed-id: price-feed-id, token-base: token-base, price-slippage: price-slippage, conf-tolerance-bps: conf-tolerance-bps } })
      (print { 
        contract: token-address, 
        old-values: none, 
        new-values: { active: active, price-feed-id: price-feed-id, token-base: token-base, price-slippage: price-slippage, conf-tolerance-bps: conf-tolerance-bps} })
    )
    (ok (map-set supported-assets { contract: token-address } { active: active, price-feed-id: price-feed-id, token-base: token-base, price-slippage: price-slippage, conf-tolerance-bps: conf-tolerance-bps }))
  )
)
