;; @contract Vault State
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_SILO (err u102001))
(define-constant ERR_NOT_TRADING_ASSET (err u102002))
(define-constant ERR_NOT_STANDARD_PRINCIPAL (err u102003))
(define-constant ERR_NOT_CONNECTION (err u102004))
(define-constant ERR_TRANSFER_DISABLED (err u102005))
(define-constant ERR_VAULT_DISABLED (err u102006))
(define-constant ERR_DEPOSIT_DISABLED (err u102007))
(define-constant ERR_WITHDRAW_DISABLED (err u102008))
(define-constant ERR_TRADING_DISABLED (err u102009))
(define-constant ERR_ABOVE_MAX (err u102010))
(define-constant ERR_BELOW_MIN (err u102011))
(define-constant ERR_UPDATE_WINDOW_CLOSED (err u102012))
(define-constant ERR_NO_ENTRY (err u102013))
(define-constant ERR_ENTRY_ALREADY_EXISTS (err u102014))
(define-constant ERR_ACTIVATION (err u102015))

(define-constant max-reward u20)                                  ;; bps                                   
(define-constant min-update-window u60)                           ;; 1 minute in seconds
(define-constant max-slippage u500)                               ;; bps; 5%
(define-constant max-exit-fee u100)                               ;; bps; 1% 
(define-constant max-perf-fee u2000)                              ;; bps; 20%
(define-constant max-mgmt-fee u54)                                ;; 1/100 of bps; 0.0054% per day / 2% annualized

(define-constant max-cooldown-window u2592000)                    ;; 30 days in seconds
(define-constant max-block-delay u7200)                           ;; 5 min in stacks blocks (block time = 5 sec)

(define-constant init-ts (some (get-current-ts)))

(define-constant bps-base (pow u10 u4))                           ;; 100%
(define-constant hbtc-base (pow u10 u8))                          ;; 10**8

;;-------------------------------------
;; Variables
;;-------------------------------------


(define-data-var fee-address principal 'SP1GBFF44X014QYZ9V6K03GN2H5JF9S59GKKTRGAS)
(define-data-var fees 
  { mgmt-fee: uint, perf-fee: uint, exit-fee: uint } 
  { mgmt-fee: u0, perf-fee: u1000, exit-fee: u0 })
(define-data-var token-price uint hbtc-base)
(define-data-var cooldown-window uint u120)                       ;; time in s (2 minutes)
(define-data-var deposit-cap uint u10000000)                      ;; 0.1 BTC 
(define-data-var min-deposit-amount uint u0)

(define-data-var max-reward-per-window uint u5)                   ;; bps
(define-data-var update-window uint u60)                          ;; 1 minute in seconds
(define-data-var reserve-rate uint u500)                          ;; bps
(define-data-var last-log-ts uint u0)                             ;; timestamp
(define-data-var block-delay uint u10)                            ;; block delay for staleness check (=~50 seconds)

(define-data-var vault-enabled bool true)
(define-data-var transfer-enabled bool true)
(define-data-var deposit-enabled bool true)
(define-data-var withdraw-enabled bool true)
(define-data-var trading-enabled bool true)

;;-------------------------------------
;; Maps
;;-------------------------------------

;; sip-010 tokens that can be traded by the vault
(define-map trading-assets
  {
    address: principal
  }
  {
    active: bool,
    ts: (optional uint),
    price-feed-id: (buff 32),                                     ;; pyth price feed id to identify the asset 
    token-base: uint,
    max-slippage: uint,                                           ;; bps; max swap slippage allowed for the asset
    is-stablecoin: bool,                                          ;; whether the asset is a stablecoin. True for USD stablecoins (uses fixed $1.00 price), False for other assets (uses pyth oracle).
  }
)

;; external contracts that interface contracts can interact with
(define-map connections 
  {
    address: principal
  }
  {
    active: bool,
    ts: (optional uint)
  }
)

;; silo contracts to which pending withdraws can be transferred to
(define-map silos 
  {
    address: principal
  }
  {
    active: bool,
    ts: (optional uint)
  }
)

(define-map custom-cooldown
  { 
    address: principal
  }
  {
    cooldown-window: uint
  }
)

(define-map custom-exit-fee
  {
    address: principal
  }
  {
    exit-fee: uint
  }
)

;;-------------------------------------
;; Helper
;;-------------------------------------

(define-private (get-current-ts)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-fee-address)
  (var-get fee-address)
)

