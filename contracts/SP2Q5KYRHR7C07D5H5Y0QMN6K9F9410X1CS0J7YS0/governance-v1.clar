;; SPDX-License-Identifier: BUSL-1.1

;; TRAITS
(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; CONSTANTS

;; Action to update governance in State Contract
(define-constant ACTION_UPDATE_GOVERNANCE u0)

;; Action to freeze upgrades on State contract
(define-constant ACTION_FREEZE_UPGRADES u1)

;; Action to set depositing assets
(define-constant ACTION_SET_DEPOSIT_ASSET_FLAG u2)

;; Action to set withdrawing assets
(define-constant ACTION_SET_WITHDRAW_ASSET_FLAG u3)

;; Action to set adding collateral to market
(define-constant ACTION_SET_ADD_COLLATERAL_FLAG u4)

;; Action to set removing collateral from market
(define-constant ACTION_SET_REMOVE_COLLATERAL_FLAG u5)

;; Action to set Borrow
(define-constant ACTION_SET_BORROW_FLAG u6)

;; Action to set Repay
(define-constant ACTION_SET_REPAY_FLAG u7)

;; Action to set Liquidation
(define-constant ACTION_SET_LIQUIDATION_FLAG u8)

;; Action to set market pause
(define-constant ACTION_SET_MARKET_PAUSE_FLAG u9)

;; Action to set market unpause
(define-constant ACTION_SET_MARKET_UNPAUSE_FLAG u10)

;; Action to update collateral settings
(define-constant ACTION_UPDATE_COLLATERAL_SETTINGS u11)

;; Action to deposit to Market reserve balance
(define-constant ACTION_DEPOSIT_TO_RESERVE u12)

;; Action to withdraw from Market reserve
(define-constant ACTION_WITHDRAW_FROM_RESERVE u13)

;; Action to update Allowed contract list
(define-constant ACTION_SET_ALLOWED_CONTRACT u14)

;; Action to remove allowed contract list
(define-constant ACTION_REMOVE_ALLOWED_CONTRACT u15)

;; Action to add new principal to guardians
(define-constant ACTION_ADD_GUARDIAN u16)

;; Action to remove principal from guardians
(define-constant ACTION_REMOVE_GUARDIAN u17)

;; Action to update interest rate parameters
(define-constant ACTION_UPDATE_INTEREST_RATE_PARAMS u18)

;; Action to update protocol reserve percentage
(define-constant ACTION_UPDATE_PROTOCOL_RESERVE_PERCENTAGE u19)

;; Action to update asset cap
(define-constant ACTION_UPDATE_ASSET_CAP u20)

;; Action to transfer out funds from governance contract
(define-constant ACTION_TRANSFER_FUNDS u21)

;; Action to remove collateral
(define-constant ACTION_REMOVE_COLLATERAL u22)

;; Action to pause interest accrual
(define-constant ACTION_SET_INTEREST_ACCRUAL_FLAG u23)

;; Action to update staking reward rate
(define-constant ACTION_UPDATE_REWARD_RATE_PARAMS u24)

;; Action to update the staking module withdrawal window
(define-constant ACTION_UPDATE_WITHDRAWAL_FINALIZATION_PERIOD u25)

;; Action to update a token feed to the Pyth oracle contract
(define-constant ACTION_UPDATE_PYTH_TOKEN_FEED u26)

;; Action to reconcile staking balance
(define-constant ACTION_RECONCILE_STAKING_LP_BALANCE u27)

;; Action to set staking flag
(define-constant ACTION_SET_STAKING_FLAG u28)

;; Action to update pyth time delta
(define-constant ACTION_UPDATE_TIME_DELTA u29)

;; Action to set lp cap
(define-constant ACTION_SET_LP_CAP u30)

;; Action to set debt cap
(define-constant ACTION_SET_DEBT_CAP u31)

;; action to set collateral cap
(define-constant ACTION_SET_COLLATERAL_CAP u32)

;; action to set refill time window
(define-constant ACTION_SET_REFILL_TIME_WINDOW u33)

;; action to set decay time window
(define-constant ACTION_SET_DECAY_TIME_WINDOW u34)

;; action to update flash loan fee
(define-constant ACTION_UPDATE_FLASH_LOAN_FEE u35)

;; action to add contract to allow list in flash loan
(define-constant ACTION_ADD_CONTRACT_FLASH_LOAN u36)

;; action to remove contract from allow list in flash loan
(define-constant ACTION_REMOVE_CONTRACT_FLASH_LOAN u37)

;; action to allow or disable any contract
(define-constant ACTION_ALLOW_ANY_CONTRACT_FLASH_LOAN u38)

;; Threshold to either execute or remove proposal
;; 10% and above
;; 1 & 2 Account Multisig will require all of them to execute or deny proposal
(define-constant THRESHOLD u10)

;; Time lock period before executing approved proposal
;; approximately 60 seconds assuming 4 second block time
(define-constant TIME_LOCKED_PERIOD u15)

;; Time lock expiration period
;; approved time lock proposal expires after expiration block
;; approximately 1 week assuming 4 second block time
(define-constant TIME_LOCK_EXECUTE_EXPIRATION_PERIOD u151200)

;; Success response
(define-constant SUCCESS (ok true))

;; ERRORS
(define-constant ERR-INVALID-ACTION (err u40000))
(define-constant ERR-NOT-GUARDIAN (err u40001))
(define-constant ERR-UNKNOWN-PROPOSAL (err u40002))
(define-constant ERR-SUBMITTED-VOTE (err u40003))
(define-constant ERR-PROPOSAL-CLOSED (err u40004))
(define-constant ERR-CONTRACT-ALREADY-INITIALIZED (err u40005))
(define-constant ERR-CONTRACT-NOT-INITIALIZED (err u40006))
(define-constant ERR-NOT-CONTRACT-DEPLOYER (err u40007))
(define-constant ERR-INTEREST-RATE-PARAMS (err u40008))
(define-constant ERR-PROPOSAL-ALREADY-EXISTS (err u40009))
(define-constant ERR-FAILED-TO-GENERATE-PROPOSAL-ID (err u40010))
(define-constant ERR-PROPOSAL-VOTING-INCOMPLETE (err u40011))
(define-constant ERR-PROPOSAL-CANNOT-CLOSE (err u40012))
(define-constant ERR-PROPOSAL-EXPIRED (err u40013))
(define-constant ERR-MINIMUM-PYTH-PRICE-DELTA (err u40014))
(define-constant ERR-PROPOSAL-NOT-CLOSED (err u40015))
(define-constant ERR-PROPOSAL-ALREADY-EXECUTED (err u40016))
(define-constant ERR-PROPOSAL-TIME-LOCKED (err u40017))
(define-constant ERR-PROPOSAL-NOT-TIME-LOCKED (err u40018))
(define-constant ERR-CANNOT-VOTE (err u40019))

;; DATA VARS

;; Next proposal nonce
(define-data-var next-proposal-nonce uint u0)

;; Guardians with specific permissions
(define-map guardians principal bool)

;; Governance proposal
(define-map governance-proposal (buff 32) {
  action: uint,
  approve-count: uint,
  deny-count: uint,
  closed: bool,
  expires-at: uint,
  executed: bool,
  execute-at: (optional uint)
})

;; approved multisigs for given proposal
(define-map proposal-approved-members { proposal-id: (buff 32), member: principal} bool)

;; denied multisigs for given proposal
(define-map proposal-denied-members { proposal-id: (buff 32), member: principal} bool)

;; Update governance proposal data
(define-map update-governance-proposal-data (buff 32) principal)

;; Set market feature proposal data
(define-map set-market-feature-proposal-data (buff 32) {
  flag: bool,
  cooldown: uint
})

;; Collateral settings proposal data
(define-map collateral-settings-proposal-data (buff 32) {
    collateral: principal,
    max-ltv: uint, 
    liquidation-ltv: uint, 
    liquidation-premium: uint,
    decimals: uint
  }
)

;; Reserve proposal data
(define-map reserve-proposal-data (buff 32) uint)

;; Market unpausing data
(define-map unpause-market-data (buff 32) uint)

;; Allowed contracts data
(define-map allowed-contract-data (buff 32) principal)

;; Update guardians proposal data
(define-map update-guardians-proposal-data (buff 32) principal)

;; Proposal's state contract address
(define-map state-contract-address (buff 32) principal)

;; Proposal's interest rate contract address
(define-map update-interest-rate-params (buff 32) {
  ir-slope-1-val: uint,
  ir-slope-2-val: uint,
  utilization-kink-val: uint,
  base-ir-val: uint,
})

;; Reserve token feed data
(define-map update-pyth-feed (buff 32) {
  token: principal,
  feed: (buff 32),
  max-confidence-ratio: uint,
})

;; Staking status flag
(define-map staking-flag (buff 32) bool)

;; contract deployer. No permissions except to initialize the contract
(define-constant contract-deployer contract-caller)

;; flag to check if the contract is initialized
(define-data-var governance-initialized bool false)

;; storage value for protocol reserve percentage.
(define-map protocol-reserve-percentage (buff 32) uint)

;; storage value for asset cap update
(define-map asset-cap-update (buff 32) uint)

;; storage value for funds transfer
(define-map transfer-funds (buff 32) {
  account: principal,
  amount: uint
})

;; storage value for remove collateral
(define-map remove-collateral (buff 32) principal)

;; storage value for reward rate
(define-map update-reward-rate-params (buff 32) {
  slope-1-val: int,
  slope-2-val: int,
  staked-kink-val: uint,
  base-reward-val: uint,
})

;; staking module withdrawal window data storage
(define-map withdrawal-finalization-period (buff 32) uint)

;; pyth time delta update value storage
(define-map update-time-delta-params (buff 32) uint)

;; time-locked actions
(define-map time-locked uint bool)

;; cap update data
(define-map cap-data (buff 32) {
    collateral: (optional principal),
    factor: uint
  }
)

;; flash loan fee update
(define-map flash-loan-fee-update (buff 32) uint)

;; flash loan add or remove contract
(define-map flash-loan-contract-update (buff 32) principal)

;; flash loan allow or disable any contract
(define-map flash-allow-disable-contract-update (buff 32) bool)

;; PRIVATE FUNCTIONS
(define-private (create-proposal (proposal-id (buff 32)) (action uint) (expires-in uint))
  (begin
    (try! (is-governance-member contract-caller))
    (asserts! (not (is-some (map-get? governance-proposal proposal-id))) ERR-PROPOSAL-ALREADY-EXISTS)
    (asserts! (var-get governance-initialized) ERR-CONTRACT-NOT-INITIALIZED)
    (var-set next-proposal-nonce (+ (var-get next-proposal-nonce) u1))
    (map-set governance-proposal proposal-id {
      action: action,
      approve-count: u1,
      deny-count: u0,
      expires-at: (+ stacks-block-height expires-in),
      closed: false,
      executed: false,
      execute-at: none,
    })
    (map-set proposal-approved-members {proposal-id: proposal-id, member: contract-caller} true)
    (print {
      action: "proposal-initiated",
      proposal-id: proposal-id
    })
    (print {
      action: "proposal-voted-approved",
      voter: contract-caller,
      proposal-id: proposal-id
    })
    (ok proposal-id)
))

(define-private (has-submitted-vote (proposal-id (buff 32)))
  (or 
    (default-to false (map-get? proposal-approved-members {proposal-id: proposal-id, member: contract-caller}))
    (default-to false (map-get? proposal-denied-members {proposal-id: proposal-id, member: contract-caller}))
))

(define-private (execute-update-pyth-token-price-feed (proposal-id (buff 32)))
  (let ((pyth-data (unwrap-panic (map-get? update-pyth-feed proposal-id))))
    (contract-call? .pyth-adapter-v1 update-price-feed-id (get token pyth-data) (get feed pyth-data) (get max-confidence-ratio pyth-data))
))

(define-private (execute-state-governance-update (proposal-id (buff 32)))
  (contract-call? .state-v1 update-governance (unwrap-panic (map-get? update-governance-proposal-data proposal-id)))
)

(define-private (execute-state-set-feature-flag (proposal-id (buff 32)) (action uint))
  (let (
      (data (unwrap-panic (map-get? set-market-feature-proposal-data proposal-id)))
      (flag (get flag data))
      (cooldown (get cooldown data))
    )
    (asserts! (not (is-eq action ACTION_SET_DEPOSIT_ASSET_FLAG)) (contract-call? .state-v1 set-deposit-asset-flag flag))
    (asserts! (not (is-eq action ACTION_SET_WITHDRAW_ASSET_FLAG)) (contract-call? .state-v1 set-withdraw-asset-flag flag))
    (asserts! (not (is-eq action ACTION_SET_ADD_COLLATERAL_FLAG)) (contract-call? .state-v1 set-add-collateral-flag flag))
    (asserts! (not (is-eq action ACTION_SET_REMOVE_COLLATERAL_FLAG)) (contract-call? .state-v1 set-remove-collateral-flag flag))
    (asserts! (not (is-eq action ACTION_SET_BORROW_FLAG)) (contract-call? .state-v1 set-borrow-flag flag))
    (asserts! (not (is-eq action ACTION_SET_REPAY_FLAG)) (contract-call? .state-v1 set-repay-flag flag))
    (asserts! (not (is-eq action ACTION_SET_LIQUIDATION_FLAG)) (contract-call? .state-v1 set-liquidation-flag flag cooldown))
    (asserts! (not (is-eq action ACTION_SET_INTEREST_ACCRUAL_FLAG)) (contract-call? .state-v1 set-interest-accrual-flag flag))
    ERR-INVALID-ACTION
))

(define-private (execute-state-set-market-flag (proposal-id (buff 32)) (action uint))
  (let ((cooldown (unwrap-panic (map-get? unpause-market-data proposal-id))))
    (asserts! (not (is-eq action ACTION_SET_MARKET_PAUSE_FLAG)) (contract-call? .state-v1 pause-market))
    (asserts! (not (is-eq action ACTION_SET_MARKET_UNPAUSE_FLAG)) (contract-call? .state-v1 unpause-market cooldown))
    ERR-INVALID-ACTION
))

(define-private (execute-state-update-collateral-settings (proposal-id (buff 32)))
  (let ((settings (unwrap-panic (map-get? collateral-settings-proposal-data proposal-id))))
    (contract-call? .state-v1 update-collateral-settings
      (get collateral settings)
      (get max-ltv settings)
      (get liquidation-ltv settings)
      (get liquidation-premium settings)
      (get decimals settings)
    )
))

(define-private (execute-state-reserve-action (proposal-id (buff 32)) (action uint))
  (let ((amount (unwrap-panic (map-get? reserve-proposal-data proposal-id))))
    (asserts! (not (is-eq action ACTION_DEPOSIT_TO_RESERVE)) (as-contract (contract-call? .state-v1 deposit-to-reserve amount)))
    (asserts! (not (is-eq action ACTION_WITHDRAW_FROM_RESERVE)) (contract-call? .state-v1 withdraw-from-reserve amount))
    ERR-INVALID-ACTION
))

(define-private (execute-state-set-allowed-contract (proposal-id (buff 32)) (action uint))
  (let ((allowed-contract (unwrap-panic (map-get? allowed-contract-data proposal-id))))
    (asserts! (not (is-eq action ACTION_SET_ALLOWED_CONTRACT)) (contract-call? .state-v1 set-allowed-contract allowed-contract))
    (asserts! (not (is-eq action ACTION_REMOVE_ALLOWED_CONTRACT)) (contract-call? .state-v1 remove-allowed-contract allowed-contract))
    ERR-INVALID-ACTION
))

(define-private (execute-update-guardian (proposal-id (buff 32)) (action uint))
  (let ((guardian (unwrap-panic (map-get? update-guardians-proposal-data proposal-id))))
    (asserts! (not (is-eq action ACTION_ADD_GUARDIAN)) (ok (map-set guardians guardian true)))
    (asserts! (not (is-eq action ACTION_REMOVE_GUARDIAN)) (ok (map-delete guardians guardian)))
    ERR-INVALID-ACTION
))

(define-private (execute-update-interest-rate-params (proposal-id (buff 32)))
  (let ((ir-data (unwrap-panic (map-get? update-interest-rate-params proposal-id))))
    (try! (accrue-interest))
    (contract-call? .linear-kinked-ir-v1 update-ir-params
      (get ir-slope-1-val ir-data)
      (get ir-slope-2-val ir-data)
      (get utilization-kink-val ir-data)
      (get base-ir-val ir-data)
    )
))

(define-private (execute-protocol-reserve-percentage (proposal-id (buff 32)))
  (let ((reserve-value (unwrap-panic (map-get? protocol-reserve-percentage proposal-id))))
    (try! (accrue-interest))
    (contract-call? .state-v1 set-protocol-reserve-percentage reserve-value)
))

(define-private (execute-update-asset-cap (proposal-id (buff 32)))
  (let ((asset-cap (unwrap-panic (map-get? asset-cap-update proposal-id))))
    (contract-call? .state-v1 update-asset-cap asset-cap)
))

(define-private (execute-update-reward-rate-params (proposal-id (buff 32)))
  (let ((reward-data (unwrap-panic (map-get? update-reward-rate-params proposal-id))))
    (try! (accrue-interest))
    (contract-call? .staking-reward-v1 update-reward-params
      (get slope-1-val reward-data)
      (get slope-2-val reward-data)
      (get staked-kink-val reward-data)
      (get base-reward-val reward-data)
    )
))

(define-private (execute-update-withdrawal-finalization-period (proposal-id (buff 32)))
  (let ((new-value (unwrap-panic (map-get? withdrawal-finalization-period proposal-id))))
    (contract-call? .staking-v1 update-withdrawal-finalization-period new-value)
))

(define-private (execute-transfer-funds (proposal-id (buff 32)))
  (let ((transfer-funds-data (unwrap-panic (map-get? transfer-funds proposal-id))))
    (as-contract (try! (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer (get amount transfer-funds-data) (as-contract contract-caller) (get account transfer-funds-data) none)))
    SUCCESS
))

(define-private (execute-freeze-upgrades)
  (contract-call? .state-v1 freeze-upgrades)
)

(define-private (execute-remove-collateral (proposal-id (buff 32)))
  (let ((collateral (unwrap-panic (map-get? remove-collateral proposal-id))))
    (try! (contract-call? .state-v1 remove-collateral collateral))
    SUCCESS
))

(define-private (execute-reconcile-staking-lp-balance)
  (contract-call? .staking-v1 reconcile-lp-token-balance)
)

(define-private (execute-set-staking-flag (proposal-id (buff 32)))
  (let ((status (unwrap-panic (map-get? staking-flag proposal-id))))
    (contract-call? .state-v1 set-staking-flag status)
))

(define-private (execute-update-time-delta (proposal-id (buff 32)))
  (let ((time-delta (unwrap-panic (map-get? update-time-delta-params proposal-id))))
    (contract-call? .pyth-adapter-v1 update-time-delta time-delta)
))

(define-private (execute-set-lp-cap (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? cap-data proposal-id))))
    (contract-call? .withdrawal-caps-v1 set-lp-cap (get factor data))
  )
)

