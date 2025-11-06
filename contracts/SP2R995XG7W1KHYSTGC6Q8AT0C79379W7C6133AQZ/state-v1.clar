;; TRAITS
(impl-trait .trait-sip-010.sip-010-trait)
(use-trait token-trait .trait-sip-010.sip-010-trait)

;; TOKENS
(define-fungible-token lp-token)

;; DATA VARS

;; core
(define-data-var total-assets uint u0)
(define-data-var total-debt-shares uint u0)
(define-map collaterals principal {
  max-ltv: uint,
  liquidation-ltv: uint,
  liquidation-premium: uint,
  decimals: uint
})
(define-map user-collaterals {user: principal, collateral: principal} {amount: uint})
(define-map positions principal {debt-shares: uint, collaterals: (list 10 principal), borrowed-amount: uint, borrowed-block: uint})
(define-data-var open-interest {
  lp-open-interest: uint,
  staked-open-interest: uint,
  protocol-open-interest: uint
} {
  lp-open-interest: u0,
  staked-open-interest: u0,
  protocol-open-interest: u0
})
(define-data-var protocol-reserve-percentage uint u0)
(define-data-var reserve-balance uint u0)
(define-data-var last-accrued-block-time uint (+ (default-to u0 (get-stacks-block-info? time (- stacks-block-height u1))) STACKS_BLOCK_TIME))
(define-data-var asset-cap uint u0)
(define-data-var borrowable-balance uint u0)
(define-data-var total-borrowed-amount uint u0)

;; permissioning
(define-data-var governance principal contract-caller)
(define-data-var deposit-asset-enabled bool true)
(define-data-var withdraw-asset-enabled bool true)
(define-data-var add-collateral-enabled bool true)
(define-data-var remove-collateral-enabled bool true)
(define-data-var borrow-enabled bool true)
(define-data-var repay-enabled bool true)
(define-data-var liquidation-enabled bool true)
(define-data-var interest-accrual-enabled bool true)
(define-data-var upgrades-enabled bool true)
(define-data-var staking-enabled bool true)
(define-map allowed-contracts principal bool)
(define-data-var liquidation-cooldown-block uint stacks-block-height)

;; lp-token
(define-constant lp-token-prefix "gusdc")

;; CONSTANTS 
(define-constant scaling-factor (contract-call? .constants-v1 get-scaling-factor))
(define-constant SUCCESS (ok true))
(define-constant STACKS_BLOCK_TIME (contract-call? .constants-v1 get-stacks-block-time ))

;; ERRORS
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-TRANSFER-NULL (err u101))
(define-constant ERR-PAUSED (err u102))
(define-constant ERR-INSUFFICIENT-FREE-LIQUIDITY (err u103))
(define-constant ERR-INVALID-PARAMS (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-SENDER-MISMATCH (err u106))
(define-constant ERR-CONTRACT-NOT-ALLOWED (err u107))
(define-constant ERR-COLLATERAL-NOT-SUPPORTED (err u108))
(define-constant ERR-NO-POSITION (err u109))
(define-constant ERR-UPGRADES-NOT-ENABLED (err u110))
(define-constant ERR-INVALID-PROTOCOL-RESERVE-PERCENTAGE (err u111))
(define-constant ERR-LIQUIDATION-UNPAUSE (err u112))
(define-constant ERR-LIQUIDATION-NOT-ALLOWED (err u113))
(define-constant ERR-LIQUIDATION-PAUSE (err u114))
(define-constant ERR-ONLY-TESTNET (err u115))
(define-constant ERR-ASSET-CAP (err u116))

;; GOVERNANCE FUNCTIONS 
(define-read-only (is-governance)
  (is-eq (var-get governance) contract-caller)
)

(define-public (update-governance (new-governance principal))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (are-upgrades-enabled) ERR-UPGRADES-NOT-ENABLED)
    (var-set governance new-governance)
    (print {
      previous-governance: contract-caller,
      new-governance: new-governance,
      action: "update-governance"
    })
    SUCCESS
))

;; TOKEN TRANSFER FUNCTIONS 
(define-public (transfer-from (token <token-trait>) (user principal) (amount uint))
  (begin
    (try! (is-allowed-contract contract-caller))
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (try! (contract-call? token transfer amount user (as-contract contract-caller) none))
    SUCCESS
))

