;; @contract Vault State
;; @version 0.1

(use-trait ft .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_ASSET (err u102001))
(define-constant ERR_NOT_CONTRACT (err u102002))
(define-constant ERR_TRANSFER_DISABLED (err u102003))
(define-constant ERR_VAULT_DISABLED (err u102004))
(define-constant ERR_DEPOSIT_DISABLED (err u102005))
(define-constant ERR_WITHDRAW_DISABLED (err u102006))
(define-constant ERR_TRADING_DISABLED (err u102007))
(define-constant ERR_ABOVE_MAX (err u102008))
(define-constant ERR_BELOW_MIN (err u102009))
(define-constant ERR_WINDOW_CLOSED (err u102010))
(define-constant ERR_NO_ENTRY (err u102011))
(define-constant ERR_DUPLICATE (err u102012))
(define-constant ERR_ACTIVATION (err u102013))
(define-constant ERR_DEVIATION (err u102014))
(define-constant ERR_INVALID (err u102015))
(define-constant ERR_NO_OPERATIONS (err u102016))

(define-constant max {
  reward: u20,                                                    ;; [20 bps] => 0.20% - max asset reward/loss per log-reward call
  deviation: u50,                                                  ;; [50 bps] => 0.50% - max share price deviation per update
  slippage: u500,                                                 ;; [500 bps] => 5.00% - max slippage for asset trades
  mgmt-fee: u54,                                                  ;; [54 bps/10000] => 0.0054% daily (2% annualized) - max management fee
  perf-fee: u2000,                                                ;; [2000 bps] => 20.00% - max performance fee on profits
  exit-fee: u100,                                                 ;; [100 bps] => 1.00% - max exit fee on withdraws
  reserve-rate: u5000,                                            ;; [5000 bps] => 50.00% - max reserve fund allocation rate
  express-fee: u200,                                              ;; [200 bps] => 2.00% - max express withdraw fee
  cooldown: u2592000,                                             ;; [2592000 seconds] => 30 days - withdraw cooldown period
  block-delay: u60,                                               ;; [60 stacks blocks] => ~5 min - price staleness check
})

(define-constant min {
  update-window: u60,                                           ;; [60 seconds] => 1 minute - min time between reward updates
})

(define-constant pct-base (pow u10 u2))                           ;; 10^2 = 100 (percentage base)
(define-constant bps-base (pow u10 u4))                           ;; 10^4 = 10000 (basis points base)
(define-constant share-base (pow u10 u8))                         ;; 10^8 = 100000000 (share price base) 

;;-------------------------------------
;; Variables
;;-------------------------------------

;; Fee Settings

(define-data-var fee-address principal tx-sender)
(define-data-var fees
  { mgmt-fee: uint, perf-fee: uint, exit-fee: uint, express-fee: uint }
  { mgmt-fee: u0, perf-fee: u1000, exit-fee: u0, express-fee: u50 })

;; Operational Limits
(define-data-var max-reward uint u3)                              ;; [3 bps] => 0.03% - max asset reward/loss per log-reward call
(define-data-var max-deviation uint u5)                           ;; [5 bps] => 0.05% - max share price deviation per update
(define-data-var reserve-rate uint u500)                          ;; [500 bps] => 5.00% - reserve fund allocation rate from profits (log-reward)
(define-data-var deposit-cap uint u0)                             ;; [8 decimals] - maximum total vault capacity
(define-data-var min-amount uint u0)                              ;; [8 decimals] - minimum deposit amount
(define-data-var cooldown uint u60)                           ;; [60 seconds] => 1 minute - default withdraw cooldown period
(define-data-var express-cooldown uint u30)                     ;; [30 seconds] => 30 seconds - express withdraw cooldown period
(define-data-var update-window uint u60)                         ;; [60 seconds] => 1 minute - min time between reward updates
(define-data-var block-delay uint u10)                            ;; [10 stacks blocks] => ~50 seconds - price staleness check

;; Operational States
(define-data-var vault-active bool true)                          ;; vault enabled/disabled flag
(define-data-var transfer-active bool true)                       ;; vault asset transfers enabled/disabled flag (reserve, fee-collector)
(define-data-var deposit-active bool true)                        ;; deposits enabled/disabled flag
(define-data-var withdraw-active bool true)                       ;; withdraws enabled/disabled flag
(define-data-var trading-active bool true)                        ;; trading enabled/disabled flag