(define-private (execute-set-debt-cap (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? cap-data proposal-id))))
    (contract-call? .withdrawal-caps-v1 set-debt-cap (get factor data))
  )
)

(define-private (execute-set-collateral-cap (proposal-id (buff 32)))
  (let (
      (data (unwrap-panic (map-get? cap-data proposal-id)))
      (collateral (unwrap-panic (get collateral data)))
      (factor (get factor data))
    )
    (contract-call? .withdrawal-caps-v1 set-collateral-cap collateral factor)
  )
)

(define-private (execute-set-refill-time-window (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? cap-data proposal-id))))
    (contract-call? .withdrawal-caps-v1 set-refill-time-window (get factor data))
  )
)

(define-private (execute-set-decay-time-window (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? cap-data proposal-id))))
    (contract-call? .withdrawal-caps-v1 set-decay-time-window (get factor data))
  )
)

(define-private (execute-update-flash-loan-fee (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? flash-loan-fee-update proposal-id))))
    (contract-call? .flash-loan-v1 update-fee data)
  )
)

(define-private (execute-add-flash-loan-contract (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? flash-loan-contract-update proposal-id))))
    (contract-call? .flash-loan-v1 set-allowed-contract data)
  )
)

(define-private (execute-remove-flash-loan-contract (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? flash-loan-contract-update proposal-id))))
    (contract-call? .flash-loan-v1 remove-allowed-contract data)
  )
)

