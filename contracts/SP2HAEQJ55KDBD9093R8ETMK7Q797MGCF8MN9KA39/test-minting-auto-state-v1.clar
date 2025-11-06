;; @contract Minting Auto State
;; @version 1

(use-trait sip-010-trait .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_SUPPORTED_ASSET (err u2401))
(define-constant ERR_ABOVE_MAX (err u2402))
(define-constant ERR_BELOW_MIN (err u2403))
(define-constant ERR_MAX_CONF_TOO_HIGH (err u2404))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u2405))

(define-constant bps-base u10000)
(define-constant usdh-base (pow u10 u8))
(define-constant max-block-delay u10)                             ;; max block delay to get timestamp from stacks block
(define-constant max-price-slippage u1000)                        ;; in bps = 10%

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var mint-fee uint u0)                                ;; bps
(define-data-var redeem-fee uint u0)                              ;; bps
(define-data-var fee-address principal tx-sender)                 ;; fee address for minting and redeeming fees

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
    block-delay: uint,                                            ;; stacks blocks
    price-slippage: uint,
    custody-address: (optional principal)                         ;; custody address for the asset
  }
)

(define-map supported-assets
  {
    contract: principal 
  }
  {
    active: bool,
    price-feed-id: (buff 32),                                     ;; pyth price feed id to identify the asset 
    token-base: uint,
    conf-tolerance-bps: uint                                      ;; asset max. confidence tolerance in bps to check pyth price feed confidence 
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-whitelist (address principal) (asset principal))
  (default-to 
    { minter: false, redeemer: false, block-delay: u1, price-slippage: u0, custody-address: none}
    (map-get? whitelist { address: address, asset: asset })
  )
)

(define-read-only (get-supported-asset (contract principal))
  (ok (unwrap! (map-get? supported-assets { contract: contract }) ERR_NOT_SUPPORTED_ASSET))
)

(define-read-only (get-mint-fee)
  (var-get mint-fee)
)

(define-read-only (get-redeem-fee)
  (var-get redeem-fee)
)

(define-read-only (get-fee-address)
  (var-get fee-address)
)

(define-read-only (check-is-supported-asset (contract principal))
  (get active
    (default-to
      { active: false }
      (map-get? supported-assets { contract: contract })
    )
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-read-only (get-state (caller-address principal) (asset-contract principal))
  (let (
    (whitelist-data (get-whitelist caller-address asset-contract))
    (supported-asset-data (try! (get-supported-asset asset-contract)))
  )
  (ok {
    price-slippage-bps: (get price-slippage whitelist-data),
    block-delay: (get block-delay whitelist-data),
    is-minter: (get minter whitelist-data),
    is-redeemer: (get redeemer whitelist-data),
    custody-address: (get custody-address whitelist-data),
    token-base: (get token-base supported-asset-data),
    conf-tolerance-bps: (get conf-tolerance-bps supported-asset-data),
    is-active-asset: (get active supported-asset-data),
    is-supported-asset: (check-is-supported-asset asset-contract),
    price-feed-id: (get price-feed-id supported-asset-data),
    mint-fee: (get-mint-fee),
    redeem-fee: (get-redeem-fee),
    fee-address: (get-fee-address)
  })
  )
)


;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-whitelist (address principal) (asset principal) (minter bool) (redeemer bool) (block-delay uint) (price-slippage uint) (custody-address principal))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (asserts! (is-standard asset) ERR_NOT_STANDARD_PRINCIPAL)
    (asserts! (is-standard custody-address) ERR_NOT_STANDARD_PRINCIPAL)
    (asserts! (<= block-delay max-block-delay) ERR_ABOVE_MAX)
    (asserts! (> block-delay u0) ERR_BELOW_MIN)
    (asserts! (<= price-slippage max-price-slippage) ERR_ABOVE_MAX)
    (print { address: address, asset: asset, old-values: (get-whitelist address asset),  new-values: { minter: minter, redeemer: redeemer, block-delay: block-delay, price-slippage: price-slippage, custody-address: (some custody-address) } })
    (ok (map-set whitelist { address: address, asset: asset } { minter: minter, redeemer: redeemer, block-delay: block-delay, price-slippage: price-slippage, custody-address: (some custody-address) }))
  )
)

(define-public (set-supported-asset (token <sip-010-trait>) (active bool) (price-feed-id (buff 32)) (conf-tolerance-bps uint))
  (let (
    (token-address (contract-of token))
    (token-base (pow u10 (unwrap-panic (contract-call? token get-decimals))))
  )
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
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
    (ok (map-set supported-assets { contract: token-address } { active: active, price-feed-id: price-feed-id, token-base: token-base, conf-tolerance-bps: conf-tolerance-bps }))
  )
)

(define-public (set-mint-fee (new-fee uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (< new-fee bps-base) ERR_ABOVE_MAX)
    (print { old-value: (get-mint-fee), new-value: new-fee })
    (ok (var-set mint-fee new-fee)))
)

(define-public (set-redeem-fee (new-fee uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (< new-fee bps-base) ERR_ABOVE_MAX)
    (print { old-value: (get-redeem-fee), new-value: new-fee })
    (ok (var-set redeem-fee new-fee)))
)

(define-public (set-fee-address (new-fee-address principal))
  (begin
    (try! (contract-call? .test-hq check-is-protocol contract-caller))
    (asserts! (is-standard new-fee-address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { old-value: (get-fee-address), new-value: new-fee-address })
    (ok (var-set fee-address new-fee-address)))
)