;; Accounting Variables
(define-data-var total-assets uint u0)                            ;; [8 decimals] - total assets in the reserve
(define-data-var pending-fees uint u0)                            ;; [8 decimals] - total pending fees payable to protocol
(define-data-var pending-rf uint u0)                              ;; [8 decimals] - total pending reserve fund payable to protocol
(define-data-var pending-claims uint u0)                          ;; [8 decimals] - total pending claims payable to users
(define-data-var claim-id uint u0)                                ;; [counter] - current claim ID
(define-data-var last-log-ts uint u0)                             ;; [unix timestamp] - last reward log timestamp

;;-------------------------------------
;; Maps
;;-------------------------------------

;; sip-010 tokens that the vault can interact with
(define-map assets
  {
    address: principal                                            ;; token contract address
  }
  {
    active: bool,                                                 ;; asset enabled/disabled for trading
    ts: (optional uint),                                          ;; [unix timestamp] - activation/deactivation timestamp
    price-feed-id: (buff 32),                                     ;; [32 bytes] - Pyth price feed identifier
    token-base: uint,                                             ;; [10^decimals] - token decimal base (e.g., 10^6, 10^8)
    max-slippage: uint,                                           ;; [bps] - max swap slippage allowed for this asset
    is-stablecoin: bool,                                          ;; whether asset is USD stablecoin (affects pricing logic)
  }
)

;; external contracts that the vault can interact with 
(define-map contracts 
  {
    address: principal                                            ;; external contract address
  }
  {
    active: bool,                                                 ;; connection enabled/disabled
    ts: (optional uint)                                           ;; [unix timestamp] - activation timestamp
  }
)

(define-map custom-cooldown
  { 
    address: principal                                            ;; user address
  }
  {
    cooldown: uint                                                ;; [seconds] - custom cooldown period for this user
  }
)

(define-map custom-exit-fee
  {
    address: principal                                            ;; user address
  }
  {
    exit-fee: uint                                                ;; [bps] - custom exit fee for this user
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

(define-read-only (get-share-price)
  (let (
    (net-assets (get-net-assets))
    (total-supply (unwrap-panic (contract-call? .test-token-hbtc-v3 get-total-supply)))
  )
    (if (> total-supply u0)
      (/ (* net-assets share-base) total-supply)
      share-base  ;; 1:1 for first deposit
    )
  )
)

(define-read-only (get-net-assets)
  (- (get-total-assets) (get-pending-claims) (get-pending-fees) (get-pending-rf))
)

(define-read-only (get-fee-address)
  (var-get fee-address)
)

(define-read-only (get-fees)
  (var-get fees)
)

(define-read-only (get-total-assets)  
  (var-get total-assets)
)

(define-read-only (get-cooldown)
  (var-get cooldown)
)

(define-read-only (get-express-cooldown)
  (var-get express-cooldown)
)

(define-read-only (get-deposit-cap)
  (var-get deposit-cap)
)

(define-read-only (get-min-amount)
  (var-get min-amount)
)

(define-read-only (get-max-reward)
  (var-get max-reward)
)

(define-read-only (get-max-deviation)
  (var-get max-deviation)
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

(define-read-only (get-pending-fees)
  (var-get pending-fees)
)

(define-read-only (get-pending-rf)
  (var-get pending-rf)
)

(define-read-only (get-pending-claims)
  (var-get pending-claims)
)

(define-read-only (get-pending)
  { fees: (get-pending-fees), rf: (get-pending-rf), claims: (get-pending-claims) }
)

(define-read-only (get-claim-id)
  (var-get claim-id)
)

(define-read-only (get-vault-active)
  (var-get vault-active)
)

(define-read-only (get-transfer-active)
  (var-get transfer-active)
)

(define-read-only (get-deposit-active)
  (var-get deposit-active)
)

(define-read-only (get-withdraw-active)
  (var-get withdraw-active)
)

(define-read-only (get-trading-active)
  (var-get trading-active)
)

(define-read-only (get-asset (address principal))
  (default-to 
    { active: false, ts: none, price-feed-id: 0x, token-base: u0, max-slippage: u0, is-stablecoin: false } 
    (map-get? assets { address: address })
  )
)

(define-read-only (get-contract (address principal))
  (default-to 
    { active: false, ts: none } 
    (map-get? contracts { address: address })
  )
)

(define-read-only (get-custom-cooldown (address principal) (is-express bool))
  (if is-express
    (get-express-cooldown)
    (get cooldown
      (default-to
        { cooldown: (get-cooldown) }
        (map-get? custom-cooldown { address: address })))
  )
)

(define-read-only (get-custom-exit-fee (address principal) (is-express bool))
  (if is-express
    (get express-fee (get-fees))
    (get exit-fee
      (default-to
        { exit-fee: (get exit-fee (get-fees)) }
        (map-get? custom-exit-fee { address: address })))
  )
)

;;-------------------------------------
;; Batch State Getters (Optimization)
;;-------------------------------------

;; @desc - Batch getter for controller reward operations
(define-read-only (get-reward-state)
  { total-assets: (get-total-assets), fees: (get-fees), pending-rf: (get-pending-rf), reserve-rate: (get-reserve-rate) }
)

;; @desc - Batch getter for deposit operation - returns all state needed for deposit validation
(define-read-only (get-deposit-state)
  { share-price: (get-share-price), total-assets: (get-total-assets), deposit-cap: (get-deposit-cap), min-amount: (get-min-amount) }
)

;; @desc - Batch getter for withdraw/redeem operation - returns all data needed
(define-read-only (get-withdraw-state (user principal) (is-express bool))
  { share-price: (get-share-price), exit-fee: (get-custom-exit-fee user is-express), cooldown: (get-custom-cooldown user is-express) }
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-vault-active)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol-active))
    (ok (asserts! (get-vault-active) ERR_VAULT_DISABLED))
  )
)