(define-private (execute-allow-any-contract-flash-loan (proposal-id (buff 32)))
  (let ((data (unwrap-panic (map-get? flash-allow-disable-contract-update proposal-id))))
    (contract-call? .flash-loan-v1 update-allow-any-contract data)
  )
)

(define-private (approve-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (approve-count (get approve-count proposal))
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
      (percentage (/ (* approve-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (deny-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (deny-count (get deny-count proposal))
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
      (percentage (/ (* deny-count u100) total-count))
    )
    (ok (>= percentage THRESHOLD))
))

(define-private (execute-proposal (proposal-id (buff 32)) (action uint))
  (begin
    (asserts! (not (is-eq action ACTION_UPDATE_GOVERNANCE)) (execute-state-governance-update proposal-id))
    (asserts! (not (is-eq action ACTION_FREEZE_UPGRADES)) (execute-freeze-upgrades))
    (asserts! (not (and (>= action ACTION_SET_DEPOSIT_ASSET_FLAG) (<= action ACTION_SET_LIQUIDATION_FLAG))) (execute-state-set-feature-flag proposal-id action))
    (asserts! (not (and (>= action ACTION_SET_MARKET_PAUSE_FLAG) (<= action ACTION_SET_MARKET_UNPAUSE_FLAG))) (execute-state-set-market-flag proposal-id action))
    (asserts! (not (and (>= action ACTION_DEPOSIT_TO_RESERVE) (<= action ACTION_WITHDRAW_FROM_RESERVE))) (execute-state-reserve-action proposal-id action))
    (asserts! (not (is-eq action ACTION_UPDATE_COLLATERAL_SETTINGS)) (execute-state-update-collateral-settings proposal-id))
    (asserts! (not (and (>= action ACTION_SET_ALLOWED_CONTRACT) (<= action ACTION_REMOVE_ALLOWED_CONTRACT))) (execute-state-set-allowed-contract proposal-id action))
    (asserts! (not (and (>= action ACTION_ADD_GUARDIAN) (<= action ACTION_REMOVE_GUARDIAN))) (execute-update-guardian proposal-id action))
    (asserts! (not (is-eq action ACTION_UPDATE_INTEREST_RATE_PARAMS)) (execute-update-interest-rate-params proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_REWARD_RATE_PARAMS)) (execute-update-reward-rate-params proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_PROTOCOL_RESERVE_PERCENTAGE)) (execute-protocol-reserve-percentage proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_ASSET_CAP)) (execute-update-asset-cap proposal-id))
    (asserts! (not (is-eq action ACTION_TRANSFER_FUNDS)) (execute-transfer-funds proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_PYTH_TOKEN_FEED)) (execute-update-pyth-token-price-feed proposal-id))
    (asserts! (not (is-eq action ACTION_REMOVE_COLLATERAL)) (execute-remove-collateral proposal-id))
    (asserts! (not (is-eq action ACTION_SET_INTEREST_ACCRUAL_FLAG)) (execute-state-set-feature-flag proposal-id action))
    (asserts! (not (is-eq action ACTION_RECONCILE_STAKING_LP_BALANCE)) (execute-reconcile-staking-lp-balance))
    (asserts! (not (is-eq action ACTION_UPDATE_WITHDRAWAL_FINALIZATION_PERIOD)) (execute-update-withdrawal-finalization-period proposal-id))
    (asserts! (not (is-eq action ACTION_SET_STAKING_FLAG)) (execute-set-staking-flag proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_TIME_DELTA)) (execute-update-time-delta proposal-id))
    (asserts! (not (is-eq action ACTION_SET_LP_CAP)) (execute-set-lp-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_DEBT_CAP)) (execute-set-debt-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_COLLATERAL_CAP)) (execute-set-collateral-cap proposal-id))
    (asserts! (not (is-eq action ACTION_SET_REFILL_TIME_WINDOW)) (execute-set-refill-time-window proposal-id))
    (asserts! (not (is-eq action ACTION_SET_DECAY_TIME_WINDOW)) (execute-set-decay-time-window proposal-id))
    (asserts! (not (is-eq action ACTION_UPDATE_FLASH_LOAN_FEE)) (execute-update-flash-loan-fee proposal-id))
    (asserts! (not (is-eq action ACTION_ADD_CONTRACT_FLASH_LOAN)) (execute-add-flash-loan-contract proposal-id))
    (asserts! (not (is-eq action ACTION_REMOVE_CONTRACT_FLASH_LOAN)) (execute-remove-flash-loan-contract proposal-id))
    (asserts! (not (is-eq action ACTION_ALLOW_ANY_CONTRACT_FLASH_LOAN)) (execute-allow-any-contract-flash-loan proposal-id))
    ERR-INVALID-ACTION
))