(define-public (transfer-to (token <token-trait>) (user principal) (amount uint))
  (begin
    (try! (is-allowed-contract contract-caller))
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? token transfer amount (as-contract contract-caller) user none)))
    SUCCESS
))

;; TOKEN FUNCTIONS 
(define-public (add-assets (user principal) (recipient principal) (assets uint) (shares uint))
  (begin
    (asserts! (var-get deposit-asset-enabled) ERR-PAUSED)
    (asserts! (not (asset-deposit-exceeds-cap assets)) ERR-ASSET-CAP)
    (try! (is-allowed-contract contract-caller))
    (try! (transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc user assets))
    ;; If transfer is successful, proceed to mint share tokens to the user
    (try! (ft-mint? lp-token shares recipient))
    (var-set total-assets (+ (var-get total-assets) assets))
    (var-set borrowable-balance (+ (var-get borrowable-balance) assets))
    (print { 
      recipient: recipient,
      assets: assets,
      shares: shares,
      user: user,
      action: "deposit",
    })
    SUCCESS
))

(define-public (remove-assets (user principal) (recipient principal) (assets uint) (shares uint))
  (begin
    (asserts! (var-get withdraw-asset-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (try! (ft-burn? lp-token shares user))
    (var-set total-assets (- (var-get total-assets) assets))
    (asserts! (>= (free-liquidity) assets) ERR-INSUFFICIENT-FREE-LIQUIDITY)
    (if (> (var-get borrowable-balance) assets) 
      (var-set borrowable-balance (- (var-get borrowable-balance) assets))
      (var-set borrowable-balance u0))
    (try! (transfer-to 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc recipient assets))
    (print {
      recipient: recipient,
      assets: assets,
      shares: shares,
      user: user,
      action: "withdraw"
    })
    SUCCESS
))

;; SETTINGS
(define-public (freeze-upgrades)
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (print {
      user: contract-caller,
      action: "freeze-upgrades",
    })
    (var-set upgrades-enabled false)
    SUCCESS
))

(define-public (set-interest-accrual-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (if (not (is-eq status (var-get interest-accrual-enabled)))
      (var-set last-accrued-block-time (+ (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1))) STACKS_BLOCK_TIME))
      true
    )
    (var-set interest-accrual-enabled status)
    (print {
        value: status,
        user: contract-caller,
        action: "set-interest-accrual-flag"
      }
    )
    SUCCESS
  )
)

(define-public (set-deposit-asset-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set deposit-asset-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-deposit-asset-flag"
    })
    SUCCESS
))

(define-public (set-withdraw-asset-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set withdraw-asset-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-withdraw-asset-flag"
    })
    SUCCESS
))

(define-public (set-add-collateral-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    ;; disabling add-collateral must have liquidation already disabled
    (asserts! (or status (not (var-get liquidation-enabled))) ERR-LIQUIDATION-PAUSE)
    (var-set add-collateral-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-add-collateral-flag"
    })
    SUCCESS
))

(define-public (set-remove-collateral-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set remove-collateral-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-remove-collateral-flag"
    })
    SUCCESS
))

(define-public (set-borrow-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set borrow-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-borrow-flag"
    })
    SUCCESS
))

(define-public (set-repay-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    ;; disabling repay requires liquidation to be already disabled
    (asserts! (or status (not (var-get liquidation-enabled))) ERR-LIQUIDATION-PAUSE)
    (var-set repay-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-repay-flag"
    })
    SUCCESS
))

(define-public (set-staking-flag (status bool))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set staking-enabled status)
    (print {
      value: status,
      user: contract-caller,
      action: "set-staking-flag"
    })
    SUCCESS
))

(define-public (set-liquidation-flag (status bool) (cooldown uint))
  (let ((cooldown-block (+ stacks-block-height cooldown)))
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    ;; liquidation unpausing needs to unpause repay and add collateral first
    (asserts! (or (not status) (and (var-get repay-enabled) (var-get add-collateral-enabled))) ERR-LIQUIDATION-UNPAUSE)
    (var-set liquidation-enabled status)
    (var-set liquidation-cooldown-block cooldown-block)
    (print {
      value: status,
      liquidation-cooldown-block: cooldown-block,
      user: contract-caller,
      action: "set-liquidation-flag"
    })
    SUCCESS  
))

