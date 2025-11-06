;; @contract Minting
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(use-trait pyth-storage-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.wormhole-traits-v1.core-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NO_REQUEST_FOR_ID (err u2201))
(define-constant ERR_NOT_ALLOWED (err u2202))
(define-constant ERR_TRADING_DISABLED (err u2203))
(define-constant ERR_CONFIRMATION_OPEN (err u2204))
(define-constant ERR_AMOUNT_NOT_ALLOWED (err u2205))
(define-constant ERR_SLIPPAGE_TOO_HIGH (err u2206))
(define-constant ERR_NOT_CUSTODY_ADDRESS (err u2207))
(define-constant ERR_NOT_SUPPORTED_ASSET (err u2208))
(define-constant ERR_ASSET_MISMATCH (err u2209))
(define-constant ERR_PRICE_FEED_MISMATCH (err u2210))
(define-constant ERR_STALE_DATA (err u2211))
(define-constant ERR_PRICE_OUT_OF_RANGE (err u2212))
(define-constant ERR_MINT_LIMIT_EXCEEDED (err u2213))
(define-constant ERR_ABOVE_MAX (err u2214))
(define-constant ERR_BELOW_MIN (err u2215))
(define-constant ERR_NOT_WHITELISTED (err u2216))
(define-constant ERR_MAX_CONF_TOO_HIGH (err u2217))
(define-constant ERR_ORACLE_CONF_TOO_LOW (err u2218))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u2219))

(define-constant this-contract (as-contract tx-sender))
(define-constant bps-base (pow u10 u4))
(define-constant price-base (pow u10 u8))
(define-constant usdh-base (pow u10 u8))
(define-constant max-price-deviation u50)

(define-constant max-mint-limit (* u500000 usdh-base))
(define-constant min-mint-limit-reset-window u300)
(define-constant max-block-delay u10)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var current-mint-id uint u0)
(define-data-var current-redeem-id uint u0)

(define-data-var mint-limit uint (* u100000 usdh-base))
(define-data-var current-mint-limit uint (* u100000 usdh-base))
(define-data-var mint-limit-reset-window uint u300)
(define-data-var last-mint-limit-reset uint u0)
(define-data-var block-delay uint u2)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map traders
  {
    address: principal
  }
  {
    minter: bool,
    redeemer: bool
  }
)

(define-map mint-requests
  {
    request-id: uint
  }
  {
    requester: principal,
    minting-asset: principal,
    amount-asset: uint,
    price: uint,
    slippage: uint,
    block-height: uint
  }
)

(define-map redeem-requests
  {
    request-id: uint
  }
  {
    requester: principal,
    redeeming-asset: principal,
    amount-usdh: uint,
    price: uint,
    slippage: uint,
    block-height: uint
  }
)

(define-map custody-addresses
  {
    address: principal
  }
  {
    active: bool
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
    conf-tolerance-bps: uint
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-current-mint-id)
  (var-get current-mint-id)
)

(define-read-only (get-current-redeem-id)
  (var-get current-redeem-id)
)

(define-read-only (get-mint-limit)
  (var-get mint-limit)
)

(define-read-only (get-current-mint-limit)
  (var-get current-mint-limit)
)

(define-read-only (get-mint-limit-reset-window)
  (var-get mint-limit-reset-window)
)

(define-read-only (get-last-mint-limit-reset)
  (var-get last-mint-limit-reset)
)

(define-read-only (get-block-delay)
  (var-get block-delay)
)

(define-read-only (get-trader (address principal))
  (default-to
    { minter: false, redeemer: false }
    (map-get? traders { address: address })
  )
)

(define-read-only (get-mint-request (request-id uint))
  (ok (unwrap! (map-get? mint-requests { request-id: request-id }) ERR_NO_REQUEST_FOR_ID))
)

(define-read-only (get-redeem-request (request-id uint))
  (ok (unwrap! (map-get? redeem-requests { request-id: request-id }) ERR_NO_REQUEST_FOR_ID))
)

(define-read-only (get-custody-address-active (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? custody-addresses { address: address })
    )
  )
)