(define-private (execute-if-approve-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (threshold (try! (approve-threshold-met proposal-id)))
      (action (get action proposal))
      (execute-at (get-proposal-execution-time proposal-id))
    )
    (if threshold
      (if (<= execute-at stacks-block-height)
        ;; proposal can be executed immediately
        (begin 
          (try! (execute-proposal proposal-id action))
          (map-set governance-proposal proposal-id (merge proposal {
            closed: true,
            executed: true,
            execute-at: (some stacks-block-height),
          }))
          (print {
            action: "proposal-executed",
            proposal-id: proposal-id
          })
          SUCCESS
        )

        ;; proposal will excuted after time-lock
        (begin
          (map-set governance-proposal proposal-id (merge proposal {
            ;; bump expires at for time locked proposals
            expires-at: (+ TIME_LOCK_EXECUTE_EXPIRATION_PERIOD execute-at),
            closed: false,
            executed: false,
            execute-at: (some execute-at),
          }))
          (print {
            action: "proposal-execution-time-locked",
            proposal-id: proposal-id,
            execute-at: execute-at
          })
          SUCCESS
        )
      )
      SUCCESS
    )

))

(define-private (deny-proposal-if-deny-threshold-met (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (threshold (try! (deny-threshold-met proposal-id)))
      (action (get action proposal))
    )
    (if threshold
      (begin
        (map-set governance-proposal proposal-id (merge proposal {
          closed: true,
          executed: false,
          execute-at: none,
        }))
        (print {
          action: "proposal-denied",
          proposal-id: proposal-id
        })
        SUCCESS
      )
      SUCCESS
    )
))