(define-read-only (check-is-deposit-active)
  (begin
    (try! (check-is-vault-active))
    (ok (asserts! (get-deposit-active) ERR_DEPOSIT_DISABLED))
  )
)

(define-read-only (check-is-withdraw-active)
  (begin
    (try! (check-is-vault-active))
    (ok (asserts! (get-withdraw-active) ERR_WITHDRAW_DISABLED))
  )
)

(define-read-only (check-transfer-auth (asset principal))
  (begin
    (try! (check-is-vault-active))
    (asserts! (get-transfer-active) ERR_TRANSFER_DISABLED)
    (check-is-asset asset)
  )
)

(define-read-only (check-is-trading-active)
  (begin
    (try! (check-is-vault-active))
    (ok (asserts! (get-trading-active) ERR_TRADING_DISABLED))
  )
) 

(define-read-only (check-is-asset (address principal))
  (ok (asserts! (get active (get-asset address)) ERR_NOT_ASSET))
)

(define-read-only (check-is-contract (address principal))
  (ok (asserts! (get active (get-contract address)) ERR_NOT_CONTRACT))
)

(define-read-only (check-update-window)
  (ok (asserts! (>= (get-current-ts) (+ (get-last-log-ts) (get-update-window))) ERR_WINDOW_CLOSED))
)

(define-read-only (check-max-reward (amount uint))
    (ok (asserts! (<= amount (/ (* (get-max-reward) (get-total-assets)) bps-base)) ERR_ABOVE_MAX))
)

(define-public (check-trading-auth (contract-1 principal) (contract-2 (optional principal)) (asset-1 (optional principal)) (asset-2 (optional principal)))
  (begin
    (try! (check-is-trading-active))
    (try! (check-is-contract contract-1))
    (match contract-2 value (try! (check-is-contract value)) true)
    (match asset-1 value (try! (check-is-asset value)) true)
    (ok (match asset-2 value (try! (check-is-asset value)) true))
  )
)

;; Share Price Protection
(define-read-only (check-max-deviation (old-price uint) (new-price uint))
  (let (
    (threshold (get-max-deviation))
    (abs-diff (if (> new-price old-price) 
                  (- new-price old-price) 
                  (- old-price new-price)))
    (deviation (if (> old-price u0)
                  (/ (* abs-diff bps-base) old-price)
                  u0))  ;; Handle edge case of first deposit
  )
    (print { action: "check-max-deviation", data: { old: old-price, new: new-price, deviation: deviation, max-deviation: threshold } })
    (ok (asserts! (<= deviation threshold) ERR_DEVIATION))
  )
)