(define-read-only (get-supported-asset (contract principal))
  (ok (unwrap! (map-get? supported-assets { contract: contract }) ERR_NOT_SUPPORTED_ASSET))
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
;; Helper
;;-------------------------------------

(define-private (verify-price
  (price uint)
  (conf-tolerance-bps uint)
  (oracle-data { conf: uint, ema-conf: uint, ema-price: int, expo: int, prev-publish-time: uint, price: int, price-identifier: (buff 32), publish-time: uint})
  (asset-contract principal))
  (let (
    (oracle-price-base (pow u10 (to-uint (* -1 (get expo oracle-data)))))
    (oracle-price-conf (get conf oracle-data))
    (oracle-price (to-uint (get price oracle-data)))
    (oracle-price-feed-id (get price-identifier oracle-data))
    (max-price (+ oracle-price (/ (* oracle-price max-price-deviation) bps-base)))
    (min-price (- oracle-price (/ (* oracle-price max-price-deviation) bps-base)))
    (scaled-max-price (/ (* max-price price-base) oracle-price-base))
    (scaled-min-price (/ (* min-price price-base) oracle-price-base))
  )
    (asserts! (is-eq oracle-price-feed-id (get price-feed-id (try! (get-supported-asset asset-contract)))) ERR_PRICE_FEED_MISMATCH)
    (asserts! (and (> price scaled-min-price) (< price scaled-max-price)) ERR_PRICE_OUT_OF_RANGE)
    (try! (check-confidence oracle-price oracle-price-conf conf-tolerance-bps))
    (ok true)
  )
)

(define-private (check-confidence (price uint) (conf uint) (conf-tolerance-bps uint))
  (ok (asserts! (or (is-eq u0 price) (<= conf (/ (* price conf-tolerance-bps) bps-base))) ERR_ORACLE_CONF_TOO_LOW)))

;;-------------------------------------
;; User
;;-------------------------------------

(define-public (request-mint
  (minting-asset <sip-010-trait>)
  (amount-asset uint)
  (price uint)
  (slippage uint)
  (price-feed-bytes (buff 8192))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (next-mint-id (+ (get-current-mint-id) u1))
    (minting-asset-contract (contract-of minting-asset))
    (supported-asset-data (try! (get-supported-asset minting-asset-contract)))
    (token-base (get token-base supported-asset-data))
    (conf-tolerance-bps (get conf-tolerance-bps supported-asset-data))
    (amount-usdh-requested (/ (* amount-asset price usdh-base) price-base token-base))
    (oracle-data (unwrap-panic (element-at (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3 decode-price-feeds price-feed-bytes execution-plan)) u0)))
    (oracle-timestamp (get publish-time oracle-data))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (state (contract-call? .minting-state-v1 get-request-mint-state contract-caller))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (get mint-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get whitelisted state) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset minting-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (try! (verify-price price conf-tolerance-bps oracle-data minting-asset-contract))
    (if (>= oracle-timestamp (+ (get-last-mint-limit-reset) (get-mint-limit-reset-window)))
      (begin
        (var-set current-mint-limit (get-mint-limit))
        (var-set last-mint-limit-reset oracle-timestamp)
      )
      true
    )
    (asserts! (<= amount-usdh-requested (get-current-mint-limit)) ERR_MINT_LIMIT_EXCEEDED)
    (asserts! (> oracle-timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (>= amount-usdh-requested (get min-amount-usdh state)) ERR_BELOW_MIN)
    (asserts! (<= slippage bps-base) ERR_ABOVE_MAX)

    (try! (contract-call? minting-asset transfer amount-asset contract-caller this-contract none))

    (map-set mint-requests { request-id: next-mint-id }
      {
        requester: contract-caller,
        minting-asset: minting-asset-contract,
        amount-asset: amount-asset,
        price: price,
        slippage: slippage,
        block-height: burn-block-height
      }
    )
    (print { request-id: next-mint-id, requester: contract-caller, minting-asset: minting-asset-contract, amount-asset: amount-asset, price: price, amount-usdh-requested: amount-usdh-requested, slippage: slippage, block-height: burn-block-height })
    (var-set current-mint-id next-mint-id)
    (ok (var-set current-mint-limit (- (get-current-mint-limit) amount-usdh-requested)))
  )
)

(define-public (claim-unconfirmed-mint-many (entries (list 1000 { request-id: uint, minting-asset: <sip-010-trait> })))
  (ok (map claim-unconfirmed-mint entries)))

(define-public (claim-unconfirmed-mint (entry { request-id: uint, minting-asset: <sip-010-trait> }))
  (let (
    (mint-request (try! (get-mint-request (get request-id entry))))
    (minting-asset-entry (get minting-asset entry))
  )
    (asserts! (> burn-block-height (+ (get block-height mint-request) (contract-call? .minting-state-v1 get-mint-confirmation-window))) ERR_CONFIRMATION_OPEN)
    (asserts! (is-eq (get minting-asset mint-request) (contract-of minting-asset-entry)) ERR_ASSET_MISMATCH)

    (try! (contract-call? minting-asset-entry transfer (get amount-asset mint-request) this-contract (get requester mint-request) none))
    (ok (map-delete mint-requests { request-id: (get request-id entry)}))
  )
)

(define-public (request-redeem
  (redeeming-asset <sip-010-trait>)
  (amount-usdh uint)
  (price uint)
  (slippage uint)
  (price-feed-bytes (buff 8192))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (next-redeem-id (+ (get-current-redeem-id) u1))
    (redeeming-asset-contract (contract-of redeeming-asset))
    (supported-asset-data (try! (get-supported-asset redeeming-asset-contract)))
    (token-base (get token-base supported-asset-data))
    (conf-tolerance-bps (get conf-tolerance-bps supported-asset-data))
    (amount-asset-requested (/ (* amount-usdh price-base token-base) price usdh-base))
    (oracle-data (unwrap-panic (element-at (try! (contract-call? 'SP3R4F6C1J3JQWWCVZ3S7FRRYPMYG6ZW6RZK31FXY.pyth-oracle-v3 decode-price-feeds price-feed-bytes execution-plan)) u0)))
    (oracle-timestamp (get publish-time oracle-data))
    (block-timestamp (unwrap-panic (get-stacks-block-info? time (- stacks-block-height (var-get block-delay)))))
    (state (contract-call? .minting-state-v1 get-request-redeem-state contract-caller))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (get redeem-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get whitelisted state) ERR_NOT_WHITELISTED)
    (asserts! (check-is-supported-asset redeeming-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (try! (verify-price price conf-tolerance-bps oracle-data redeeming-asset-contract))
    (asserts! (> oracle-timestamp block-timestamp) ERR_STALE_DATA)
    (asserts! (>= amount-usdh (get min-amount-usdh state)) ERR_BELOW_MIN)
    (asserts! (<= slippage bps-base) ERR_ABOVE_MAX)

    (try! (contract-call? .usdh-token-v1 transfer amount-usdh contract-caller this-contract none))

    (map-set redeem-requests { request-id: next-redeem-id }
      {
        requester: contract-caller,
        redeeming-asset: redeeming-asset-contract,
        amount-usdh: amount-usdh,
        price: price,
        slippage: slippage,
        block-height: burn-block-height,
      }
    )
    (print { request-id: next-redeem-id, requester: contract-caller, redeeming-asset: redeeming-asset-contract, amount-asset-requested: amount-asset-requested, amount-usdh: amount-usdh, price: price,  slippage: slippage, block-height: burn-block-height })
    (ok (var-set current-redeem-id next-redeem-id))
  )
)

(define-public (claim-unconfirmed-redeem-many (entries (list 1000 uint)))
  (ok (map claim-unconfirmed-redeem entries)))

(define-public (claim-unconfirmed-redeem (redeem-id uint))
  (let (
    (redeem-request (try! (get-redeem-request redeem-id)))
  )
    (asserts! (> burn-block-height (+ (get block-height redeem-request) (contract-call? .minting-state-v1 get-redeem-confirmation-window))) ERR_CONFIRMATION_OPEN)

    (try! (contract-call? .usdh-token-v1 transfer (get amount-usdh redeem-request) this-contract (get requester redeem-request) none))
    (ok (map-delete redeem-requests { request-id: redeem-id }))
  )
)

;;-------------------------------------
;; Trader
;;-------------------------------------

(define-public (confirm-mint (request-id uint) (price uint) (amount-asset-confirmed uint) (minting-asset <sip-010-trait>) (custody-address principal) (memo (optional (buff 34))))
  (let (
    (mint-request (try! (get-mint-request request-id)))
    (price-requested (get price mint-request))
    (requester (get requester mint-request))
    (amount-asset-requested (get amount-asset mint-request))
    (minting-asset-contract (get minting-asset mint-request))
    (slippage-tolerance (/ (* price-requested (get slippage mint-request)) bps-base))
    (token-base (get token-base (try! (get-supported-asset (contract-of minting-asset)))))
    (state (contract-call? .minting-state-v1 get-confirm-mint-state))
    (fee-address (get fee-address state))
    (amount-asset-fee (/ (* amount-asset-confirmed (get mint-fee-asset state)) bps-base))
    (amount-usdh (/ (* (- amount-asset-confirmed amount-asset-fee) price usdh-base) price-base token-base))
    (amount-usdh-fee (/ (* amount-usdh (get mint-fee-usdh state)) bps-base))
    (amount-usdh-confirmed (- amount-usdh amount-usdh-fee))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (get mint-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get minter (get-trader contract-caller)) ERR_NOT_ALLOWED)
    (asserts! (get-custody-address-active custody-address) ERR_NOT_CUSTODY_ADDRESS)
    (asserts! (is-standard custody-address) ERR_NOT_STANDARD_PRINCIPAL)
    (asserts! (check-is-supported-asset minting-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (is-eq minting-asset-contract (contract-of minting-asset)) ERR_ASSET_MISMATCH)
    (asserts! (<= amount-asset-confirmed amount-asset-requested) ERR_AMOUNT_NOT_ALLOWED)
    (asserts! (>= price (- price-requested slippage-tolerance)) ERR_SLIPPAGE_TOO_HIGH)

    (try! (contract-call? .usdh-token-v1 mint-for-protocol amount-usdh-confirmed requester))
    (if (> amount-usdh-fee u0) (try! (contract-call? .usdh-token-v1 mint-for-protocol amount-usdh-fee fee-address)) true)
    (try! (contract-call? minting-asset transfer (- amount-asset-confirmed amount-asset-fee) this-contract custody-address memo))
    (if (> amount-asset-fee u0) (try! (contract-call? minting-asset transfer amount-asset-fee this-contract fee-address none)) true)
    (if (not (is-eq amount-asset-requested amount-asset-confirmed))
      (try! (contract-call? minting-asset transfer (- amount-asset-requested amount-asset-confirmed) this-contract requester none))
      true
    )

    (map-delete mint-requests { request-id: request-id })
    (print { request-id: request-id, price: price, amount-usdh-confirmed: amount-usdh-confirmed, minting-asset: minting-asset-contract })
    (ok true)
  )
)

(define-public (cancel-mint-request-many (entries (list 1000 { request-id: uint, minting-asset: <sip-010-trait> })))
  (ok (map cancel-mint-request entries)))

(define-public (cancel-mint-request (entry { request-id: uint, minting-asset: <sip-010-trait> }))
  (let (
    (mint-request (try! (get-mint-request (get request-id entry))))
    (minting-asset-entry (get minting-asset entry))
    (token-base (get token-base (try! (get-supported-asset (contract-of minting-asset-entry)))))
    (price (get price mint-request))
    (amount-asset (get amount-asset mint-request))
    (amount-usdh-requested (/ (* amount-asset price usdh-base) price-base token-base))
    (new-mint-limit (+ (get-current-mint-limit) amount-usdh-requested))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (contract-call? .minting-state-v1 get-mint-enabled) ERR_TRADING_DISABLED)
    (asserts! (get minter (get-trader contract-caller)) ERR_NOT_ALLOWED)
    (asserts! (is-eq (get minting-asset mint-request) (contract-of minting-asset-entry)) ERR_ASSET_MISMATCH)

    (try! (contract-call? minting-asset-entry transfer amount-asset this-contract (get requester mint-request) none))
    (map-delete mint-requests { request-id: (get request-id entry) })
    (ok (if (<= new-mint-limit (get-mint-limit)) (var-set current-mint-limit new-mint-limit) (var-set current-mint-limit (get-mint-limit))))
  )
)

(define-public (confirm-redeem (request-id uint) (price uint) (amount-usdh-confirmed uint) (redeeming-asset <sip-010-trait>) (memo (optional (buff 34))))
  (let (
    (redeem-request (try! (get-redeem-request request-id)))
    (price-requested (get price redeem-request))
    (requester (get requester redeem-request))
    (amount-usdh-requested (get amount-usdh redeem-request))
    (redeeming-asset-contract (get redeeming-asset redeem-request))
    (slippage-tolerance (/ (* price-requested (get slippage redeem-request)) bps-base))
    (token-base (get token-base (try! (get-supported-asset (contract-of redeeming-asset)))))
    (state (contract-call? .minting-state-v1 get-confirm-redeem-state))
    (fee-address (get fee-address state))
    (amount-usdh-fee (/ (* amount-usdh-confirmed (get redeem-fee-usdh state)) bps-base))
    (amount-asset (/ (* (- amount-usdh-confirmed amount-usdh-fee) price-base token-base) price usdh-base))
    (amount-asset-fee (/ (* amount-asset (get redeem-fee-asset state)) bps-base))
    (amount-asset-confirmed (- amount-asset amount-asset-fee))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (get redeem-enabled state) ERR_TRADING_DISABLED)
    (asserts! (get redeemer (get-trader contract-caller)) ERR_NOT_ALLOWED)
    (asserts! (check-is-supported-asset redeeming-asset-contract) ERR_NOT_SUPPORTED_ASSET)
    (asserts! (is-eq redeeming-asset-contract (contract-of redeeming-asset)) ERR_ASSET_MISMATCH)
    (asserts! (<= amount-usdh-confirmed amount-usdh-requested) ERR_AMOUNT_NOT_ALLOWED)
    (asserts! (<= price (+ price-requested slippage-tolerance)) ERR_SLIPPAGE_TOO_HIGH)

    (try! (contract-call? .redeeming-reserve-v1-2 transfer amount-asset-confirmed requester redeeming-asset memo))
    (if (> amount-asset-fee u0) (try! (contract-call? .redeeming-reserve-v1-2 transfer amount-asset-fee fee-address redeeming-asset none)) true)
    (try! (contract-call? .usdh-token-v1 burn-for-protocol (- amount-usdh-confirmed amount-usdh-fee) this-contract))
    (if (> amount-usdh-fee u0) (try! (contract-call? .usdh-token-v1 transfer amount-usdh-fee this-contract fee-address none)) true)
    (if (not (is-eq amount-usdh-requested amount-usdh-confirmed))
      (try! (contract-call? .usdh-token-v1 transfer (- amount-usdh-requested amount-usdh-confirmed) this-contract requester none))
      true
    )

    (map-delete redeem-requests { request-id: request-id })
    (print { request-id: request-id, price: price, amount-asset-confirmed: amount-asset-confirmed, redeeming-asset: redeeming-asset-contract })
    (ok true)
  )
)

(define-public (cancel-redeem-request-many (entries (list 1000 uint)))
  (ok (map cancel-redeem-request entries)))

(define-public (cancel-redeem-request (request-id uint))
  (let (
    (redeem-request (try! (get-redeem-request request-id)))
  )
    (try! (contract-call? .hq-v1 check-is-enabled))
    (asserts! (contract-call? .minting-state-v1 get-redeem-enabled) ERR_TRADING_DISABLED)
    (asserts! (get redeemer (get-trader contract-caller)) ERR_NOT_ALLOWED)

    (try! (contract-call? .usdh-token-v1 transfer (get amount-usdh redeem-request) this-contract (get requester redeem-request) none))
    (ok (map-delete redeem-requests { request-id: request-id }))
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

(define-public (set-block-delay (new-amount uint))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (<= new-amount max-block-delay) ERR_ABOVE_MAX)
    (asserts! (> new-amount u0) ERR_BELOW_MIN)
    (print { old-value: (get-block-delay), new-value: new-amount })
    (ok (var-set block-delay new-amount))
  )
)

(define-public (set-trader (address principal) (mint bool) (redeem bool))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: address, old-values: (get-trader address), new-values: { minter: mint, redeemer: redeem } })
    (ok (map-set traders { address: address } { minter: mint, redeemer: redeem}))
  )
)

(define-public (set-custody-address (custody-address principal) (active bool))
  (begin
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (is-standard custody-address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { address: custody-address, old-value: (get-custody-address-active custody-address), new-value: active })
    (ok (map-set custody-addresses {address: custody-address} {active: active}))
  )
)

(define-public (set-supported-asset (token <sip-010-trait>) (active bool) (price-feed-id (buff 32)) (conf-tolerance-bps uint))
  (let (
    (token-address (contract-of token))
    (token-base (pow u10 (unwrap-panic (contract-call? token get-decimals))))
  )
    (try! (contract-call? .hq-v1 check-is-protocol contract-caller))
    (asserts! (<= conf-tolerance-bps bps-base) ERR_MAX_CONF_TOO_HIGH)
    (if (check-is-supported-asset token-address)
      (print {
        contract: token-address,
        old-values: (some (unwrap-panic (get-supported-asset token-address))),
        new-values: { active: active, price-feed-id: price-feed-id, token-base: token-base, conf-tolerance-bps: conf-tolerance-bps } })
      (print {
        contract: token-address, 
        old-values: none, 
        new-values: { active: active, price-feed-id: price-feed-id, token-base: token-base, conf-tolerance-bps: conf-tolerance-bps } })
    )
    (ok (map-set supported-assets { contract: (contract-of token) } { active: active, price-feed-id: price-feed-id, token-base: token-base, conf-tolerance-bps: conf-tolerance-bps }))
  )
)