(define-private (set-guardians (maybe-account (optional principal)))
  (match maybe-account 
    account (begin (map-set guardians account true) SUCCESS)
    SUCCESS
))

(define-private (accrue-interest)
  (let (
      (accrue-interest-params (unwrap! (contract-call? .state-v1 get-accrue-interest-params) ERR-INTEREST-RATE-PARAMS))
      (accrued-interest (try! (contract-call? .linear-kinked-ir-v1 accrue-interest
        (get last-accrued-block-time accrue-interest-params)
        (get lp-interest accrue-interest-params)
        (get staked-interest accrue-interest-params)
        (try! (contract-call? .staking-reward-v1 calculate-staking-reward-percentage (contract-call? .staking-v1 get-active-staked-lp-tokens)))
        (get protocol-interest accrue-interest-params)
        (get protocol-reserve-percentage accrue-interest-params)
        (get total-assets accrue-interest-params)))
      )
    )
    (contract-call? .state-v1 set-accrued-interest accrued-interest)
))

(define-private (get-proposal-execution-time (proposal-id (buff 32)))
  (let (
    (proposal (unwrap-panic (map-get? governance-proposal proposal-id)))
    (action (get action proposal))
    (is-time-locked (default-to false (map-get? time-locked action)))
    (current-execute-at (get execute-at proposal))
    (execute-at (if is-time-locked (+ stacks-block-height TIME_LOCKED_PERIOD) stacks-block-height))
  )
    (if (is-some current-execute-at) (unwrap-panic current-execute-at) execute-at)
  )
)