;;-------------------------------------
;; Protocol/Internal State Updates
;;-------------------------------------

(define-private (update-total-assets (amount uint) (is-add bool))
  (let (
    (current (get-total-assets))
  )
    (var-set total-assets (if is-add (+ current amount) (- current amount)))
    (print { action: "update-total-assets", data: { old: current, new: (get-total-assets), is-add: is-add } })
    (ok true)
  )
)

(define-private (update-shares (amount uint) (is-add bool) (user principal))
  (let (
    (current (unwrap-panic (contract-call? .test-token-hbtc-v3 get-total-supply)))
  )
    (if is-add 
      (try! (contract-call? .test-token-hbtc-v3 mint-for-protocol amount user)) 
      (try! (contract-call? .test-token-hbtc-v3 burn-for-protocol amount user)))
    (print { action: "update-shares", data: { old: current, new: (if is-add (+ current amount) (- current amount)), user: user, is-add: is-add } })
    (ok true)
  )
)

(define-private (update-pending-claims (amount uint) (is-add bool))
  (let (
    (current (get-pending-claims))
  )
    (var-set pending-claims (if is-add (+ current amount) (- current amount)))
    (print { action: "update-pending-claims", data: { old: current, new: (get-pending-claims), is-add: is-add } })
    (ok true)
  )
)

(define-private (update-pending-fees (amount uint) (is-add bool))
  (let (
    (current (get-pending-fees))
  )
    (var-set pending-fees (if is-add (+ current amount) (- current amount)))
    (print { action: "update-pending-fees", data: { old: current, new: (get-pending-fees), is-add: is-add } })
    (ok true)
  )
)

(define-private (update-pending-rf (amount uint) (is-add bool))
  (let (
    (current (get-pending-rf))
  )
    (var-set pending-rf (if is-add (+ current amount) (- current amount)))
    (print { action: "update-pending-rf", data: { old: current, new: (get-pending-rf), is-add: is-add } })
    (ok true)
  )
)

(define-private (update-last-log-ts)
  (begin
    (print { action: "update-last-log-ts", data: { old: (get-last-log-ts), new: (get-current-ts) } })
    (var-set last-log-ts (get-current-ts))
  )
)

;; Helper to execute a single update operation
(define-private (execute-update 
  (op { type: (string-ascii 14), amount: uint, is-add: bool })
  (prev (response bool uint)))
  (begin
    (try! prev)
    (if (is-eq (get type op) "total-assets")
      (update-total-assets (get amount op) (get is-add op))
      (if (is-eq (get type op) "pending-claims")
        (update-pending-claims (get amount op) (get is-add op))
        (if (is-eq (get type op) "pending-fees")
          (update-pending-fees (get amount op) (get is-add op))
          (if (is-eq (get type op) "pending-rf")
            (update-pending-rf (get amount op) (get is-add op))
            ERR_INVALID))))
  )
)

;; PUBLIC: Batch update with share price protection and optional commit-reward and shares update
(define-public (update-state 
  (operations (list 10 { type: (string-ascii 14), amount: uint, is-add: bool }))
  (reward (optional { reward: uint, is-add: bool }))
  (shares (optional { amount: uint, is-add: bool, user: principal })))
  (let (
    (init-share-price (get-share-price))
    (init-total-assets (get-total-assets))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol contract-caller))
    (asserts! (> (len operations) u0) ERR_NO_OPERATIONS)
    
    ;; Execute ALL operations before checking
    (try! (fold execute-update operations (ok true)))
    
    ;; Optionally handle shares update
    (match shares
      data (try! (update-shares (get amount data) (get is-add data) (get user data)))
      true)
    
    ;; Optionally handle commit-reward logic
    (match reward
      data (begin
        (try! (check-max-reward (get reward data)))
        (try! (check-update-window))
        (unwrap-panic (update-total-assets (get reward data) (get is-add data)))
        (update-last-log-ts)
        (print { action: "commit-reward", user: contract-caller, data: { 
          share-price: { old: init-share-price, new: (get-share-price) },
          total-assets: { old: init-total-assets, new: (get-total-assets) },
          return: (/ (* (get reward data) bps-base pct-base) init-total-assets),
          next-log-ts: (get-last-log-ts),
        } })
        true)
      true)
    
    ;; POST-CONDITION: Check share price deviation after all updates
    (try! (check-max-deviation init-share-price (get-share-price)))
    
    (print { action: "update-state", user: contract-caller,
             data: { operations: operations, shares: shares, share-price: { old: init-share-price, new: (get-share-price) } } })
    (ok true)
  )
)

