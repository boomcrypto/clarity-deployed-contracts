
;; @contract Minting Auto
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(use-trait pyth-storage-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.wormhole-traits-v1.core-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_TRADING_DISABLED (err u2301))
(define-constant ERR_NOT_CUSTODY_ADDRESS (err u2302))
(define-constant ERR_NOT_SUPPORTED_ASSET (err u2303))
(define-constant ERR_PRICE_FEED_MISMATCH (err u2304))
(define-constant ERR_STALE_DATA (err u2305))
(define-constant ERR_MINT_LIMIT_EXCEEDED (err u2306))
(define-constant ERR_ABOVE_MAX (err u2307))
(define-constant ERR_BELOW_MIN (err u2308))
(define-constant ERR_NOT_WHITELISTED (err u2309))
(define-constant ERR_SLIPPAGE_TOO_HIGH (err u2310))
(define-constant ERR_TOKEN_BASE_MISMATCH (err u2311))

(define-constant bps-base (pow u10 u4))
(define-constant oracle-base (pow u10 u8))
(define-constant usdh-base (pow u10 u8))

(define-constant max-slippage u1000)
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
    slippage: uint,
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

;;-------------------------------------
;; Minter
;;-------------------------------------

(define-public (mint
  (minting-asset <sip-010-trait>)
  (amount-usdh-requested uint)
  (slippage-tolerance uint)
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
    (slippage-bps (get slippage supported-asset-data))
    (state (contract-call? .test-minting-state get-confirm-mint-state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (decoded-price
      (match price-feed-bytes value
        (element-at (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2 decode-price-feeds value execution-plan)) u0)
        (some { conf: u0, ema-conf: u0, ema-price: 0, expo: 0, prev-publish-time: u0, price: (to-int oracle-base), price-identifier: 0x00, publish-time: (+ block-timestamp u1)})
      )
    )
    (price (to-uint (unwrap-panic (get price decoded-price))))
    (timestamp (unwrap-panic (get publish-time decoded-price)))
    (price-feed-id (unwrap-panic (get price-identifier decoded-price)))
    (slippage-amount (/ (* price slippage-bps) bps-base))
    (amount-asset-required (/ (* amount-usdh-requested oracle-base token-base) (- price slippage-amount) usdh-base))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (asserts! (get mint-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get minter (get-whitelist tx-sender minting-asset-contract)) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset minting-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= slippage-bps slippage-tolerance ) ERR_SLIPPAGE_TOO_HIGH)
    (asserts! (is-eq price-feed-id (get price-feed-id supported-asset-data)) ERR_PRICE_FEED_MISMATCH)

    (if (>= timestamp (+ (get-last-mint-limit-reset) (get-mint-limit-reset-window)))
      (begin
        (var-set current-mint-limit (get-mint-limit))
        (var-set last-mint-limit-reset timestamp)
      )
      true
    )

    (asserts! (<= amount-usdh-requested (get-current-mint-limit)) ERR_MINT_LIMIT_EXCEEDED)

    (try! (contract-call? .test-usdh-token-final mint-for-protocol amount-usdh-requested tx-sender))
    (try! (contract-call? minting-asset transfer amount-asset-required tx-sender (get-custody-address) memo))

    (print { price: price, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-amount: slippage-amount, minting-asset: minting-asset-contract })
    (ok (var-set current-mint-limit (- (get-current-mint-limit) amount-usdh-requested)))
  )
)

;;-------------------------------------
;; Redemer
;;-------------------------------------

(define-public (redeem
  (redeeming-asset <sip-010-trait>)
  (amount-usdh-requested uint)
  (slippage-tolerance uint)
  (memo (optional (buff 34)))
  (price-feed-bytes (optional (buff 8192)))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (redeeming-asset-contract (contract-of redeeming-asset))
    (token-base (get token-base (try! (get-supported-asset redeeming-asset-contract))))
    (state (contract-call? .test-minting-state get-confirm-redeem-state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (decoded-price
      (match price-feed-bytes value
        (element-at (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2 decode-price-feeds value execution-plan)) u0)
        (some { conf: u0, ema-conf: u0, ema-price: 0, expo: 0, prev-publish-time: u0, price: (to-int oracle-base), price-identifier: 0x00, publish-time: (+ block-timestamp u1)})
      )
    )
    (price (to-uint (unwrap-panic (get price decoded-price))))
    (timestamp (unwrap-panic (get publish-time decoded-price)))
    (price-feed-id (unwrap-panic (get price-identifier decoded-price)))
    (slippage-bps (get slippage (try! (get-supported-asset redeeming-asset-contract))))
    (slippage-amount (/ (* price slippage-bps) bps-base))
    (amount-asset-required (/ (* amount-usdh-requested oracle-base token-base) (- price slippage-amount) usdh-base))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (asserts! (get redeem-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get redeemer (get-whitelist tx-sender redeeming-asset-contract)) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset redeeming-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (is-eq price-feed-id (get price-feed-id (try! (get-supported-asset redeeming-asset-contract)))) ERR_PRICE_FEED_MISMATCH)
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= slippage-bps slippage-tolerance ) ERR_SLIPPAGE_TOO_HIGH)

    (try! (contract-call? .test-usdh-token-final burn-for-protocol amount-usdh-requested tx-sender))
    (try! (contract-call? .test-redeeming-reserve transfer amount-asset-required tx-sender redeeming-asset))

    (print { price: price, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-amount: slippage-amount, redeeming-asset: redeeming-asset-contract })
    (ok (var-set current-mint-limit (- (get-current-mint-limit) amount-usdh-requested)))
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-mint-limit (new-mint-limit uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-mint-limit max-mint-limit) ERR_ABOVE_MAX)
    (ok (var-set mint-limit new-mint-limit)))
)

(define-public (set-mint-limit-reset-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (>= new-window min-mint-limit-reset-window) ERR_BELOW_MIN)
    (ok (var-set mint-limit-reset-window new-window)))
)

(define-public (set-block-delay (new-amount uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-amount max-block-delay) ERR_ABOVE_MAX)
    (asserts! (> new-amount u0) ERR_BELOW_MIN)
    (ok (var-set block-delay new-amount))
  )
)

(define-public (set-whitelist (address principal) (asset principal) (minter bool) (redeemer bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (map-set whitelist { address: address, asset: asset } { minter: minter, redeemer: redeemer }))
  )
)

(define-public (set-custody-address (new-custody-address principal))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (var-set custody-address new-custody-address))
  )
)

(define-public (set-supported-asset (token <sip-010-trait>) (active bool) (price-feed-id (buff 32)) (token-base uint) (slippage uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= slippage max-slippage) ERR_ABOVE_MAX)
    (asserts! (is-eq token-base (pow u10 (unwrap-panic (contract-call? token get-decimals)))) ERR_TOKEN_BASE_MISMATCH)
    (ok (map-set supported-assets { contract: (contract-of token) } { active: active, price-feed-id: price-feed-id, token-base: token-base, slippage: slippage }))
  )
)