;; READ ONLY FUNCTIONS
(define-read-only (is-governance-member (member principal))
  (contract-call? .meta-governance-v1 is-governance-member member)
)

(define-read-only (is-guardian (member principal))
  (begin
    (unwrap! (map-get? guardians member) ERR-NOT-GUARDIAN)
    SUCCESS
))

(define-read-only (get-proposal (proposal-id (buff 32)))
  (map-get? governance-proposal proposal-id)
)
  
;; PUBLIC FUNCTIONS

(define-public (initiate-proposal-to-set-market-feature (action uint) (feature bool) (expires-in uint) (cooldown uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: feature,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_SET_DEPOSIT_ASSET_FLAG) (<= action ACTION_SET_INTEREST_ACCRUAL_FLAG)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set set-market-feature-proposal-data proposal-id {
      flag: feature,
      cooldown: cooldown
    })
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-set-market-state (action uint) (expires-in uint) (cooldown uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_SET_MARKET_PAUSE_FLAG) (<= action ACTION_REMOVE_COLLATERAL)) ERR-INVALID-ACTION)
    (map-set unpause-market-data proposal-id cooldown)
    (try! (create-proposal proposal-id action expires-in))
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-freeze-upgrades (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: ACTION_FREEZE_UPGRADES,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id ACTION_FREEZE_UPGRADES expires-in))
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-governance (new-governance principal) (expires-in uint))
  (let (
      (action ACTION_UPDATE_GOVERNANCE)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: new-governance,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set update-governance-proposal-data proposal-id new-governance)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-collateral-settings (token <token-trait>) (max-ltv uint) (liquidation-ltv uint) (liquidation-premium uint) (expires-in uint))
  (let (
      (collateral (contract-of token))
      (decimals (unwrap-panic (contract-call? token get-decimals)))
      (action ACTION_UPDATE_COLLATERAL_SETTINGS)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: {
          collateral: collateral,
          max-ltv: max-ltv,
          liquidation-ltv: liquidation-ltv,
          liquidation-premium: liquidation-premium,
          decimals: decimals
        }
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set collateral-settings-proposal-data proposal-id {
      collateral: collateral,
      max-ltv: max-ltv,
      liquidation-ltv: liquidation-ltv,
      liquidation-premium: liquidation-premium,
      decimals: decimals
    })
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-remove-collateral (collateral principal) (expires-in uint))
  (let (
      (action ACTION_REMOVE_COLLATERAL)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: collateral
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set remove-collateral proposal-id collateral)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-for-reserve-balance (action uint) (amount uint) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: amount
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_DEPOSIT_TO_RESERVE) (<= action ACTION_WITHDRAW_FROM_RESERVE)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set reserve-proposal-data proposal-id amount)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-allowed-contract (action uint) (allowed-contract principal) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: allowed-contract
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_SET_ALLOWED_CONTRACT) (<= action ACTION_REMOVE_ALLOWED_CONTRACT)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set allowed-contract-data proposal-id allowed-contract)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-guardians (action uint) (guardian principal) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: guardian
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_ADD_GUARDIAN) (<= action ACTION_REMOVE_GUARDIAN)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set update-guardians-proposal-data proposal-id guardian)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-interest-params (ir-slope-1-val uint) (ir-slope-2-val uint) (utilization-kink-val uint) (base-ir-val uint) (expires-in uint))
  (let (
      (action ACTION_UPDATE_INTEREST_RATE_PARAMS)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: {
          ir-slope-1-val: ir-slope-1-val,
          ir-slope-2-val: ir-slope-2-val,
          utilization-kink-val: utilization-kink-val,
          base-ir-val: base-ir-val,
        }
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set update-interest-rate-params proposal-id {
      ir-slope-1-val: ir-slope-1-val,
      ir-slope-2-val: ir-slope-2-val,
      utilization-kink-val: utilization-kink-val,
      base-ir-val: base-ir-val,
    })
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-reward-params (slope-1-val int) (slope-2-val int) (staked-kink-val uint) (base-reward-val uint) (expires-in uint))
  (let (
      (action ACTION_UPDATE_REWARD_RATE_PARAMS)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: {
          slope-1-val: slope-1-val,
          slope-2-val: slope-2-val,
          staked-kink-val: staked-kink-val,
          base-reward-val: base-reward-val,
        }
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set update-reward-rate-params proposal-id {
      slope-1-val: slope-1-val,
      slope-2-val: slope-2-val,
      staked-kink-val: staked-kink-val,
      base-reward-val: base-reward-val,
    })
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-withdrawal-finalization-period (withdrawal-period uint) (expires-in uint))
  (let (
      (action ACTION_UPDATE_WITHDRAWAL_FINALIZATION_PERIOD)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: withdrawal-period
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set withdrawal-finalization-period proposal-id withdrawal-period)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-protocol-reserve-percentage (reserve-percentage uint) (expires-in uint))
  (let (
      (action ACTION_UPDATE_PROTOCOL_RESERVE_PERCENTAGE)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: reserve-percentage
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set protocol-reserve-percentage proposal-id reserve-percentage)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-asset-cap (asset-cap uint) (expires-in uint))
  (let (
      (action ACTION_UPDATE_ASSET_CAP)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: asset-cap
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set asset-cap-update proposal-id asset-cap)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-transfer-funds (account principal) (amount uint) (expires-in uint))
  (let (
      (action ACTION_TRANSFER_FUNDS)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        data: {
          account: account,
          amount: amount
        }
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set transfer-funds proposal-id {account: account, amount: amount})
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-reconcile-staking-lp-balance (expires-in uint))
  (let (
      (action ACTION_RECONCILE_STAKING_LP_BALANCE)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-set-staking-flag (expires-in uint) (status bool))
  (let (
      (action ACTION_SET_STAKING_FLAG)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        status: status,
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id action expires-in))
    (map-set staking-flag proposal-id status)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-pyth-time-delta (expires-in uint) (time-delta uint))
  (let (
      (action ACTION_UPDATE_TIME_DELTA)
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        time-delta: time-delta,
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (>= time-delta (contract-call? .pyth-adapter-v1 get-pyth-minimum-time-delta)) ERR-MINIMUM-PYTH-PRICE-DELTA)
    (try! (create-proposal proposal-id action expires-in))
    (map-set update-time-delta-params proposal-id time-delta)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-withdrawal-caps-param (action uint) (data { collateral: (optional principal), factor: uint }) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        data: data,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_SET_LP_CAP) (<= action ACTION_SET_DECAY_TIME_WINDOW)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (asserts! (if (is-eq action ACTION_SET_COLLATERAL_CAP)
      (is-some (get collateral data))
      true
    ) ERR-INVALID-ACTION)
    (map-set cap-data proposal-id data)
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-flash-loan-fee (new-fee uint) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: ACTION_UPDATE_FLASH_LOAN_FEE,
        new-fee: new-fee,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id ACTION_UPDATE_FLASH_LOAN_FEE expires-in))
    (map-set flash-loan-fee-update proposal-id new-fee)
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-flash-loan-contract (action uint) (contract principal) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: action,
        expires-in: expires-in,
        contract: contract,
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (asserts! (and (>= action ACTION_ADD_CONTRACT_FLASH_LOAN) (<= action ACTION_REMOVE_CONTRACT_FLASH_LOAN)) ERR-INVALID-ACTION)
    (try! (create-proposal proposal-id action expires-in))
    (map-set flash-loan-contract-update proposal-id contract)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initiate-proposal-to-update-allow-any-flash-loan (value bool) (expires-in uint))
  (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: ACTION_ALLOW_ANY_CONTRACT_FLASH_LOAN,
        value: value,
        expires-in: expires-in
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id ACTION_ALLOW_ANY_CONTRACT_FLASH_LOAN expires-in))
    (map-set flash-allow-disable-contract-update proposal-id value)
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))