;; stops deposits, withdrawals, add/rm collateral, borrow, repay and liquidations
;; can be triggered by the guardian
(define-public (pause-market)
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (try! (set-deposit-asset-flag false))
    (try! (set-withdraw-asset-flag false))
    (try! (set-liquidation-flag false u0))
    (try! (set-add-collateral-flag false))
    (try! (set-remove-collateral-flag false))
    (try! (set-borrow-flag false))
    (try! (set-repay-flag false))
    (try! (set-interest-accrual-flag false))
    (print {
      user: contract-caller,
      action: "pause-market"
    })
    SUCCESS
))

(define-public (unpause-market (cooldown uint))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (try! (set-deposit-asset-flag true))
    (try! (set-withdraw-asset-flag true))
    (try! (set-add-collateral-flag true))
    (try! (set-remove-collateral-flag true))
    (try! (set-borrow-flag true))
    (try! (set-repay-flag true))
    (try! (set-liquidation-flag true cooldown))
    (try! (set-interest-accrual-flag true))
    (print {
      user: contract-caller,
      action: "unpause-market"
    })
    SUCCESS
))

(define-public (update-collateral-settings (collateral principal) (max-ltv uint) (liquidation-ltv uint) (liquidation-premium uint) (decimals uint))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (< max-ltv liquidation-ltv) ERR-INVALID-PARAMS)
    (asserts! (< liquidation-premium scaling-factor) ERR-INVALID-PARAMS)
    (try! (is-valid-liqLTV-and-liqPremium liquidation-ltv liquidation-premium))
    (map-set collaterals collateral {
      max-ltv: max-ltv,
      liquidation-ltv: liquidation-ltv,
      liquidation-premium: liquidation-premium,
      decimals: decimals
    })
    (print {
      collateral: collateral,
      max-ltv: max-ltv,
      liquidation-ltv: liquidation-ltv,
      liquidation-premium: liquidation-premium,
      decimals: decimals,
      user: contract-caller,
      action: "update-collateral-settings"
    })
    SUCCESS
))

(define-public (remove-collateral (collateral principal))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (map-delete collaterals collateral)
    (print {
      collateral: collateral,
      user: contract-caller,
      action: "remove-collateral"
    })
    SUCCESS
))

(define-public (update-asset-cap (new-cap uint))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (print {
      old-asset-cap: (var-get asset-cap),
      new-asset-cap: new-cap,
      action: "update-asset-cap"
    })
    (var-set asset-cap new-cap)
    SUCCESS
))

;; RESERVE BALANCE OPERATIONS
(define-public (deposit-to-reserve (amount uint))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (var-set reserve-balance (+ amount (var-get reserve-balance)))
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer amount contract-caller (as-contract contract-caller) none))
    (print {
      amount: amount,
      user: contract-caller,
      action: "deposit-to-reserve"
    })
    SUCCESS
))

(define-public (withdraw-from-reserve (amount uint))
  (let (
      (current-reserve-balance (var-get reserve-balance))
      (recipient contract-caller)
    )
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (>= current-reserve-balance amount) ERR-INSUFFICIENT-BALANCE)
    (asserts! (>= (free-liquidity) amount) ERR-INSUFFICIENT-FREE-LIQUIDITY)
    (var-set reserve-balance (- current-reserve-balance amount))
    (asserts! (> amount u0) ERR-TRANSFER-NULL)
    (as-contract (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer amount (as-contract contract-caller) recipient none)))
    (print {
      amount: amount,
      user: contract-caller,
      action: "withdraw-from-reserve"
    })
    SUCCESS
))

(define-private (can-borrow-without-reserve (withdraw-amount uint))
  (let (
      (remaining-balance-post-withdraw (- (free-liquidity) withdraw-amount))
      (reserve-balance-amount (var-get reserve-balance))
    )
    ;; draw down from reserve balance
    (if (< remaining-balance-post-withdraw reserve-balance-amount) 
      ERR-INSUFFICIENT-FREE-LIQUIDITY
      SUCCESS
    )
))