(define-read-only (get-fees)
  (var-get fees)
)

(define-read-only (get-token-price)
  (var-get token-price)
)

(define-read-only (get-cooldown-window)
  (var-get cooldown-window)
)

(define-read-only (get-custom-cooldown (address principal))
  (get cooldown-window
    (default-to
      { cooldown-window: (get-cooldown-window) }
      (map-get? custom-cooldown { address: address }))
  )
)

(define-read-only (get-custom-exit-fee (address principal))
  (get exit-fee
    (default-to
      { exit-fee: (get exit-fee (get-fees)) }
      (map-get? custom-exit-fee { address: address }))
  )
)

(define-read-only (get-deposit-cap)
  (var-get deposit-cap)
)

(define-read-only (get-max-reward-per-window)
  (var-get max-reward-per-window)
)

(define-read-only (get-update-window)
  (var-get update-window)
)

(define-read-only (get-reserve-rate)
  (var-get reserve-rate)
)

(define-read-only (get-last-log-ts)
  (var-get last-log-ts)
)

(define-read-only (get-block-delay)
  (var-get block-delay)
)

(define-read-only (get-vault-enabled)
  (var-get vault-enabled)
)

(define-read-only (get-transfer-enabled)
  (var-get transfer-enabled)
)

(define-read-only (get-deposit-enabled)
  (var-get deposit-enabled)
)

(define-read-only (get-withdraw-enabled)
  (var-get withdraw-enabled)
)

(define-read-only (get-trading-enabled)
  (var-get trading-enabled))

(define-read-only (get-trading-asset (address principal))
  (default-to 
    { active: false, ts: none, price-feed-id: 0x, token-base: u0, max-slippage: u0, is-stablecoin: false } 
    (map-get? trading-assets { address: address })
  )
)

(define-read-only (get-connection (address principal))
  (default-to 
    { active: false, ts: none } 
    (map-get? connections { address: address })
  )
)

(define-read-only (get-silo (address principal))
  (default-to 
    { active: false, ts: none }  
    (map-get? silos { address: address })
  )
)

(define-read-only (get-min-deposit-amount)
  (var-get min-deposit-amount)
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-vault-enabled)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol-enabled))
    (ok (asserts! (get-vault-enabled) ERR_VAULT_DISABLED))
  )
)

(define-read-only (check-is-deposit-enabled)
  (begin
    (try! (check-is-vault-enabled))
    (ok (asserts! (get-deposit-enabled) ERR_DEPOSIT_DISABLED))
  )
)

(define-read-only (check-is-withdraw-enabled)
  (begin
    (try! (check-is-vault-enabled))
    (ok (asserts! (get-withdraw-enabled) ERR_WITHDRAW_DISABLED))
  )
)

(define-read-only (check-is-transfer-enabled)
  (begin
    (try! (check-is-vault-enabled))
    (ok (asserts! (get-transfer-enabled) ERR_TRANSFER_DISABLED))
  )
)

(define-read-only (check-is-trading-enabled)
  (begin
    (try! (check-is-vault-enabled))
    (ok (asserts! (get-trading-enabled) ERR_TRADING_DISABLED))
  )
) 

(define-read-only (check-is-trading-asset (address principal))
  (ok (asserts! (get active (get-trading-asset address)) ERR_NOT_TRADING_ASSET))
)

(define-read-only (check-is-connection (address principal))
  (ok (asserts! (get active (get-connection address)) ERR_NOT_CONNECTION))
)

(define-read-only (check-is-silo (address principal))
  (ok (asserts! (get active (get-silo address)) ERR_NOT_SILO))
)

(define-read-only (check-is-update-window-open)
  (ok (asserts! (> (get-current-ts) (+ (get-last-log-ts) (get-update-window))) ERR_UPDATE_WINDOW_CLOSED))
)

(define-read-only (check-max-reward (amount uint) (vault-balance uint))
    (ok (asserts! (<= amount (/ (* (get-max-reward-per-window) vault-balance) bps-base)) ERR_ABOVE_MAX))
)