(define-public (approve (proposal-id (buff 32)))
  (let ((proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL)))
    (try! (is-governance-member contract-caller))
    (asserts! (not (get closed proposal)) ERR-PROPOSAL-CLOSED)
    (asserts! (< stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (not (has-submitted-vote proposal-id)) ERR-SUBMITTED-VOTE)
    (asserts! (is-none (get execute-at proposal)) ERR-CANNOT-VOTE)
    (map-set proposal-approved-members {proposal-id: proposal-id, member: contract-caller} true)
    (map-set governance-proposal proposal-id (merge proposal { approve-count: (+ (get approve-count proposal) u1) }))

    (print {
      action: "proposal-voted-approved",
      voter: contract-caller,
      proposal-id: proposal-id
    })
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    SUCCESS
))

(define-public (deny (proposal-id (buff 32)))
  (let ((proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL)))
    (try! (is-governance-member contract-caller))
    (asserts! (not (get closed proposal)) ERR-PROPOSAL-CLOSED)
    (asserts! (< stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
    (asserts! (not (has-submitted-vote proposal-id)) ERR-SUBMITTED-VOTE)
    (asserts! (is-none (get execute-at proposal)) ERR-CANNOT-VOTE)
    (map-set proposal-denied-members {proposal-id: proposal-id, member: contract-caller} true)
    (map-set governance-proposal proposal-id (merge proposal { deny-count: (+ (get deny-count proposal) u1) }))

    (print {
      action: "proposal-voted-denied",
      voter: contract-caller,
      proposal-id: proposal-id
    })
    ;; deny proposal if the deny threshold is met
    (try! (deny-proposal-if-deny-threshold-met proposal-id))
    SUCCESS
))

;; Close the proposal when
;; - Every one voted
;; - But all the votes does not meet neither approve or deny threshold. Proposal is locked.
;; or proposal is expired
(define-public (close (proposal-id (buff 32)))
  (let (
      (proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL))
      (total-voted (+ (get approve-count proposal) (get deny-count proposal)))
      (total-count (contract-call? .meta-governance-v1 governance-multisig-count))
      (deny-threshold (try! (deny-threshold-met proposal-id)))
      (approve-threshold (try! (approve-threshold-met proposal-id)))
      (has-threshold-met (or deny-threshold approve-threshold))
    )
    (try! (is-governance-member contract-caller))
    (asserts! (not (get closed proposal)) ERR-PROPOSAL-CLOSED)
    (if (>= stacks-block-height (get expires-at proposal))
      (begin 
        (print {
          action: "proposal-expired",
          proposal-id: proposal-id
        })
        true
      )
      (begin
        (asserts! (is-eq total-count total-voted) ERR-PROPOSAL-VOTING-INCOMPLETE)
        (asserts! (not has-threshold-met) ERR-PROPOSAL-CANNOT-CLOSE)
      )
    )
    (map-set governance-proposal proposal-id (merge proposal { 
      closed: true,
      executed: false,
      execute-at: none
    }))
    (print {
      action: "proposal-closed",
      proposal-id: proposal-id
    })
    SUCCESS
))