(define-private (is-valid-liqLTV-and-liqPremium (liquidation-ltv uint) ( liquidation-premium uint))
  (let ((inverted-discount (/ (* scaling-factor scaling-factor) (+ scaling-factor liquidation-premium))))
    (asserts! (< liquidation-ltv inverted-discount) ERR-INVALID-PARAMS)
    SUCCESS
  )
)

;; assets * total shares / total assets
(define-private (convert-to-lp-tokens (assets uint))
  (let ((asset-params (get-lp-params)))
    (contract-call? .math-v1 convert-to-shares asset-params assets true)
))

;; shares * total assets / total shares
(define-read-only (convert-to-assets (shares uint))
  (let ((asset-params (get-lp-params)))
    (contract-call? .math-v1 convert-to-assets asset-params shares true)
))

;; SIP-10 LP-TOKEN FUNCTIONS
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR-SENDER-MISMATCH)
    (match memo to-print (print to-print) 0x)
    (try! (ft-transfer? lp-token amount sender recipient))
    (print {
      sender: sender,
      recipient: recipient,
      amount: amount,
      memo: memo,
      action: "lp-token-transfer"
    })
    SUCCESS
))

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance lp-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply lp-token))
)

(define-read-only (get-name)
  (ok (concat lp-token-prefix " - Granite LP Token"))
)

(define-read-only (get-symbol)
  (ok (concat lp-token-prefix "-GLP"))
)

(define-read-only (get-decimals)
  (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-decimals)
)

(define-read-only (get-token-uri)
  (ok none)
)

;; PERMISSIONED FUNCTIONS
(define-read-only (is-allowed-contract (address principal))
  (begin
    (unwrap! (map-get? allowed-contracts address) ERR-CONTRACT-NOT-ALLOWED)
    SUCCESS
))

(define-private (is-allowed-contract-or-governance)
  (or (default-to false (map-get? allowed-contracts contract-caller)) (is-governance))
)

(define-public (set-allowed-contract (contract principal))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (are-upgrades-enabled) ERR-UPGRADES-NOT-ENABLED)
    (map-set allowed-contracts contract true)
    (print {
      allowed-contracts: contract,
      action: "set-allowed-contract"
    })
    SUCCESS
))

(define-public (remove-allowed-contract (contract principal))
  (begin
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (are-upgrades-enabled) ERR-UPGRADES-NOT-ENABLED)
    (map-delete allowed-contracts contract)
    (print {
      removed-contracts: contract,
      action: "remove-allowed-contract"
    })
    SUCCESS
))

(define-public (set-protocol-reserve-percentage (value uint)) 
  (begin 
    (asserts! (is-governance) ERR-UNAUTHORIZED)
    (asserts! (<= value scaling-factor) ERR-INVALID-PROTOCOL-RESERVE-PERCENTAGE)
    (print {
      old-protocol-reserve-percentage: (var-get protocol-reserve-percentage),
      updated-protocol-reserve-percentage: value,
      action: "set-protocol-reserve-percentage"})
    (var-set protocol-reserve-percentage value) 
    SUCCESS
))

;; STATE READS
(define-read-only (get-lp-params)
  {
    total-assets: (var-get total-assets),
    total-shares: (ft-get-supply lp-token),
  }
)

(define-read-only (get-debt-params)
  (let ((open-interest-data (var-get open-interest))) 
    {
      open-interest: (+ (get lp-open-interest open-interest-data) (get staked-open-interest open-interest-data) (get protocol-open-interest open-interest-data)),
      total-debt-shares: (var-get total-debt-shares),
    }
))

(define-read-only (get-protocol-reserve-percentage) (var-get protocol-reserve-percentage))

(define-read-only (get-asset-cap) (var-get asset-cap))

(define-read-only (get-reserve-balance) (var-get reserve-balance))

(define-read-only (free-liquidity)
  (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc get-balance (as-contract tx-sender)))
)

(define-read-only (available-liquidity)
  (let
    (
      (current-token-balance (free-liquidity))
      (current-reserve-balance (var-get reserve-balance))
    )
    (if (< current-token-balance current-reserve-balance)
      (ok u0)
      (ok (- current-token-balance current-reserve-balance))
    )
))