(define-public (check-connections-and-assets (connection-a principal) (connection-b (optional principal)) (asset-a (optional principal)) (asset-b (optional principal)))
  (begin
    (try! (check-is-connection connection-a))
    (match connection-b value (try! (check-is-connection value)) true)
    (match asset-a value (try! (check-is-trading-asset value)) true)
    (ok (match asset-b value (try! (check-is-trading-asset value)) true))
  )
)

;;-------------------------------------
;; Setters
;;-------------------------------------

(define-public (set-fee-address (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (is-standard address) ERR_NOT_STANDARD_PRINCIPAL)
    (print { action: "set-fee-address", user: contract-caller, data: { old-value: (get-fee-address), new-value: address } })
    (ok (var-set fee-address address))
  )
)

(define-public (set-fees (mgmt-fee uint) (perf-fee uint) (exit-fee uint))
  (let (
    (new-fees { mgmt-fee: mgmt-fee, perf-fee: perf-fee, exit-fee: exit-fee })
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (<= mgmt-fee max-mgmt-fee) ERR_ABOVE_MAX)
    (asserts! (<= perf-fee max-perf-fee) ERR_ABOVE_MAX)
    (asserts! (<= exit-fee max-exit-fee) ERR_ABOVE_MAX)
    (print { action: "set-fees", user: contract-caller, data: { old-value: (get-fees), new-value: new-fees } })
    (ok (var-set fees new-fees))
  )
)

(define-public (set-token-price (price uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol contract-caller))
    (print { action: "set-token-price", user: contract-caller, data: { old-value: (get-token-price), new-value: price } })
    (ok (var-set token-price price))
  )
)

(define-public (set-cooldown-window (new-window uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (<= new-window max-cooldown-window ) ERR_ABOVE_MAX)
    (print { action: "set-cooldown-window", user: contract-caller, data: { old-value: (get-cooldown-window), new-value: new-window } })
    (ok (var-set cooldown-window new-window))
  )
)

(define-public (set-custom-cooldown (address principal) (new-window uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (<= new-window max-cooldown-window) ERR_ABOVE_MAX)
    (print {action: "set-custom-cooldown", user: contract-caller, data: { address: address, old-value: (get-custom-cooldown address), new-value: new-window}})
    (ok (map-set custom-cooldown {  address: address } { cooldown-window: new-window }))
  )
)

(define-public (set-custom-exit-fee (address principal) (new-exit-fee uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-fee-setter contract-caller))
    (asserts! (<= new-exit-fee max-exit-fee) ERR_ABOVE_MAX)
    (print { action: "set-custom-exit-fee", user: contract-caller, data: { address: address, old-value: (get-custom-exit-fee address), new-value: new-exit-fee } })
    (ok (map-set custom-exit-fee { address: address } { exit-fee: new-exit-fee }))
  )
)

(define-public (set-deposit-cap (amount uint))  
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-deposit-cap", user: contract-caller, data: { old-value: (get-deposit-cap), new-value: amount } })
    (ok (var-set deposit-cap amount))
  )
)

(define-public (set-max-reward-per-window (new-max-reward-per-window uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (<= new-max-reward-per-window max-reward) ERR_ABOVE_MAX)
    (print { 
      action: "set-max-reward-per-window", user: contract-caller, data: { old-value: (get-max-reward-per-window), new-value: new-max-reward-per-window } 
    })
    (ok (var-set max-reward-per-window new-max-reward-per-window))
  )
)

(define-public (set-update-window (new-update-window uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (>= new-update-window min-update-window) ERR_BELOW_MIN)
    (print { 
      action: "set-update-window", user: contract-caller, data: { old-value: (get-update-window), new-value: new-update-window } 
    })
    (ok (var-set update-window new-update-window))
  )
)

(define-public (set-reserve-rate (new-reserve-rate uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { 
      action: "set-reserve-rate", user: contract-caller, data: { old-value: (get-reserve-rate), new-value: new-reserve-rate } 
    })
    (ok (var-set reserve-rate new-reserve-rate))
  )
)

(define-public (set-block-delay (new-block-delay uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (asserts! (<= new-block-delay max-block-delay) ERR_ABOVE_MAX)
    (print { 
      action: "set-block-delay", user: contract-caller, data: { old-value: (get-block-delay), new-value: new-block-delay } 
    })
    (ok (var-set block-delay new-block-delay))
  )
)

(define-public (update-last-log-ts)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol contract-caller))
    (print { action: "update-last-log-ts", user: contract-caller, data: { old-value: (get-last-log-ts), new-value: (get-current-ts) } })
    (ok (var-set last-log-ts (get-current-ts)))
  )
)