(define-public (increment-claim-id)
  (let (
    (current-id (get-claim-id))
    (new-id (+ current-id u1))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol contract-caller))
    (var-set claim-id new-id)
    (print { action: "increment-claim-id", user: contract-caller, data: { old: current-id, new: new-id } })
    (ok new-id)
  )
)
;;-------------------------------------
;; Setters
;;-------------------------------------

(define-public (set-fee-address (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (try! (contract-call? .test-hq-vaults-v3 check-is-standard address))
    (print { action: "set-fee-address", user: contract-caller, data: { old: (get-fee-address), new: address } })
    (ok (var-set fee-address address))
  )
)

(define-public (set-fees (mgmt-fee uint) (perf-fee uint) (exit-fee uint) (express-fee uint))
  (let (
    (new-fees { mgmt-fee: mgmt-fee, perf-fee: perf-fee, exit-fee: exit-fee, express-fee: express-fee })
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= mgmt-fee (get mgmt-fee max)) ERR_ABOVE_MAX)
    (asserts! (<= perf-fee (get perf-fee max)) ERR_ABOVE_MAX)
    (asserts! (<= exit-fee (get exit-fee max)) ERR_ABOVE_MAX)
    (asserts! (<= express-fee (get express-fee max)) ERR_ABOVE_MAX)
    (print { action: "set-fees", user: contract-caller, data: { old: (get-fees), new: new-fees } })
    (ok (var-set fees new-fees))
  )
)

(define-public (set-custom-exit-fee (address principal) (exit-fee uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-fee-setter contract-caller))
    (asserts! (<= exit-fee (get exit-fee max) ) ERR_ABOVE_MAX)
    (print { action: "set-custom-exit-fee", user: contract-caller, data: { address: address, old: (get-custom-exit-fee address false), new: exit-fee } })
    (ok (map-set custom-exit-fee { address: address } { exit-fee: exit-fee }))
  )
)

(define-public (set-cooldown (new-cooldown uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= new-cooldown (get cooldown max) ) ERR_ABOVE_MAX)
    (print { action: "set-cooldown", user: contract-caller, data: { old: (get-cooldown), new: new-cooldown } })
    (ok (var-set cooldown new-cooldown))
  )
)

(define-public (set-express-cooldown (new-cooldown uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= new-cooldown (get cooldown max)) ERR_ABOVE_MAX)
    (print { action: "set-express-cooldown", user: contract-caller, data: { old: (get-express-cooldown), new: new-cooldown } })
    (ok (var-set express-cooldown new-cooldown))
  )
)

(define-public (set-custom-cooldown (address principal) (new-cooldown uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= new-cooldown (get cooldown max) ) ERR_ABOVE_MAX)
    (print { action: "set-custom-cooldown", user: contract-caller, data: { address: address, old: (get-custom-cooldown address false), new: new-cooldown } })
    (ok (map-set custom-cooldown {  address: address } { cooldown: new-cooldown }))
  )
)

(define-public (set-deposit-cap (new-deposit-cap uint))  
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-deposit-cap", user: contract-caller, data: { old: (get-deposit-cap), new: new-deposit-cap } })
    (ok (var-set deposit-cap new-deposit-cap))
  )
)