(define-read-only (get-accrue-interest-params)
  (let ((open-interest-data (var-get open-interest)))
    (ok {
      last-accrued-block-time: (var-get last-accrued-block-time),
      lp-interest: (get lp-open-interest open-interest-data),
      staked-interest: (get staked-open-interest open-interest-data),
      protocol-interest: (get protocol-open-interest open-interest-data),
      protocol-reserve-percentage: (var-get protocol-reserve-percentage),
      total-assets: (var-get total-assets),
    })
))

(define-read-only (get-governance) 
  (var-get governance)
)

(define-read-only (is-borrow-enabled)
  (var-get borrow-enabled)
)

(define-read-only (is-repay-enabled)
  (var-get repay-enabled)
)

(define-read-only (is-add-collateral-enabled)
  (var-get add-collateral-enabled)
)

(define-read-only (is-remove-collateral-enabled)
  (var-get remove-collateral-enabled)
)

(define-read-only (is-liquidation-enabled)
  (and (var-get liquidation-enabled) (>= stacks-block-height (var-get liquidation-cooldown-block)))
)

(define-read-only (is-interest-accrual-enabled)
  (var-get interest-accrual-enabled)
)

(define-read-only (are-upgrades-enabled) 
  (var-get upgrades-enabled)
)

(define-read-only (is-deposit-asset-enabled)
  (var-get deposit-asset-enabled)
)

(define-read-only (is-withdraw-asset-enabled)
  (var-get withdraw-asset-enabled)
)

(define-read-only (is-staking-enabled)
  (var-get staking-enabled)
)

(define-read-only (get-user-position (user principal))
  (map-get? positions user)
)

(define-read-only (get-collateral (collateral principal))
  (map-get? collaterals collateral)
)

(define-read-only (get-user-collateral (user principal) (collateral principal))
  (map-get? user-collaterals {user: user, collateral: collateral})
)

(define-read-only (get-open-interest)
  (var-get open-interest)
)

(define-read-only (get-borrow-repay-params (user principal))
  {
    user-position: (map-get? positions user),
    total-borrowed-amount: (var-get total-borrowed-amount)
  }
)

(define-read-only (get-collateral-params (collateral-token principal) (user principal))
  (ok {
    collateral-info: (unwrap! (map-get? collaterals collateral-token) ERR-COLLATERAL-NOT-SUPPORTED),
    user-balance: (map-get? user-collaterals {user: user, collateral: collateral-token}),
    user-position: (default-to {debt-shares: u0, collaterals: (list), borrowed-amount: u0, borrowed-block: u0} (map-get? positions user)),
  })
)

(define-read-only (get-borrowable-balance) (var-get borrowable-balance))

(define-read-only (asset-deposit-exceeds-cap (deposit uint))
  (> (+ (var-get total-assets) deposit) (var-get asset-cap))
)

(define-private (fold-remove (item principal) (data {item-to-remove: principal, new-list:(list 10 principal)}))
	(if (is-eq item (get item-to-remove data))
    data
    {
      item-to-remove: (get item-to-remove data),
      new-list: (unwrap-panic (as-max-len? (append (get new-list data) item) u10)),
    }
))

(define-read-only (remove-item (collaterals-list (list 10 principal)) (collateral principal))
  (fold fold-remove collaterals-list {item-to-remove: collateral, new-list: (list)})
)

;; STATE WRITES
(define-public (increase-total-assets (assets uint))
  (begin
    (asserts! (not is-in-mainnet) ERR-ONLY-TESTNET)
    (try! (is-allowed-contract contract-caller))
    (var-set total-assets (+ (var-get total-assets) assets))
    (var-set borrowable-balance (+ (var-get borrowable-balance) assets))
    SUCCESS
))