(define-public (set-vault-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-vault-enabled", user: contract-caller, data: { old-value: (get-vault-enabled), new-value: enabled } })
    (ok (var-set vault-enabled enabled))
  )
)

(define-public (disable-vault)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-vault", user: contract-caller, data: { old-value: (get-vault-enabled), new-value: false } })
    (ok (var-set vault-enabled false))
  )
)

(define-public (set-transfer-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-transfer-enabled", user: contract-caller, data: { old-value: (get-transfer-enabled), new-value: enabled } })
    (ok (var-set transfer-enabled enabled))
  )
)

(define-public (disable-transfer)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-transfer", user: contract-caller, data: { old-value: (get-transfer-enabled), new-value: false } })
    (ok (var-set transfer-enabled false))
  )
)

(define-public (set-deposit-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-deposit-enabled", user: contract-caller, data: { old-value: (get-deposit-enabled), new-value: enabled } })
    (ok (var-set deposit-enabled enabled))
  )
)

(define-public (disable-deposits)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-deposits", user: contract-caller, data: { old-value: (get-deposit-enabled), new-value: false } })
    (ok (var-set deposit-enabled false))
  )
)

(define-public (set-withdraw-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-withdraw-enabled", user: contract-caller, data: { old-value: (get-withdraw-enabled), new-value: enabled } })
    (ok (var-set withdraw-enabled enabled))
  )
)

(define-public (disable-withdraw)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-withdraw", user: contract-caller, data: { old-value: (get-withdraw-enabled), new-value: false } })
    (ok (var-set withdraw-enabled false))

  )
)

(define-public (set-trading-enabled (enabled bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-trading-enabled", user: contract-caller, data: { old-value: (get-trading-enabled), new-value: enabled } })
    (ok (var-set trading-enabled enabled))
  )
)

(define-public (disable-trading)
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-guardian contract-caller))
    (print { action: "disable-trading", user: contract-caller, data: { old-value: (get-trading-enabled), new-value: false } })
    (ok (var-set trading-enabled false))
  )
)

(define-public (request-new-trading-asset (token <ft>) (price-feed-id (buff 32)) (new-max-slippage uint) (is-stablecoin bool))
  (let (
    (token-address (contract-of token))
    (token-base (pow u10 (unwrap-panic (contract-call? token get-decimals))))
    (new-entry { active: false, ts: (some (get-current-ts)), price-feed-id: price-feed-id, token-base: token-base, max-slippage: new-max-slippage, is-stablecoin: is-stablecoin })
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (<= new-max-slippage max-slippage) ERR_ABOVE_MAX)
    (print { action: "request-new-trading-asset", user: contract-caller, data: { token-address: token-address, old-value: (get-trading-asset token-address), new-value: new-entry } })
    (ok (asserts! (map-insert trading-assets { address: token-address } new-entry) ERR_ENTRY_ALREADY_EXISTS))
  )
)