(define-public (execute (proposal-id (buff 32)))
  (let ((proposal (unwrap! (map-get? governance-proposal proposal-id) ERR-UNKNOWN-PROPOSAL)))
    (try! (is-governance-member contract-caller))
    (asserts! (not (get closed proposal)) ERR-PROPOSAL-CLOSED)
    (asserts! (not (get executed proposal)) ERR-PROPOSAL-ALREADY-EXECUTED)
    (asserts! (<= (unwrap! (get execute-at proposal) ERR-PROPOSAL-NOT-TIME-LOCKED) stacks-block-height) ERR-PROPOSAL-TIME-LOCKED)
    (asserts! (< stacks-block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    SUCCESS
))

(define-public (initiate-proposal-to-update-pyth-feed (token principal) (feed (buff 32)) (max-confidence-ratio uint) (expires-in uint))
    (let (
      (proposal-nonce (var-get next-proposal-nonce))
      (proposal-id (keccak256 (unwrap! (to-consensus-buff? {
        sender: contract-caller,
        nonce: proposal-nonce,
        action: ACTION_UPDATE_PYTH_TOKEN_FEED,
        expires-in: expires-in,
        data: {
          feed: feed,
          max-confidence-ratio: max-confidence-ratio
        }
      }) ERR-FAILED-TO-GENERATE-PROPOSAL-ID)))
    )
    (try! (create-proposal proposal-id ACTION_UPDATE_PYTH_TOKEN_FEED expires-in))  
    (map-set update-pyth-feed proposal-id {token: token, feed: feed, max-confidence-ratio: max-confidence-ratio})
    ;; try to execute the proposal if threshold is met
    (try! (execute-if-approve-threshold-met proposal-id))
    (ok proposal-id)
))

(define-public (initialize-governance (guardians-addrs (list 5 (optional principal))))
  (begin
    (asserts! (not (var-get governance-initialized)) ERR-CONTRACT-ALREADY-INITIALIZED)
    (asserts! (is-eq contract-caller contract-deployer) ERR-NOT-CONTRACT-DEPLOYER)
    (var-set governance-initialized true)
    (map set-guardians guardians-addrs)
    SUCCESS
))

(define-public (guardian-pause-market)
  (begin
    (try! (is-guardian contract-caller))
    (try! (contract-call? .state-v1 pause-market))
    (try! (contract-call? .state-v1 set-staking-flag false))
    SUCCESS
))

(map-set time-locked ACTION_UPDATE_GOVERNANCE true)
(map-set time-locked ACTION_FREEZE_UPGRADES true)
(map-set time-locked ACTION_UPDATE_COLLATERAL_SETTINGS true)
(map-set time-locked ACTION_WITHDRAW_FROM_RESERVE true)
(map-set time-locked ACTION_ADD_GUARDIAN true)
(map-set time-locked ACTION_UPDATE_INTEREST_RATE_PARAMS true)
(map-set time-locked ACTION_UPDATE_PROTOCOL_RESERVE_PERCENTAGE true)
(map-set time-locked ACTION_REMOVE_COLLATERAL true)
(map-set time-locked ACTION_UPDATE_REWARD_RATE_PARAMS true)
(map-set time-locked ACTION_UPDATE_WITHDRAWAL_FINALIZATION_PERIOD true)
(map-set time-locked ACTION_SET_LP_CAP true)
(map-set time-locked ACTION_SET_DEBT_CAP true)
(map-set time-locked ACTION_SET_COLLATERAL_CAP true)
(map-set time-locked ACTION_SET_REFILL_TIME_WINDOW true)
(map-set time-locked ACTION_SET_DECAY_TIME_WINDOW true)
(map-set time-locked ACTION_SET_WITHDRAW_ASSET_FLAG true)
(map-set time-locked ACTION_SET_REMOVE_COLLATERAL_FLAG true)
(map-set time-locked ACTION_SET_REPAY_FLAG true)
(map-set time-locked ACTION_SET_MARKET_PAUSE_FLAG true)
(map-set time-locked ACTION_SET_ALLOWED_CONTRACT true)
(map-set time-locked ACTION_REMOVE_ALLOWED_CONTRACT true)
(map-set time-locked ACTION_SET_STAKING_FLAG true)
(map-set time-locked ACTION_UPDATE_FLASH_LOAN_FEE true)
(map-set time-locked ACTION_ADD_CONTRACT_FLASH_LOAN true)
(map-set time-locked ACTION_REMOVE_CONTRACT_FLASH_LOAN true)
(map-set time-locked ACTION_ALLOW_ANY_CONTRACT_FLASH_LOAN true)