(define-public (set-accrued-interest (accrued-interest {last-accrued-block-time: uint, lp-open-interest: uint, staked-open-interest: uint, protocol-open-interest: uint, total-assets: uint,}))
  (begin
    (asserts! (is-interest-accrual-enabled) SUCCESS)
    (asserts! (is-allowed-contract-or-governance) ERR-UNAUTHORIZED)
    (var-set last-accrued-block-time (get last-accrued-block-time accrued-interest))
    (var-set open-interest {
      lp-open-interest: (get lp-open-interest accrued-interest),
      staked-open-interest: (get staked-open-interest accrued-interest),
      protocol-open-interest: (get protocol-open-interest accrued-interest)
    })
    (var-set total-assets (get total-assets accrued-interest))
    SUCCESS
))

(define-public (update-borrow-state (borrow-state {user: principal, user-debt-shares: uint, user-collaterals: (list 10 principal), user-borrowed-amount: uint, shares: uint, amount: uint, total-borrowed-amount: uint}))
  (let (
      (amount (get amount borrow-state))
      (user (get user borrow-state))
      (open-interest-data (var-get open-interest))
    )
    (asserts! (is-borrow-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (map-set positions user {
      debt-shares: (get user-debt-shares borrow-state),
      collaterals: (get user-collaterals borrow-state),
      borrowed-amount: (get user-borrowed-amount borrow-state),
      borrowed-block: stacks-block-height,
    })
    (var-set open-interest {
      lp-open-interest: (+ (get lp-open-interest open-interest-data) amount),
      staked-open-interest: (get staked-open-interest open-interest-data),
      protocol-open-interest: (get protocol-open-interest open-interest-data)
    })
    (var-set total-debt-shares (+ (var-get total-debt-shares) (get shares borrow-state)))
    (var-set borrowable-balance (- (var-get borrowable-balance) amount))
    (try! (can-borrow-without-reserve amount))
    (try! (transfer-to 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc user amount))
    (var-set total-borrowed-amount (get total-borrowed-amount borrow-state))
    SUCCESS
))

(define-public (update-repay-state (repay-state {
  user: principal,
  user-debt-shares: uint,
  user-collaterals: (list 10 principal),
  shares: uint, amount: uint,
  lp-part: uint, protocol-part: uint, staked-part: uint, staked-lp-tokens: uint, 
  payor: principal, borrowed-amount: uint, total-borrowed-amount: uint, staking-contract: principal, borrowed-block: uint}))
  (let (
      (protocol-part (get protocol-part repay-state))
      (lp-part (get lp-part repay-state))
      (staked-part (get staked-part repay-state))
      (staked-lp-tokens (get staked-lp-tokens repay-state))
      (open-interest-data (var-get open-interest))
    )
    (asserts! (is-repay-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (map-set positions (get user repay-state) {
      debt-shares: (get user-debt-shares repay-state), 
      collaterals: (get user-collaterals repay-state),
      borrowed-amount: (get borrowed-amount repay-state),
      borrowed-block: (get borrowed-block repay-state)
    })
    (var-set total-debt-shares (- (var-get total-debt-shares) (get shares repay-state)))
    (var-set total-borrowed-amount (get total-borrowed-amount repay-state))
    (var-set open-interest {
      lp-open-interest: (- (get lp-open-interest open-interest-data) lp-part),
      staked-open-interest: (- (get staked-open-interest open-interest-data) staked-part),
      protocol-open-interest: (- (get protocol-open-interest open-interest-data) protocol-part)
    })
    (var-set reserve-balance (+ (var-get reserve-balance) protocol-part))
    (var-set borrowable-balance (+ (+ (var-get borrowable-balance) lp-part) staked-part))
    (try! (transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc (get payor repay-state) (get amount repay-state)))
    (if (> staked-lp-tokens u0)
      (ft-mint? lp-token staked-lp-tokens (get staking-contract repay-state))
      SUCCESS
    )
))

(define-public (update-add-collateral (token <token-trait>) (add-collateral-state {user: principal, amount: uint, total-collateral-amount: uint, user-position: {debt-shares: uint, collaterals: (list 10 principal), borrowed-amount: uint, borrowed-block: uint}}))
  (begin
    (asserts! (is-add-collateral-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (try! (transfer-from token (get user add-collateral-state) (get amount add-collateral-state)))
    (map-set user-collaterals {user: (get user add-collateral-state), collateral: (contract-of token)} {amount: (get total-collateral-amount add-collateral-state)})
    (map-set positions (get user add-collateral-state) (get user-position add-collateral-state))
    SUCCESS
))

(define-public (update-user-collateral (user principal) (collateral principal) (amount uint))
  (begin
    (asserts! (is-remove-collateral-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (map-set user-collaterals {user: user, collateral: collateral} {amount: amount})
    SUCCESS
))

(define-public (update-remove-collateral (user principal) (collateral principal) (debt-shares uint) (updated-collaterals (list 10 principal)) (borrowed-amount uint) (borrowed-block uint))
  (begin
    (asserts! (is-remove-collateral-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    (map-delete user-collaterals {user: user, collateral: collateral})
    (map-set positions user {debt-shares: debt-shares, collaterals: updated-collaterals, borrowed-amount: borrowed-amount, borrowed-block: borrowed-block})
    SUCCESS
))

(define-public (update-liquidate-collateral-state (collateral <token-trait>) (liquidate-collateral-state
  {
      liquidator: principal,
      user: principal,
      collateral-to-give: uint,
      repay-amount: uint,
      paid-shares: uint,
      lp-part: uint,
      protocol-part: uint,
      staked-part: uint,
      staked-lp-tokens: uint,
      borrowed-amount: uint,
      total-borrowed-amount: uint,
      staking-contract: principal,
      remaining-balance: uint,
      updated-collaterals: (list 10 principal)
  }))
  (let (
      (user (get user liquidate-collateral-state))
      (position (unwrap! (map-get? positions user) ERR-NO-POSITION))
      (collateral-token (contract-of collateral))
      (user-balance (unwrap! (get amount (map-get? user-collaterals {user: user, collateral: collateral-token})) ERR-INSUFFICIENT-BALANCE))
      (liquidator (get liquidator liquidate-collateral-state))
      (collateral-to-give (get collateral-to-give liquidate-collateral-state))
      (paid-shares (get paid-shares liquidate-collateral-state))
      (lp-part (get lp-part liquidate-collateral-state))
      (protocol-part (get protocol-part liquidate-collateral-state))
      (staked-part (get staked-part liquidate-collateral-state))
      (staked-lp-tokens (get staked-lp-tokens liquidate-collateral-state))
      (repay-amount (get repay-amount liquidate-collateral-state))
      (open-interest-data (var-get open-interest))
    )
    (asserts! (is-liquidation-enabled) ERR-PAUSED)
    (try! (is-allowed-contract contract-caller))
    ;; user liquidation should not happen in the same block
    ;; user should always have borrowed before liquidating
    (asserts! (> stacks-block-height (get borrowed-block position)) ERR-LIQUIDATION-NOT-ALLOWED)
    ;; reduce position collateral amount
    (map-set user-collaterals {user: user, collateral: collateral-token} {amount: (- user-balance collateral-to-give)})
    ;; reduce position debt shares and total debt shares
    (map-set positions user {
      debt-shares: (- (get debt-shares position) paid-shares), 
      collaterals: (get collaterals position),
      borrowed-amount: (get borrowed-amount liquidate-collateral-state),
      borrowed-block: (get borrowed-block position)
    })
    (var-set total-borrowed-amount (get total-borrowed-amount liquidate-collateral-state))
    (var-set total-debt-shares (- (var-get total-debt-shares) paid-shares))
    ;; reduce total debt
    (var-set open-interest {
      lp-open-interest: (- (get lp-open-interest open-interest-data) lp-part),
      staked-open-interest: (- (get staked-open-interest open-interest-data) staked-part),
      protocol-open-interest: (- (get protocol-open-interest open-interest-data) protocol-part)
    })
    (var-set reserve-balance (+ (var-get reserve-balance) protocol-part))
    ;; increase borrowable balance
    (var-set borrowable-balance (+ (+ (var-get borrowable-balance) lp-part) staked-part))

    ;; transfer collateral to liquidator
    (try! (transfer-to collateral liquidator collateral-to-give))
    ;; transfer repay amount from liquidator
    (try! (if (> repay-amount u0) (transfer-from 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc liquidator repay-amount) SUCCESS))
    (if (> staked-lp-tokens u0)
      (ft-mint? lp-token staked-lp-tokens (get staking-contract liquidate-collateral-state))
      SUCCESS
    )
))

(define-private (reduce-total-assets-and-borrowable-balance (amount uint))
  (let ((current-total-assets (var-get total-assets)))
    (if (> (var-get borrowable-balance) amount) 
      (var-set borrowable-balance (- (var-get borrowable-balance) amount))
      (var-set borrowable-balance u0)
    )

    (if (>= current-total-assets amount) 
      (begin (var-set total-assets (- current-total-assets amount))  {remaining-debt: u0})
      (begin (var-set total-assets u0)  {remaining-debt: (- amount current-total-assets)})
    )
  )
)

(define-private (slash-staked-lp-tokens (tokens-to-slash uint) (staked-lp-tokens uint) (staking-contract principal))
  (if (or (is-eq tokens-to-slash u0) (is-eq staked-lp-tokens u0)) 
    (ok {tokens-slashed: u0, remaining: tokens-to-slash})
    (if (>= staked-lp-tokens tokens-to-slash)
      (let ((assets-slashed (convert-to-assets tokens-to-slash)))
        (try! (ft-burn? lp-token tokens-to-slash staking-contract))
        (reduce-total-assets-and-borrowable-balance assets-slashed)
        (ok {tokens-slashed: tokens-to-slash, remaining: u0})
      )
      (let ((assets-slashed (convert-to-assets staked-lp-tokens)))
        (try! (ft-burn? lp-token staked-lp-tokens staking-contract))
        (reduce-total-assets-and-borrowable-balance assets-slashed)
        (var-set staking-enabled false)
        (print {
          action: "staking-wipeout",
          slashed-staked-lp-tokens: staked-lp-tokens
        })
        (ok {tokens-slashed: staked-lp-tokens, remaining: (- tokens-to-slash staked-lp-tokens)})
      )
    )
  )
)

(define-private (socialize-debt-from-reserve (lp-tokens-to-socialize uint))
  (let (
      (current-reserve-balance (var-get reserve-balance))
      (amount (convert-to-assets lp-tokens-to-socialize))
    )
    (if (>= current-reserve-balance amount)
      (begin (var-set reserve-balance (- current-reserve-balance amount)) {remaining-debt: u0})
      (begin (var-set reserve-balance u0) {remaining-debt: (- amount current-reserve-balance)})
    )
  )
)

(define-public (socialize-user-bad-debt (user principal) (socialized-debt-amount uint) (lp-part uint) (staked-part uint) (protocol-part uint) (updated-total-borrowed-amount uint) (staking-contract principal) (staked-lp-tokens uint))
  (let (
      (position (unwrap! (map-get? positions user) ERR-NO-POSITION))
      (current-reserve-balance (var-get reserve-balance))
      (open-interest-data (var-get open-interest))
      (current-total-assets (var-get total-assets))
    )
    (try! (is-allowed-contract contract-caller))
    ;; set user debt shares to 0 and reduce total debt shares
    (var-set total-debt-shares (- (var-get total-debt-shares) (get debt-shares position)))
    (map-set positions user {debt-shares: u0, collaterals: (get collaterals position), borrowed-amount: u0, borrowed-block: (get borrowed-block position)})
    ;; reduce total debt
    (var-set open-interest {
      lp-open-interest: (- (get lp-open-interest open-interest-data) lp-part),
      staked-open-interest: (- (get staked-open-interest open-interest-data) staked-part),
      protocol-open-interest: (- (get protocol-open-interest open-interest-data) protocol-part)
    })
    (var-set total-borrowed-amount updated-total-borrowed-amount)
    ;; slash staked lp tokens to cover the debt
    ;; then use reserve to cover the remaining debt
    ;; then use unstaked lp-tokens
    (let (
        (debt-to-lp-tokens (convert-to-lp-tokens socialized-debt-amount))
        (slashed-info (try! (slash-staked-lp-tokens debt-to-lp-tokens staked-lp-tokens staking-contract)))
        (reserved-socilaized-info (socialize-debt-from-reserve (get remaining slashed-info)))
        (remaining-debt (get remaining-debt reserved-socilaized-info))
      )
      (reduce-total-assets-and-borrowable-balance remaining-debt)
      (ok (get tokens-slashed slashed-info))
    )
  )
)