(define-public (remove-trading-asset (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (print { action: "remove-trading-asset", user: contract-caller, data: { address: address, old-value: (get-trading-asset address) } })
    (ok (map-delete trading-assets { address: address }))
  )
)

(define-public (activate-trading-asset (address principal))
  (let (
    (entry (get-trading-asset address))
    (ts (unwrap! (get ts entry) ERR_NO_ENTRY))
    (updated-entry (merge entry { active: true }))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (>= (get-current-ts) (+ ts (contract-call? .test-hq-vaults-v1 get-activation-delay))) ERR_ACTIVATION)
    (print { action: "activate-trading-asset", user: contract-caller, data: { address: address, old-value: entry, new-value: updated-entry } })
    (ok (map-set trading-assets { address: address } updated-entry))
  )
)

(define-public (set-max-slippage (address principal) (new-max-slippage uint))
  (let (
    (entry (get-trading-asset address))
    (updated-entry (merge entry { max-slippage: new-max-slippage }))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (<= new-max-slippage max-slippage) ERR_ABOVE_MAX)
    (print { action: "set-max-slippage", user: contract-caller, data: { address: address, old-value: entry, new-value: updated-entry } })
    (ok (map-set trading-assets { address: address } updated-entry))
  )
)

(define-public (request-new-connection (address principal))
  (let (
    (new-entry { active: false, ts: (some (get-current-ts)) })
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (print { action: "request-new-connection", user: contract-caller, data: { address: address, old-value: (get-connection address), new-value: new-entry } })
    (ok (asserts! (map-insert connections { address: address } new-entry) ERR_ENTRY_ALREADY_EXISTS))
  )
)

(define-public (remove-connection (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (print { action: "remove-connection", user: contract-caller, data: { address: address, old-value: (get-connection address) } })
    (ok (map-delete connections { address: address }))
  )
)

(define-public (activate-connection (address principal))
  (let (
    (entry (get-connection address))
    (ts (unwrap! (get ts entry) ERR_NO_ENTRY))
    (updated-entry (merge entry { active: true }))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (>= (get-current-ts) (+ ts (contract-call? .test-hq-vaults-v1 get-activation-delay))) ERR_ACTIVATION)
    (print { action: "activate-connection", user: contract-caller, data: { address: address, old-value: entry, new-value: updated-entry } })
    (ok (map-set connections { address: address } updated-entry))
  )
)

(define-public (request-new-silo (address principal))
  (let (
    (new-entry { active: false, ts: (some (get-current-ts)) })
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (print { action: "request-new-silo", user: contract-caller, data: { address: address, old-value: (get-silo address), new-value: new-entry } })
    (ok (asserts! (map-insert silos { address: address } new-entry) ERR_ENTRY_ALREADY_EXISTS))
  )
)

(define-public (remove-silo (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (print { action: "remove-silo", user: contract-caller, data: { address: address, old-value: (get-silo address) } })
    (ok (map-delete silos { address: address }))
  )
)

(define-public (activate-silo (address principal))
  (let (
    (entry (get-silo address))
    (ts (unwrap! (get ts entry) ERR_NO_ENTRY))
    (updated-entry (merge entry { active: true }))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-owner contract-caller))
    (asserts! (>= (get-current-ts) (+ ts (contract-call? .test-hq-vaults-v1 get-activation-delay))) ERR_ACTIVATION)
    (print { action: "activate-silo", user: contract-caller, data: { address: address, old-value: entry, new-value: updated-entry } })
    (ok (map-set silos { address: address } updated-entry))
  )
)

(define-public (set-min-deposit-amount (amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v1 check-is-admin contract-caller))
    (print { action: "set-min-deposit-amount", user: contract-caller, data: { old-value: (get-min-deposit-amount), new-value: amount } })
    (ok (var-set min-deposit-amount amount))
  )
)

;;-------------------------------------
;; Init
;;-------------------------------------

;; Initialize trading assets
(map-set trading-assets { address: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token } { active: true, ts: init-ts, price-feed-id: 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43, token-base: (pow u10 u8), max-slippage: u100, is-stablecoin: false })
(map-set trading-assets { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 } { active: true, ts: init-ts, price-feed-id: 0x00, token-base: (pow u10 u8), max-slippage: u100, is-stablecoin: true })
(map-set trading-assets { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.susdh-token-v1 } { active: true, ts: init-ts, price-feed-id: 0x01, token-base: (pow u10 u8), max-slippage: u100, is-stablecoin: false })
(map-set trading-assets { address: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc } { active: true, ts: init-ts, price-feed-id: 0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: true })
(map-set trading-assets { address: 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx } { active: true, ts: init-ts, price-feed-id: 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: false })
(map-set trading-assets { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 } { active: true, ts: init-ts, price-feed-id: 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: false })

(map-set connections { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-v1 } { active: true, ts: init-ts })
(map-set connections { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-silo-v1 } { active: true, ts: init-ts })
(map-set connections { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.minting-auto-v1-1 } { active: true, ts: init-ts })
(map-set connections { address: 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-7 } { active: true, ts: init-ts })
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 } { active: true, ts: init-ts })
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 } { active: true, ts: init-ts })
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3 } { active: true, ts: init-ts })
(map-set connections { address: 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.borrower-v1 } { active: true, ts: init-ts })
;; Initialize Bitflow pool contracts
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2 } { active: true, ts: init-ts })
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 } { active: true, ts: init-ts })
(map-set connections { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 } { active: true, ts: init-ts })

;; Initialize silos
(map-set silos { address: .test-silo-hbtc3-v1 } { active: true, ts: init-ts })