(define-public (set-min-amount (new-min-amount uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-min-amount", user: contract-caller, data: { old: (get-min-amount), new: new-min-amount } })
    (ok (var-set min-amount new-min-amount))
  )
)

(define-public (set-max-reward (new-max-reward uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (asserts! (<= new-max-reward (get reward max) ) ERR_ABOVE_MAX)
    (print { action: "set-max-reward", user: contract-caller, data: { old: (get-max-reward), new: new-max-reward } })
    (ok (var-set max-reward new-max-reward))
  )
)

(define-public (set-max-deviation (new-max-deviation uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (asserts! (<= new-max-deviation (get deviation max)) ERR_ABOVE_MAX)
    (print { action: "set-max-deviation", user: contract-caller, data: { old: (get-max-deviation), new: new-max-deviation } })
    (ok (var-set max-deviation new-max-deviation))
  )
)

(define-public (set-update-window (new-update-window uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (asserts! (>= new-update-window (get update-window min) ) ERR_BELOW_MIN)
    (print { action: "set-update-window", user: contract-caller, data: { old: (get-update-window), new: new-update-window } })
    (ok (var-set update-window new-update-window))
  )
)

(define-public (set-reserve-rate (new-reserve-rate uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= new-reserve-rate (get reserve-rate max)) ERR_ABOVE_MAX)
    (print { action: "set-reserve-rate", user: contract-caller, data: { old: (get-reserve-rate), new: new-reserve-rate } })
    (ok (var-set reserve-rate new-reserve-rate))
  )
)

(define-public (set-block-delay (new-block-delay uint))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (asserts! (<= new-block-delay (get block-delay max) ) ERR_ABOVE_MAX)
    (print { action: "set-block-delay", user: contract-caller, data: { old: (get-block-delay), new: new-block-delay } })
    (ok (var-set block-delay new-block-delay))
  )
)

(define-public (set-vault-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-vault-active", user: contract-caller, data: { old: (get-vault-active), new: active } })
    (ok (var-set vault-active active))
  )
)

(define-public (disable-vault)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-vault", user: contract-caller, data: { old: (get-vault-active), new: false } })
    (ok (var-set vault-active false))
  )
)

(define-public (set-transfer-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-transfer-active", user: contract-caller, data: { old: (get-transfer-active), new: active } })
    (ok (var-set transfer-active active))
  )
)

(define-public (disable-transfer)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-transfer", user: contract-caller, data: { old: (get-transfer-active), new: false } })
    (ok (var-set transfer-active false))
  )
)

(define-public (set-deposit-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-deposit-active", user: contract-caller, data: { old: (get-deposit-active), new: active } })
    (ok (var-set deposit-active active))
  )
)

(define-public (disable-deposits)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-deposits", user: contract-caller, data: { old: (get-deposit-active), new: false } })
    (ok (var-set deposit-active false))
  )
)

(define-public (set-withdraw-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-withdraw-active", user: contract-caller, data: { old: (get-withdraw-active), new: active } })
    (ok (var-set withdraw-active active))
  )
)

(define-public (disable-withdraw)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-withdraw", user: contract-caller, data: { old: (get-withdraw-active), new: false } })
    (ok (var-set withdraw-active false))

  )
)

(define-public (set-trading-active (active bool))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-admin contract-caller))
    (print { action: "set-trading-active", user: contract-caller, data: { old: (get-trading-active), new: active } })
    (ok (var-set trading-active active))
  )
)

(define-public (disable-trading)
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-guardian contract-caller))
    (print { action: "disable-trading", user: contract-caller, data: { old: (get-trading-active), new: false } })
    (ok (var-set trading-active false))
  )
)

(define-public (request-new-asset (token <ft>) (price-feed-id (buff 32)) (max-slippage uint) (is-stablecoin bool))
  (let (
    (token-address (contract-of token))
    (token-base (pow u10 (unwrap-panic (contract-call? token get-decimals))))
    (new-entry { active: false, ts: (some (get-current-ts)), price-feed-id: price-feed-id, token-base: token-base, max-slippage: max-slippage, is-stablecoin: is-stablecoin })
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (asserts! (<= max-slippage (get slippage max) ) ERR_ABOVE_MAX)
    (print { action: "request-new-asset", user: contract-caller, data: { token-address: token-address, old: (get-asset token-address), new: new-entry } })
    (ok (asserts! (map-insert assets { address: token-address } new-entry) ERR_DUPLICATE))
  )
)

(define-public (remove-asset (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "remove-asset", user: contract-caller, data: { address: address, old: (get-asset address) } })
    (ok (map-delete assets { address: address }))
  )
)

