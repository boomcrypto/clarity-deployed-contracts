;; @contract Minting Auto
;; @version 1.1

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
(define-constant ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO (err u2310))
(define-constant ERR_ORACLE_CONF_TOO_LOW (err u2311))

(define-constant bps-base (pow u10 u4))
(define-constant usdh-base (pow u10 u8))

(define-constant max-price-slippage u1000)
(define-constant max-block-delay u10)
(define-constant max-mint-limit (* u500000 usdh-base))
(define-constant min-mint-limit-reset-window u60)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var mint-limit uint (* u100000 usdh-base))
(define-data-var current-mint-limit uint (* u100000 usdh-base))
(define-data-var mint-limit-reset-window uint u600)
(define-data-var last-mint-limit-reset uint u0)

;;-------------------------------------
;; Getters
;;-------------------------------------

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

;;-------------------------------------
;; Checks
;;-------------------------------------

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
    (state (try! (contract-call? .minting-auto-state-v1 get-state contract-caller minting-asset-contract )))
    (token-base (get token-base state))
    (conf-tolerance-bps (get conf-tolerance-bps state))
    (price-slippage-bps (get price-slippage-bps state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (get block-delay state)))))
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
    (slippage-in-price (/ (* decoded-price price-slippage-bps) bps-base))
    (amount-asset-required-before-slippage (/ (* amount-usdh-requested decoded-price-base token-base) decoded-price usdh-base))
    (amount-asset-required (/ (* amount-usdh-requested decoded-price-base token-base) (- decoded-price slippage-in-price) usdh-base))
    (amount-asset-slippage (- amount-asset-required amount-asset-required-before-slippage))
    (fee-amount (/ (* amount-asset-slippage (get mint-fee state)) bps-base))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (contract-call? .minting-state-v1 get-mint-enabled) ERR_TRADING_DISABLED)
    (asserts! (get is-minter state) ERR_NOT_WHITELISTED)
    (asserts! (get is-supported-asset state) ERR_NOT_SUPPORTED_ASSET)
    (try! (check-confidence decoded-price decoded-price-conf conf-tolerance-bps))
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= price-slippage-bps price-slippage-tolerance ) ERR_PRICE_SLIPPAGE_TOO_HIGH)
    (asserts! (>= amount-usdh-requested (contract-call? .minting-state-v1 get-min-amount-usdh-requested)) ERR_BELOW_MIN)
    (asserts! (> amount-asset-required u0) ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO)
    (asserts! (is-eq (unwrap-panic (get price-identifier decoded-data)) (get price-feed-id state)) ERR_PRICE_FEED_MISMATCH)

    (if (>= timestamp (+ (get-last-mint-limit-reset) (get-mint-limit-reset-window)))
      (begin
        (var-set current-mint-limit (get-mint-limit))
        (var-set last-mint-limit-reset timestamp)
      )
      true
    )

    (asserts! (<= amount-usdh-requested (get-current-mint-limit)) ERR_MINT_LIMIT_EXCEEDED)

    (try! (contract-call? .usdh-token-v1 mint-for-protocol amount-usdh-requested contract-caller))
    (try! (contract-call? minting-asset transfer (- amount-asset-required fee-amount) contract-caller (unwrap-panic (get custody-address state)) memo))

    (if (> fee-amount u0)
      (try! (contract-call? minting-asset transfer fee-amount contract-caller (get fee-address state) none))
      true
    )

    (print { price: decoded-price, price-conf: decoded-price-conf, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-in-price: slippage-in-price, fee-amount: fee-amount, minting-asset: minting-asset-contract, conf-tolerance-bps: conf-tolerance-bps })
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
    (state (try! (contract-call? .minting-auto-state-v1 get-state contract-caller redeeming-asset-contract )))
    (token-base (get token-base state))
    (conf-tolerance-bps (get conf-tolerance-bps state))
    (price-slippage-bps (get price-slippage-bps state))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (get block-delay state)))))
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
    (slippage-in-price (/ (* decoded-price price-slippage-bps) bps-base))
    (amount-asset-required-before-slippage (/ (* amount-usdh-requested decoded-price-base token-base) decoded-price usdh-base))
    (amount-asset-required (/ (* amount-usdh-requested decoded-price-base token-base) (+ decoded-price slippage-in-price) usdh-base))
    (amount-asset-slippage (- amount-asset-required-before-slippage amount-asset-required))
    (fee-amount (/ (* amount-asset-slippage (get redeem-fee state)) bps-base))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (contract-call? .minting-state-v1 get-redeem-enabled) ERR_TRADING_DISABLED)
    (asserts! (get is-redeemer state) ERR_NOT_WHITELISTED)
    (asserts! (get is-supported-asset state) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (is-eq (unwrap-panic (get price-identifier decoded-data)) (get price-feed-id state)) ERR_PRICE_FEED_MISMATCH)
    (try! (check-confidence decoded-price decoded-price-conf conf-tolerance-bps))
    (asserts! (> timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (<= price-slippage-bps price-slippage-tolerance ) ERR_PRICE_SLIPPAGE_TOO_HIGH)
    (asserts! (>= amount-usdh-requested (contract-call? .minting-state-v1 get-min-amount-usdh-requested)) ERR_BELOW_MIN)
    (asserts! (> amount-asset-required u0) ERR_AMOUNT_ASSET_REQUIRED_IS_ZERO)

    (try! (contract-call? .usdh-token-v1 burn-for-protocol amount-usdh-requested contract-caller))
    (try! (contract-call? .redeeming-reserve-v1-2 transfer (- amount-asset-required fee-amount) contract-caller redeeming-asset memo))

    (if (> fee-amount u0)
      (try! (contract-call? .redeeming-reserve-v1-2 transfer fee-amount (get fee-address state) redeeming-asset none))
      true
    )

    (print { price: decoded-price, price-conf: decoded-price-conf, oracle-timestamp: timestamp, amount-usdh-requested: amount-usdh-requested, amount-asset-required: amount-asset-required, slippage-in-price: slippage-in-price, fee-amount: fee-amount, redeeming-asset: redeeming-asset-contract, conf-tolerance-bps: conf-tolerance-bps })
    (ok true)
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-mint-limit (new-mint-limit uint))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (<= new-mint-limit max-mint-limit) ERR_ABOVE_MAX)
    (print { old-value: (get-mint-limit), new-value: new-mint-limit })
    (ok (var-set mint-limit new-mint-limit)))
)

(define-public (set-mint-limit-reset-window (new-window uint))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (>= new-window min-mint-limit-reset-window) ERR_BELOW_MIN)
    (print { old-value: (get-mint-limit-reset-window), new-value: new-window })
    (ok (var-set mint-limit-reset-window new-window)))
)