(define-public (activate-asset (address principal))
  (let (
    (entry (get-asset address))
    (ts (unwrap! (get ts entry) ERR_NO_ENTRY))
    (updated-entry (merge entry { active: true }))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (try! (contract-call? .test-hq-vaults-v3 check-activation-delay ts))
    (print { action: "activate-asset", user: contract-caller, data: { address: address, old: entry, new: updated-entry } })
    (ok (map-set assets { address: address } updated-entry))
  )
)

(define-public (set-max-slippage (address principal) (max-slippage uint))
  (let (
    (entry (get-asset address))
    (updated-entry (merge entry { max-slippage: max-slippage }))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (asserts! (<= max-slippage (get slippage max) ) ERR_ABOVE_MAX)
    (print { action: "set-max-slippage", user: contract-caller, data: { address: address, old: entry, new: updated-entry } })
    (ok (map-set assets { address: address } updated-entry))
  )
)

(define-public (request-new-contract (address principal))
  (let (
    (new-entry { active: false, ts: (some (get-current-ts)) })
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "request-new-contract", user: contract-caller, data: { address: address, old: (get-contract address), new: new-entry } })
    (ok (asserts! (map-insert contracts { address: address } new-entry) ERR_DUPLICATE))
  )
)

(define-public (remove-contract (address principal))
  (begin
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (print { action: "remove-contract", user: contract-caller, data: { address: address, old: (get-contract address) } })
    (ok (map-delete contracts { address: address }))
  )
)

(define-public (activate-contract (address principal))
  (let (
    (entry (get-contract address))
    (ts (unwrap! (get ts entry) ERR_NO_ENTRY))
    (updated-entry (merge entry { active: true }))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-owner contract-caller))
    (try! (contract-call? .test-hq-vaults-v3 check-activation-delay ts))
    (print { action: "activate-contract", user: contract-caller, data: { address: address, old: entry, new: updated-entry } })
    (ok (map-set contracts { address: address } updated-entry))
  )
)

;;-------------------------------------
;; Init
;;-------------------------------------
;; Remove for production

(define-constant init-ts (some (get-current-ts)))

;; Initialize trading assets
(map-set assets { address: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token } { active: true, ts: init-ts, price-feed-id: 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43, token-base: (pow u10 u8), max-slippage: u100, is-stablecoin: false })

;; TODO set correct contracts
(map-set contracts { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-v1-1 } { active: true, ts: init-ts })
(map-set contracts { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.staking-silo-v1-1 } { active: true, ts: init-ts })
(map-set contracts { address: 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-7 } { active: true, ts: init-ts })

;; -------------------------------------------------
;; Init for testing purposes
;; -------------------------------------------------

(map-set contracts { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.minting-auto-v1-2 } { active: true, ts: init-ts })
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 } { active: true, ts: init-ts })
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 } { active: true, ts: init-ts })
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3 } { active: true, ts: init-ts })
(map-set contracts { address: 'SP3BJR4P3W2Y9G22HA595Z59VHBC9EQYRFWSKG743.borrower-v1 } { active: true, ts: init-ts })
(map-set contracts { address: 'SP26NGV9AFZBX7XBDBS2C7EC7FCPSAV9PKREQNMVS.borrower-v1 } { active: true, ts: init-ts })

(map-set assets { address: 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 } { active: true, ts: init-ts, price-feed-id: 0x02, token-base: (pow u10 u8), max-slippage: u100, is-stablecoin: true })
(map-set assets { address: 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc } { active: true, ts: init-ts, price-feed-id: 0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: true })
(map-set assets { address: 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx } { active: true, ts: init-ts, price-feed-id: 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: false })
(map-set assets { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2 } { active: true, ts: init-ts, price-feed-id: 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17, token-base: (pow u10 u6), max-slippage: u1000, is-stablecoin: false })
(map-set assets { address: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token } { active: true, ts: init-ts, price-feed-id: 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43, token-base: (pow u10 u8), max-slippage: u1000, is-stablecoin: false })

;; Initialize Bitflow pool contracts used in tests
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-aeusdc-usdh-v-1-2 } { active: true, ts: init-ts })
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-2 } { active: true, ts: init-ts })
(map-set contracts { address: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 } { active: true, ts: init-ts })
