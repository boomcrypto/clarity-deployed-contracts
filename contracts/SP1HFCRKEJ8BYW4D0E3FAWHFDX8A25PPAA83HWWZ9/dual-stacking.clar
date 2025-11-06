;; ===================================
;; YIELD DUAL STACKING CONTRACT
;; ===================================
;; This contract manages yield distribution for participants who hold sBTC
;; and optionally stack STX. It operates in cycles with periodic snapshots
;; to calculate rewards based on holdings and stacking participation.

;; ===================================
;; ERROR CONSTANTS
;; ===================================
;; Organized in logical ranges for better maintainability:
;; 100-119: Enrollment & Participation
;; 120-139: Cycle Management
;; 140-159: Snapshot Operations
;; 160-179: Ratio & Weight Computation
;; 180-199: Reward Distribution
;; 200-219: Admin & Configuration
;; 220-239: Data Validation

;; Enrollment & Participation Errors (100-119)
(define-constant ERR_ACTIVATION_HEIGHT_NOT_MET (err u100))
(define-constant ERR_ALREADY_ENROLLED (err u101))
(define-constant ERR_USER_BLACKLISTED (err u102))
(define-constant ERR_NOT_ENROLLED (err u103))
(define-constant ERR_ENROLL_MINIMUM_HOLD_NOT_MET (err u104))
(define-constant ERR_CYCLE_IN_FUTURE (err u105))
(define-constant ERR_ALREADY_PROPOSED_RATIO (err u106))
(define-constant ERR_RATIO_NOT_PROPOSED (err u107))
(define-constant ERR_COMPUTE_RATIO_FOR_ALL_PARTICIPANTS_FIRST (err u108))
(define-constant ERR_COMPUTED_RATIO_ALL_PARTICIPANTS (err u109))
(define-constant ERR_RATIO_TOO_LOW (err u110))
(define-constant ERR_RATIO_TOO_HIGH (err u111))
(define-constant ERR_ALREADY_VALIDATED_RATIO (err u112))
(define-constant ERR_INVALID_RATIO_FOR_ZERO_STX (err u113))
(define-constant ERR_ALREADY_WHITELISTED (err u114))
(define-constant ERR_TRACKING_ADDRESS_NOT_WHITELISTED (err u115))
(define-constant ERR_NOT_BLACKLISTED (err u116))

;; Cycle Management Errors (120-139)
(define-constant ERR_NOT_NEW_CYCLE_YET (err u120))
(define-constant ERR_CYCLE_ENDED (err u121))
(define-constant ERR_CYCLE_ENDED_2 (err u122)) ;; This should never be thrown
(define-constant ERR_NOT_REWARDED_ALL (err u123))
(define-constant ERR_REWARDS_NOT_SENT_YET (err u124))

;; Snapshot Operation Errors (140-159)
(define-constant ERR_NOT_NEW_SNAPSHOT_YET (err u140))
(define-constant ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS (err u141))
(define-constant ERR_NOT_ALL_SNAPSHOTS (err u142))
(define-constant ERR_SNAPSHOTS_NOT_CONCLUDED (err u143))
(define-constant ERR_SNAPSHOTS_ALREADY_CONCLUDED (err u144))
(define-constant ERR_STX_BLOCK_NOT_MATCHING (err u145))
(define-constant ERR_STX_BLOCK_IN_FUTURE (err u146))

;; Ratio & Weight Computation Errors (160-179)
(define-constant ERR_RATIOS_NOT_CONCLUDED (err u160))
(define-constant ERR_WEIGHTS_NOT_COMPUTED (err u161))
(define-constant ERR_WEIGHTS_ALREADY_COMPUTED (err u162))
(define-constant ERR_NOT_ALL_WEIGHTS_COMPUTED (err u163))

;; Reward Distribution Errors (180-199)
(define-constant ERR_CANNOT_DISTRIBUTE_REWARDS (err u180))
(define-constant ERR_ALREADY_REWARDED (err u181))
(define-constant ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED (err u182))
(define-constant ERR_ALREADY_FINALIZED (err u183))
(define-constant ERR_CANNOT_FINALIZE (err u184))

;; Admin & Configuration Errors (200-219)
(define-constant ERR_NOT_ADMIN (err u200))
(define-constant ERR_CONTRACT_ALREADY_ACTIVE (err u201))
(define-constant ERR_CONTRACT_NOT_ACTIVE (err u202))
(define-constant ERR_APR_TOO_LOW (err u210))
(define-constant ERR_APR_TOO_HIGH (err u211))
(define-constant ERR_MULTIPLIER_TOO_LOW (err u212))
(define-constant ERR_MULTIPLIER_TOO_HIGH (err u213))

;; Data Validation Errors (220-239)
(define-constant ERR_WRONG_CYCLE_ID (err u220))
(define-constant ERR_ALREADY_INSTANTIATED (err u221))

;; Emergency Functions Errors (240-259)
(define-constant ERR_INSUFFICIENT_FUNDS (err u240))

;; ===================================
;; CONFIGURATION CONSTANTS
;; ===================================

(define-constant SNAPSHOT_NOT_TAKEN_MARKER u1000)
(define-constant SCALING_FACTOR u100000000)
(define-constant MIN_APR_SCALED u1000000) ;; 1% APR - 0.01 * 10^8
(define-constant MAX_APR_SCALED u20000000) ;; 20% APR - 0.20 * 10^8

(define-constant RATIO_PRECISION_HELPER_VALUE u100000000) ;; 10^8 precision for ratios
(define-constant SQRT_RATIO_PRECISION_HELPER_VALUE u10000) ;; 10^4 precision for sqrt-ratios
(define-constant MIN_GOLDEN_RATIO u1) ;; Minimum allowed ratio (10^-8 in scaled terms) to prevent division by zero

;; ===================================
;; STATE VARIABLES - Contract Control
;; ===================================

(define-data-var is-contract-active bool false)
(define-data-var admin principal contract-caller)
;; Operation tracking: u0=snapshotting, u1=concluded, u2=proposed-ratio, u3=ratio-validated, u4=weights-finalized, u5=set-can-distribute, u6=finalized
(define-data-var last-operation-done uint u0)

;; ===================================
;; STATE VARIABLES - Cycle Management
;; ===================================

(define-data-var cycle-id uint u0)
(define-data-var current-cycle-stacks-block-height uint u0)
(define-data-var current-cycle-bitcoin-block-height uint u0)
(define-data-var current-cycle-total-sbtc uint u0)
(define-data-var current-cycle-total-stx uint u0)
(define-data-var current-cycle-participants-count uint u0)

;; Cycle configuration variables
(define-data-var blocks-per-snapshot uint u0)
(define-data-var snapshots-per-cycle uint u0) ;; last snapshot is: next-cycle-bitcoin-block - blocks-per-snapshot
(define-data-var next-blocks-per-snapshot uint (var-get blocks-per-snapshot))
(define-data-var next-snapshots-per-cycle uint (var-get snapshots-per-cycle))
(define-data-var next-cycle-bitcoin-block-height uint (+ (var-get current-cycle-bitcoin-block-height)
  (* (var-get blocks-per-snapshot) (var-get snapshots-per-cycle))
))
(define-data-var bitcoin-blocks-per-year uint u52500)

;; ===================================
;; STATE VARIABLES - Snapshot Management
;; ===================================

(define-data-var current-snapshot-bitcoin-block-height uint u0)
(define-data-var current-snapshot-stacks-block-height uint u0)
(define-data-var current-snapshot-total-sbtc uint u0)
(define-data-var current-snapshot-total-stx uint u0)
(define-data-var current-snapshot-count uint u0)
(define-data-var current-snapshot-index uint u0)
(define-data-var are-snapshots-finalized bool false)
(define-data-var is-liquid-stacking-enabled bool true)

;; Local variable for snapshot processing
(define-data-var snapshot-block-hash (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)

;; ===================================
;; STATE VARIABLES - Rewards & Ratios
;; ===================================

(define-data-var is-ratio-validated bool false)
(define-data-var is-distribution-enabled bool false)
(define-data-var rewards-to-distribute uint u0)
(define-data-var participants-rewarded-count uint u0)

;; APR - annual percentage rate scaled by 10^8. This represents the maximum
;; percentage of the sBTC yield contributors are ready to give away as rewards
;; in a year.
(define-data-var APR uint u5000000)

;; Yield boost multiplier for dual stacking (M, where max boost = M+1)
;; Default is 9, meaning 10x max boost (M+1 = 10)
(define-data-var yield-boost-multiplier uint u9)

;; ===================================
;; STATE VARIABLES - Weight Computation
;; ===================================

(define-data-var total-weights-sum uint u0)
(define-data-var weights-computed-count uint u0)
(define-data-var are-weights-computed bool false)

;; ===================================
;; STATE VARIABLES - Enrollment
;; ===================================

(define-data-var next-cycle-participants-count uint u0)
(define-data-var min-sbtc-hold-required-for-enrollment uint u10000)

;; ===================================
;; STATE VARIABLES - Ratio Computation
;; ===================================

(define-data-var processing-ratio uint u0)
(define-data-var max-percentage-above-ratio uint u500) ;; 5%
(define-constant PRECISION_PERCENTAGE_RATIO u100)

;; ===================================
;; NETWORK-SPECIFIC INITIALIZATION
;; ===================================

;; Network-specific initialization
(var-set current-cycle-bitcoin-block-height u922150)
(var-set snapshots-per-cycle u14)
(var-set blocks-per-snapshot u150)

;; ===================================
;; DATA MAPS - Participant Management
;; ===================================

;; When someone enrolls, gets added to the map
;; When someone leaves, gets removed from the map
;; Use cycle relevant at get-stacks-block-info state of map when doing calculations
;; For DeFis the rewarded addresses will be the addresses of their reward SC
(define-map participants
  { address: principal }
  {
    stacking-address: principal, ;; same address as enrollment for users
    rewarded-address: principal, ;; default contract-caller if not set
    tracking-address: principal, ;; custom only for DeFis
  }
)

(define-map whitelisted-defi-tracking-addresses
  { address: principal } ;; their rewards SC
  { whitelisted: bool }
)

(define-map blacklist
  { address: principal }
  { blacklisted: bool }
)
;; (map-set blacklist {address: ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP} {blacklisted: true}) ;; wallet 8
;; the Foundation and other sBTC holders, will not be taken into account by default as they haven't enrolled in the SC (and they should not enroll)

;; ===================================
;; DATA MAPS - Holdings Tracking
;; ===================================

;; cycle should start when the PoX prepare phase starts
;; it should end when the next PoX cycle prepare phase starts

;; Enrolled address tracking per cycle
(define-map participant-holding
  {
    cycle-id: uint,
    address: principal,
  }
  {
    amount: uint,
    stacked: uint,
    last-snapshot: uint,
    rewarded: bool,
    reward-amount: uint,
  }
)

(define-map participant-addresses
  {
    cycle-id: uint,
    address: principal,
  }
  {
    stacking-address: principal, ;; same address as enrollment for users
    rewarded-address: principal, ;; default contract-caller if not set
    tracking-address: principal, ;; custom only for DeFis
  }
)

;; Track address for whole sBTC amount per cycle
(define-map tracking-holding
  {
    cycle-id: uint,
    tracking-address: principal,
  }
  {
    amount: uint,
    rewarded: bool,
  }
)

;; Stacking address for STX
(define-map stacking-holding
  {
    cycle-id: uint,
    stacking-address: principal,
  }
  { amount: uint }
)

;; Stacking address for STX
(define-map stacking-holding-snapshot-index
  {
    cycle-id: uint,
    snapshot-index: uint,
    stacking-address: principal,
  }
  { computed: bool }
)

;; Weight computation tracking
(define-map participant-weights
  {
    cycle-id: uint,
    tracking-address: principal,
  }
  { weight: uint }
)

(define-map participant-weight-tracked
  {
    cycle-id: uint,
    enrolled-address: principal,
  }
  { computed: bool }
)

;; ===================================
;; DATA MAPS - Rewards Management
;; ===================================

(define-map rewards-holding
  {
    cycle-id: uint,
    rewarded-address: principal,
  }
  { amount: uint }
)

;; ===================================
;; DATA MAPS - Cycle & Snapshot Data
;; ===================================

(define-map cycle-snapshot-to-stx-block-height
  {
    cycle-id: uint,
    snapshot-id: uint,
  }
  {
    stx-block-height: uint,
    bitcoin-block-height-stored: uint,
  }
)

(define-map distribution-finalized-stx-block-height-when-called
  { cycle-id: uint }
  { stx-block-height: uint }
)

(define-map yield-cycles-data
  { cycle-id: uint }
  {
    blocks-per-snapshot: uint,
    snapshots-per-cycle: uint,
    start-btc-block-height: uint,
    start-stx-block-height: uint,
  }
)

;; ===================================
;; DATA MAPS - Ratio Management
;; ===================================

(define-map proposed-ratio
  {
    cycle-id: uint,
    user: principal,
  }
  {
    golden-ratio: uint,
    participants-counted: uint,
    sbtc-below: uint,
    sbtc-above: uint,
    sbtc-equal: uint,
  }
)

(define-map track-proposed-given-ratio
  {
    cycle-id: uint,
    user: principal,
    ratio: uint,
  }
  { proposed: bool }
)

(define-map ratio-used
  { cycle-id: uint }
  { used-ratio: uint }
)

(define-map amount-below-ratio-cycle-user
  {
    cycle-id: uint,
    user: principal,
    ratio: uint,
  }
  { sbtc-amount: uint }
)

(define-map amount-above-ratio-cycle-user
  {
    cycle-id: uint,
    user: principal,
    ratio: uint,
  }
  { sbtc-amount: uint }
)

(define-map track-participant-computed-proposed-ratio
  {
    cycle-id: uint,
    user: principal,
    ratio: uint,
    user-address: principal,
  }
  { computed: bool }
)

(define-map track-participant-tracking-computed-proposed-ratio
  {
    cycle-id: uint,
    user: principal,
    ratio: uint,
    user-tracking-address: principal,
  }
  { computed: bool }
)

;; ===================================
;; INITIALIZATION FUNCTIONS
;; ===================================

;; Update the initial Bitcoin block height before contract activation
(define-public (update-initialize-block (new-bitcoin-block-height uint))
  (begin
    (asserts! (not (var-get is-contract-active))
      ERR_CONTRACT_ALREADY_ACTIVE
    )
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set current-cycle-bitcoin-block-height
      new-bitcoin-block-height
    ))
  )
)

;; Contract initialization - activates the contract and starts the first cycle
(define-public (initialize-contract (stx-block-height uint))
  (begin
    (asserts!
      (>= burn-block-height
        (var-get current-cycle-bitcoin-block-height)
      )
      ERR_ACTIVATION_HEIGHT_NOT_MET
    )
    (asserts! (not (var-get is-contract-active))
      ERR_CONTRACT_ALREADY_ACTIVE
    )
    (asserts!
      (unwrap-panic (contract-call? .bitcoin-block-buffer
        validate-stx-block-brackets-btc-block stx-block-height
        (var-get current-cycle-bitcoin-block-height)
      ))
      ERR_STX_BLOCK_NOT_MATCHING
    )

    (var-set next-snapshots-per-cycle (var-get snapshots-per-cycle))
    (var-set next-blocks-per-snapshot (var-get blocks-per-snapshot))
    (reset-state-for-cycle stx-block-height)
    (var-set next-cycle-bitcoin-block-height
      (+ (var-get current-cycle-bitcoin-block-height)
        (* (var-get blocks-per-snapshot) (var-get snapshots-per-cycle))
      ))
    (update-snapshot-for-new-cycle stx-block-height)
    (map-set cycle-snapshot-to-stx-block-height {
      cycle-id: (var-get cycle-id),
      snapshot-id: (var-get current-snapshot-index),
    } {
      stx-block-height: stx-block-height,
      bitcoin-block-height-stored: (var-get current-cycle-bitcoin-block-height),
    })
    (ok (var-set is-contract-active true))
  )
)

;; Reset state variables for a new cycle
(define-private (reset-state-for-cycle (stx-block-height uint))
  (begin
    (var-set blocks-per-snapshot (var-get next-blocks-per-snapshot))
    (var-set snapshots-per-cycle (var-get next-snapshots-per-cycle))
    (var-set is-distribution-enabled false)
    (var-set current-cycle-stacks-block-height stx-block-height)
    (var-set current-cycle-total-sbtc u0)
    (var-set current-cycle-total-stx u0)
    (var-set current-snapshot-total-sbtc u0)
    (var-set current-snapshot-total-stx u0)
    (var-set participants-rewarded-count u0)
    (var-set are-snapshots-finalized false)
    (var-set is-ratio-validated false)
    (var-set are-weights-computed false)
    (var-set weights-computed-count u0)
    (var-set total-weights-sum u0)
    (map-set yield-cycles-data { cycle-id: (var-get cycle-id) } {
      blocks-per-snapshot: (var-get blocks-per-snapshot),
      snapshots-per-cycle: (var-get snapshots-per-cycle),
      start-btc-block-height: (var-get current-cycle-bitcoin-block-height),
      start-stx-block-height: stx-block-height,
    })
    (var-set last-operation-done u0) ;; snapshotting
    (var-set current-cycle-participants-count
      (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
        (var-get next-cycle-participants-count)
      ))
  )
)

;; Update snapshot variables for a new cycle
(define-private (update-snapshot-for-new-cycle (stx-block-height uint))
  (begin
    (var-set current-snapshot-bitcoin-block-height
      (var-get current-cycle-bitcoin-block-height)
    )
    (var-set current-snapshot-count u0)
    (var-set current-snapshot-index u0)
    (var-set current-snapshot-stacks-block-height stx-block-height)
  )
)

;; ===================================
;; ENROLLMENT FUNCTIONS
;; ===================================

;; Enroll a user in the yield program
(define-public (enroll (rewarded-address (optional principal)))
  (let ((rewards-recipient (default-to contract-caller rewarded-address)))
    (asserts!
      (is-none (map-get? participants { address: contract-caller }))
      ERR_ALREADY_ENROLLED
    )
    (asserts!
      (is-none (map-get? blacklist { address: contract-caller }))
      ERR_USER_BLACKLISTED
    )
    (asserts!
      (>=
        (unwrap-panic (contract-call?
          'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          get-balance-available contract-caller
        ))
        (var-get min-sbtc-hold-required-for-enrollment)
      )
      ERR_ENROLL_MINIMUM_HOLD_NOT_MET
    )
    (var-set next-cycle-participants-count
      (+ (var-get next-cycle-participants-count) u1)
    )
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: rewards-recipient,
      enrolled-address: contract-caller,
      stacking-address: contract-caller,
      tracking-address: contract-caller,
      cycle-id: (var-get cycle-id),
      function-name: "enroll",
    })
    (ok (map-set participants { address: contract-caller } {
      rewarded-address: rewards-recipient,
      stacking-address: contract-caller,
      tracking-address: contract-caller,
    }))
  )
)

;; Enroll a DeFi protocol with custom addresses (admin only)
(define-public (enroll-defi
    (defi-contract principal)
    (tracking-address principal)
    (rewarded-address principal)
    (stacking-address (optional principal))
  )
  (let ((stacking-recipient (default-to defi-contract stacking-address)))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts!
      (is-none (map-get? participants { address: defi-contract }))
      ERR_ALREADY_ENROLLED
    )
    (asserts! (is-none (map-get? blacklist { address: defi-contract }))
      ERR_USER_BLACKLISTED
    )
    (var-set next-cycle-participants-count
      (+ (var-get next-cycle-participants-count) u1)
    )
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: rewarded-address,
      stacking-address: stacking-recipient,
      tracking-address: tracking-address,
      enrolled-address: defi-contract,
      cycle-id: (var-get cycle-id),
      function-name: "enroll",
    })
    (ok (map-set participants { address: defi-contract } {
      rewarded-address: rewarded-address,
      stacking-address: stacking-recipient,
      tracking-address: tracking-address,
    }))
  )
)

;; Batch enroll multiple DeFi protocols (admin only)
(define-public (enroll-defi-batch (defi-contracts (list
  900
  {
    defi-contract: principal,
    tracking-address: principal,
    rewarded-address: principal,
    stacking-address: (optional principal),
  }
)))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (map enroll-defi-one defi-contracts))
  )
)

;; Helper for batch DeFi enrollment
(define-private (enroll-defi-one (entry {
  defi-contract: principal,
  tracking-address: principal,
  rewarded-address: principal,
  stacking-address: (optional principal),
}))
  (let (
      (defi-contract (get defi-contract entry))
      (stacking-address (get stacking-address entry))
      (rewarded-address (get rewarded-address entry))
      (tracking-address (get tracking-address entry))
    )
    (try! (enroll-defi defi-contract tracking-address rewarded-address
      stacking-address
    ))
    (ok true)
  )
)

;; Opt out of the yield program
(define-public (opt-out)
  (begin
    (asserts!
      (is-some (map-get? participants { address: contract-caller }))
      ERR_NOT_ENROLLED
    )
    (ok (remove-participant contract-caller))
  )
)

;; Opt out a DeFi protocol (admin only)
(define-public (opt-out-defi (defi-contract principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts!
      (is-some (map-get? participants { address: defi-contract }))
      ERR_NOT_ENROLLED
    )
    (ok (remove-participant defi-contract))
  )
)

;; Batch opt out a DeFi protocol (admin only)
(define-public (opt-out-defi-batch (defi-contracts (list 200 principal)))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (map remove-participant defi-contracts))
  )
)

;; Add DeFi tracking address to whitelist - gives them maximum weight boost
(define-public (whitelist-defi-tracking (defi-rewards-contract principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts!
      (is-none (map-get? whitelisted-defi-tracking-addresses { address: defi-rewards-contract }))
      ERR_ALREADY_WHITELISTED
    )

    (print {
      bitcoin-block-height: burn-block-height,
      whitelisted-address: defi-rewards-contract,
      function-name: "whitelisted-defi-tracking-address",
    })
    (map-set whitelisted-defi-tracking-addresses { address: defi-rewards-contract } { whitelisted: true })
    (ok true)
  )
)

;; Remove DeFi tracking address from whitelist (admin only)
(define-public (remove-whitelisted-defi-tracking (defi-rewards-contract principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts!
      (is-some (map-get? whitelisted-defi-tracking-addresses { address: defi-rewards-contract }))
      ERR_TRACKING_ADDRESS_NOT_WHITELISTED
    )
    (print {
      bitcoin-block-height: burn-block-height,
      removed-whitelisted-address: defi-rewards-contract,
      function-name: "remove-whitelisted-defi-tracking-address",
    })
    (map-delete whitelisted-defi-tracking-addresses { address: defi-rewards-contract })
    (ok true)
  )
)

;; Batch remove DeFi tracking addresses from whitelist (admin only)
(define-public (remove-whitelisted-defi-tracking-batch (defi-rewards-contract (list 200 principal)))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (map remove-whitelisted-defi-tracking defi-rewards-contract))
  )
)

;; Remove a participant from enrollment
(define-private (remove-participant (address principal))
  (begin
    (print {
      bitcoin-block-height: burn-block-height,
      enrolled-address: address,
      cycle-id: (var-get cycle-id),
      function-name: "opt-out",
    })
    (map-delete participants { address: address })
    (var-set next-cycle-participants-count
      (- (var-get next-cycle-participants-count) u1)
    )
  )
)

(define-public (set-liquid-stacking (state bool))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set is-liquid-stacking-enabled state))
  )
)

;; ===================================
;; PARTICIPANT MANAGEMENT FUNCTIONS
;; ===================================

;; Change reward address for a user
(define-public (change-reward-address (new-address principal))
  (let ((participant (map-get? participants { address: contract-caller })))
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: new-address,
      stacking-address: (get stacking-address participant),
      tracking-address: (get tracking-address participant),
      enrolled-address: contract-caller,
      cycle-id: (var-get cycle-id),
      function-name: "update-participant-details",
    })
    (ok (map-set participants { address: contract-caller }
      (merge (unwrap-panic participant) { rewarded-address: new-address })
    ))
  )
)

;; Change reward address for a DeFi protocol (admin only)
(define-public (change-reward-address-defi
    (defi-contract principal)
    (new-reward-address principal)
  )
  (let ((participant (map-get? participants { address: defi-contract })))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: new-reward-address,
      stacking-address: (get stacking-address participant),
      tracking-address: (get tracking-address participant),
      enrolled-address: defi-contract,
      cycle-id: (var-get cycle-id),
      function-name: "update-participant-details",
    })
    (ok (map-set participants { address: defi-contract }
      (merge (unwrap-panic participant) { rewarded-address: new-reward-address })
    ))
  )
)

;; Change stacking address for a DeFi protocol (admin only)
(define-public (change-stacking-address-defi
    (defi-contract principal)
    (new-stacking-address principal)
  )
  (let ((participant (map-get? participants { address: defi-contract })))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: (get rewarded-address participant),
      stacking-address: new-stacking-address,
      tracking-address: (get tracking-address participant),
      enrolled-address: defi-contract,
      cycle-id: (var-get cycle-id),
      function-name: "update-participant-details",
    })
    (ok (map-set participants { address: defi-contract }
      (merge (unwrap-panic participant) { stacking-address: new-stacking-address })
    ))
  )
)

;; Change tracking address for a DeFi protocol (admin only)
(define-public (change-tracking-address-defi
    (defi-contract principal)
    (new-tracking-address principal)
  )
  (let ((participant (map-get? participants { address: defi-contract })))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (print {
      bitcoin-block-height: burn-block-height,
      reward-address: (get rewarded-address participant),
      stacking-address: (get stacking-address participant),
      tracking-address: new-tracking-address,
      enrolled-address: defi-contract,
      cycle-id: (var-get cycle-id),
      function-name: "update-participant-details",
    })
    (ok (map-set participants { address: defi-contract }
      (merge (unwrap-panic participant) { tracking-address: new-tracking-address })
    ))
  )
)

;; Change addresses details for a DeFi protocol (admin only)
(define-public (change-addresses-defi
    (defi-contract principal)
    (new-tracking-address (optional principal))
    (new-reward-address (optional principal))
    (new-stacking-address (optional principal))
  )
  (let ((participant (map-get? participants { address: defi-contract })))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (let (
        (local-reward-address (default-to (unwrap-panic (get rewarded-address participant))
          new-reward-address
        ))
        (local-stacking-address (default-to (unwrap-panic (get stacking-address participant))
          new-stacking-address
        ))
        (local-tracking-address (default-to (unwrap-panic (get tracking-address participant))
          new-tracking-address
        ))
      )
      (print {
        bitcoin-block-height: burn-block-height,
        reward-address: local-reward-address,
        stacking-address: local-stacking-address,
        tracking-address: local-tracking-address,
        enrolled-address: defi-contract,
        cycle-id: (var-get cycle-id),
        function-name: "update-participant-details",
      })
      (ok (map-set participants { address: defi-contract } {
        rewarded-address: local-reward-address,
        tracking-address: local-tracking-address,
        stacking-address: local-stacking-address,
      }))
    )
  )
)

;; Batch change addresses details multiple DeFi protocols (admin only)
(define-public (change-addresses-defi-batch (defi-contracts (list
  900
  {
    defi-contract: principal,
    tracking-address: (optional principal),
    rewarded-address: (optional principal),
    stacking-address: (optional principal),
  }
)))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (map change-addresses-defi-one defi-contracts))
  )
)

;; Helper for batch DeFi change addresses details
(define-private (change-addresses-defi-one (entry {
  defi-contract: principal,
  tracking-address: (optional principal),
  rewarded-address: (optional principal),
  stacking-address: (optional principal),
}))
  (let (
      (defi-contract (get defi-contract entry))
      (stacking-address (get stacking-address entry))
      (rewarded-address (get rewarded-address entry))
      (tracking-address (get tracking-address entry))
    )
    (try! (change-addresses-defi defi-contract tracking-address
      rewarded-address stacking-address
    ))
    (ok true)
  )
)

;; ===================================
;; BLACKLIST MANAGEMENT FUNCTIONS
;; ===================================

;; Add an address to the blacklist (admin only)
(define-public (add-blacklisted (address principal))
  (let ((participant (map-get? participants { address: address })))
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (if (is-some participant)
      (begin
        (remove-participant address)
        (print {
          bitcoin-block-height: burn-block-height,
          reward-address: (get rewarded-address participant),
          stacking-address: (get stacking-address participant),
          tracking-address: (get tracking-address participant),
          enrolled-address: address,
          cycle-id: (var-get cycle-id),
          function-name: "blacklisted",
        })
        (ok (map-set blacklist { address: address } { blacklisted: true }))
      )
      (begin
        (print {
          bitcoin-block-height: burn-block-height,
          enrolled-address: address,
          cycle-id: (var-get cycle-id),
          function-name: "blacklisted",
        })
        (ok (map-set blacklist { address: address } { blacklisted: true }))
      )
    )
  )
)

;; Batch add addresses to blacklist (admin only)
(define-public (add-blacklisted-batch (addresses (list 200 principal)))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (map add-blacklisted addresses))
  )
)

;; Remove an address from the blacklist (admin only)
(define-public (remove-blacklisted (address principal))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (asserts! (is-some (map-get? blacklist { address: address }))
      ERR_NOT_BLACKLISTED
    )
    (print {
      bitcoin-block-height: burn-block-height,
      enrolled-address: address,
      cycle-id: (var-get cycle-id),
      function-name: "unblacklisted",
    })
    (ok (map-delete blacklist { address: address }))
  )
)

;; Batch remove addresses from blacklist (admin only)
(define-public (remove-blacklisted-batch (addresses (list 200 principal)))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (map remove-blacklisted addresses))
  )
)

;; ===================================
;; ADMIN CONFIGURATION FUNCTIONS
;; ===================================

;; Update admin address
(define-public (update-admin (new-admin-address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      admin-address: new-admin-address,
      cycle-id: (var-get cycle-id),
      function-name: "update-admin",
    })
    (ok (var-set admin new-admin-address))
  )
)

;; Update minimum hold requirement for enrollment
(define-public (update-min-sbtc-hold-required-for-enrollment (new-min-hold uint))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      min-sbtc-hold-required-for-enrollment: new-min-hold,
      cycle-id: (var-get cycle-id),
      function-name: "update-min-enrollment",
    })
    (ok (var-set min-sbtc-hold-required-for-enrollment new-min-hold))
  )
)

;; Update the number of blocks per snapshot (applies to next cycle)
(define-public (update-snapshot-length (updated-blocks-per-snapshot uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      snapshot-length: updated-blocks-per-snapshot,
      cycle-id: (var-get cycle-id),
      function-name: "update-snapshot-length",
    })
    (ok (var-set next-blocks-per-snapshot updated-blocks-per-snapshot))
  )
)

;; Update the number of snapshots per cycle (applies to next cycle)
(define-public (update-snapshots-per-cycle (updated-snapshots-per-cycle uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      snapshots-per-cycle: updated-snapshots-per-cycle,
      cycle-id: (var-get cycle-id),
      function-name: "update-snapshots-per-cycle",
    })
    (ok (var-set next-snapshots-per-cycle updated-snapshots-per-cycle))
  )
)

;; Update both snapshots per cycle and blocks per snapshot (applies to next cycle)
(define-public (update-cycle-data
    (updated-snapshots-per-cycle uint)
    (updated-blocks-per-snapshot uint)
  )
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      snapshot-length: updated-blocks-per-snapshot,
      snapshots-per-cycle: updated-snapshots-per-cycle,
      cycle-id: (var-get cycle-id),
      function-name: "update-cycle-data",
    })
    (var-set next-snapshots-per-cycle updated-snapshots-per-cycle)
    (ok (var-set next-blocks-per-snapshot updated-blocks-per-snapshot))
  )
)

;; Update both snapshots per cycle and blocks per snapshot (applies to first cycle)
(define-public (update-cycle-data-before-initialized
    (updated-snapshots-per-cycle uint)
    (updated-blocks-per-snapshot uint)
  )
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)

    (asserts! (not (var-get is-contract-active))
      ERR_CONTRACT_ALREADY_ACTIVE
    )
    (print {
      bitcoin-block-height: burn-block-height,
      snapshot-length: updated-blocks-per-snapshot,
      snapshots-per-cycle: updated-snapshots-per-cycle,
      cycle-id: (var-get cycle-id),
      function-name: "update-cycle-data",
    })
    (var-set snapshots-per-cycle updated-snapshots-per-cycle)
    (ok (var-set blocks-per-snapshot updated-blocks-per-snapshot))
  )
)

;; Update both snapshots per cycle and blocks per snapshot (applies to next cycle)
(define-public (update-bitcoin-blocks-per-year (updated-bitcoin-blocks-per-year uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (print {
      bitcoin-block-height: burn-block-height,
      cycle-id: (var-get cycle-id),
      bitcoin-blocks-per-year: updated-bitcoin-blocks-per-year,
      function-name: "update-bitcoin-blocks-per-year",
    })
    (ok (var-set bitcoin-blocks-per-year updated-bitcoin-blocks-per-year))
  )
)

;; Update APR (Annual Percentage Rate, applies to next cycle)
(define-public (update-APR (new-apr-one-eight uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (asserts! (>= new-apr-one-eight MIN_APR_SCALED) ERR_APR_TOO_LOW)
    (asserts! (<= new-apr-one-eight MAX_APR_SCALED) ERR_APR_TOO_HIGH)
    (ok (var-set APR new-apr-one-eight))
  )
)

;; Update yield boost multiplier for dual stacking (M, where max boost = M+1)
;; Default is 9, meaning 10x max boost (M+1 = 10)
;; Note: This takes effect immediately (unlike APR which applies to next cycle)
(define-public (update-yield-boost-multiplier (new-multiplier uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (asserts! (>= new-multiplier u1) ERR_MULTIPLIER_TOO_LOW)
    (asserts! (<= new-multiplier u20) ERR_MULTIPLIER_TOO_HIGH) ;; capped at 21x max boost
    (print {
      bitcoin-block-height: burn-block-height,
      yield-boost-multiplier: new-multiplier,
      max-boost: (+ new-multiplier u1),
      cycle-id: (var-get cycle-id),
      function-name: "update-yield-boost-multiplier",
    })
    (ok (var-set yield-boost-multiplier new-multiplier))
  )
)

;; Emergency withdraw function for admin to withdraw sBTC funds
(define-public (emergency-withdraw-sbtc
    (amount uint)
    (recipient principal)
  )
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (> amount u0) ERR_INSUFFICIENT_FUNDS)
    (let ((contract-balance (unwrap-panic (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        get-balance-available (as-contract contract-caller)
      ))))
      (asserts! (>= contract-balance amount) ERR_INSUFFICIENT_FUNDS)
      (print {
        bitcoin-block-height: burn-block-height,
        cycle-id: (var-get cycle-id),
        amount: amount,
        recipient: recipient,
        contract-balance: contract-balance,
        function-name: "emergency-withdraw-sbtc",
      })
      (try! (as-contract (contract-call?
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        transfer amount tx-sender recipient none
      )))
      (ok true)
    )
  )
)

;; Read-only function to check contract's sBTC balance
(define-read-only (get-contract-sbtc-balance)
  (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
    get-balance-available (as-contract contract-caller)
  ))
)

;; ===================================
;; SNAPSHOT FUNCTIONS
;; ===================================

;; Capture snapshot balances for a list of participants
(define-public (capture-snapshot-balances (principals (list 900 principal)))
  (let ((stx-id-header-hash (unwrap!
      (get-stacks-block-info? id-header-hash
        (var-get current-snapshot-stacks-block-height)
      )
      ERR_STX_BLOCK_IN_FUTURE
    )))
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (var-set snapshot-block-hash stx-id-header-hash)
    (let ((snapshot-total (fold capture-participant-balances principals u0)))
      (var-set current-snapshot-total-sbtc
        (+ (var-get current-snapshot-total-sbtc) snapshot-total)
      )
      (ok snapshot-total)
    )
  )
)

;; Capture and update balances for a single user during snapshot
(define-private (capture-participant-balances
    (address principal)
    (current-sbtc-total uint)
  )
  (let (
      (cycle-id-current (var-get cycle-id))
      (is-user-enrolled-this-cycle (is-enrolled-this-cycle address))
      (participant-data (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash
          (var-get current-cycle-stacks-block-height)
        ))
        (map-get? participants { address: address })
      ))
      (participant-hold (map-get? participant-holding {
        cycle-id: cycle-id-current,
        address: address,
      }))
      (sbtc-balance (at-block
        ;; nonexistent sbtc-balance on that block height - never happens
        (var-get snapshot-block-hash)
        (unwrap-panic (contract-call?
          'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          get-balance-available address
        ))
      ))
      (local-current-snapshot-index (var-get current-snapshot-index))
    )
    ;; only add those that are part of the pool and aren't already snapshotted
    (if (or
        (is-none participant-data)
        (and (is-some participant-data) (is-eq
          (default-to SNAPSHOT_NOT_TAKEN_MARKER
            (get last-snapshot participant-hold)
          )
          local-current-snapshot-index
        ))
      )
      ;; don't count him
      current-sbtc-total
      (let (
          ;; the unwrap panic never throws as we have the other map checked, meaning we also have value here
          (stacked-address (unwrap-panic (get stacking-address participant-data)))
          (stacking-hold (map-get? stacking-holding {
            cycle-id: cycle-id-current,
            stacking-address: stacked-address,
          }))
          (new-total (+ current-sbtc-total sbtc-balance))
          ;; the unwrap panic never throws as we have the other map checked, meaning we also have value here
          (tracking-address (unwrap-panic (get tracking-address participant-data)))
          (tracking-hold (map-get? tracking-holding {
            cycle-id: cycle-id-current,
            tracking-address: tracking-address,
          }))
          (stx-stacked (if (get-is-whitelisted-defi tracking-address)
            u0
            (get-amount-stacked-at-block-height stacked-address
              (var-get current-snapshot-stacks-block-height)
            )
          ))
        )
        (var-set current-snapshot-count
          (+ (var-get current-snapshot-count) u1)
        )
        (var-set current-snapshot-total-stx
          (+ (var-get current-snapshot-total-stx) stx-stacked)
        )
        (map-set participant-holding {
          cycle-id: cycle-id-current,
          address: address,
        } {
          amount: (+ sbtc-balance (default-to u0 (get amount participant-hold))), ;; just for data, not used afterwards in computations
          stacked: (+ stx-stacked (default-to u0 (get stacked participant-hold))),
          last-snapshot: local-current-snapshot-index,
          rewarded: false,
          reward-amount: u0,
        })
        (map-set tracking-holding {
          cycle-id: cycle-id-current,
          tracking-address: tracking-address,
        } {
          amount: (+ sbtc-balance (default-to u0 (get amount tracking-hold))),
          rewarded: false,
        })
        (if (is-some (map-get? stacking-holding-snapshot-index {
            cycle-id: cycle-id-current,
            snapshot-index: local-current-snapshot-index,
            stacking-address: stacked-address,
          }))
          true
          (begin
            (map-set stacking-holding {
              cycle-id: cycle-id-current,
              stacking-address: stacked-address,
            } { amount: (+ stx-stacked (default-to u0 (get amount stacking-hold))) }
            )
            (map-set stacking-holding-snapshot-index {
              cycle-id: cycle-id-current,
              snapshot-index: local-current-snapshot-index,
              stacking-address: stacked-address,
            } { computed: true }
            )
          )
        )
        (print {
          cycle-id: cycle-id-current,
          snapshot-index: local-current-snapshot-index,
          sbtc-balance: sbtc-balance,
          stx-stacked: stx-stacked,
          tracking-address: tracking-address,
          stacking-address: stacked-address,
          enrolled-address: address,
          function-name: "compute-current-snapshot-balance",
        })
        new-total
      )
    )
  )
)

;; Advance to the next snapshot in the current cycle
(define-public (advance-to-next-snapshot (new-stx-block-height uint))
  (let ((next-snapshot-bitcoin-block-height (+ (var-get current-snapshot-bitcoin-block-height)
      (var-get blocks-per-snapshot)
    )))
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (>= burn-block-height next-snapshot-bitcoin-block-height)
      ERR_NOT_NEW_SNAPSHOT_YET
    )
    (asserts!
      (is-eq (var-get current-snapshot-count)
        (var-get current-cycle-participants-count)
      )
      ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS
    )
    (asserts!
      (not (is-eq (var-get snapshots-per-cycle)
        (+ (var-get current-snapshot-index) u1)
      ))
      ERR_CYCLE_ENDED
    )
    (asserts!
      (< next-snapshot-bitcoin-block-height
        (var-get next-cycle-bitcoin-block-height)
      )
      ERR_CYCLE_ENDED_2
    )
    (asserts!
      (unwrap-panic (contract-call? .bitcoin-block-buffer
        validate-stx-block-brackets-btc-block new-stx-block-height
        next-snapshot-bitcoin-block-height
      ))
      ERR_STX_BLOCK_NOT_MATCHING
    )

    (var-set current-snapshot-bitcoin-block-height
      next-snapshot-bitcoin-block-height
    )
    (var-set current-cycle-total-sbtc
      (+ (var-get current-cycle-total-sbtc)
        (var-get current-snapshot-total-sbtc)
      ))
    (var-set current-cycle-total-stx
      (+ (var-get current-cycle-total-stx)
        (var-get current-snapshot-total-stx)
      ))
    (var-set current-snapshot-total-sbtc u0)
    (var-set current-snapshot-total-stx u0)
    (var-set current-snapshot-count u0)
    (var-set current-snapshot-index
      (+ (var-get current-snapshot-index) u1)
    )
    (map-set cycle-snapshot-to-stx-block-height {
      cycle-id: (var-get cycle-id),
      snapshot-id: (var-get current-snapshot-index),
    } {
      stx-block-height: new-stx-block-height,
      bitcoin-block-height-stored: next-snapshot-bitcoin-block-height,
    })
    (ok (var-set current-snapshot-stacks-block-height new-stx-block-height))
  )
)

;; Finalize all snapshots for the current cycle
(define-public (finalize-snapshots)
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (not (var-get are-snapshots-finalized))
      ERR_SNAPSHOTS_ALREADY_CONCLUDED
    )
    (asserts!
      (is-eq (+ (var-get current-snapshot-index) u1)
        (var-get snapshots-per-cycle)
      )
      ERR_NOT_ALL_SNAPSHOTS
    )
    (asserts!
      (is-eq (var-get current-snapshot-count)
        (var-get current-cycle-participants-count)
      )
      ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS
    )
    ;; Add in the calculation the total amount from the last snapshot
    (var-set current-cycle-total-sbtc
      (+ (var-get current-cycle-total-sbtc)
        (var-get current-snapshot-total-sbtc)
      ))
    (var-set current-cycle-total-stx
      (+ (var-get current-cycle-total-stx)
        (var-get current-snapshot-total-stx)
      ))
    (print {
      cycle-id: (var-get cycle-id),
      current-cycle-total-sbtc: (var-get current-cycle-total-sbtc),
      current-cycle-total-stx: (var-get current-cycle-total-stx),
      function-name: "conclude-cycle-snapshots",
    })
    (var-set last-operation-done u1) ;; concluded
    (ok (var-set are-snapshots-finalized true))
  )
)

;; ===================================
;; RATIO COMPUTATION FUNCTIONS
;; ===================================

;; Propose a golden ratio for the current cycle
(define-public (propose-golden-ratio (ratio uint))
  (begin
    (asserts! (var-get are-snapshots-finalized)
      ERR_SNAPSHOTS_NOT_CONCLUDED
    )
    (asserts!
      (is-none (map-get? ratio-used { cycle-id: (var-get cycle-id) }))
      ERR_ALREADY_VALIDATED_RATIO
    )
    (asserts!
      (is-none (map-get? proposed-ratio {
        cycle-id: (var-get cycle-id),
        user: tx-sender,
      }))
      ERR_ALREADY_PROPOSED_RATIO
    )
    (map-set proposed-ratio {
      cycle-id: (var-get cycle-id),
      user: tx-sender,
    } {
      golden-ratio: ratio,
      participants-counted: u0,
      sbtc-below: u0,
      sbtc-above: u0,
      sbtc-equal: u0,
    })
    (var-set last-operation-done u2) ;; proposed-ratio
    (ok true)
  )
)

;; Change a previously proposed golden ratio before validation
(define-public (change-proposed-golden-ratio (ratio uint))
  (begin
    (asserts!
      (is-some (map-get? proposed-ratio {
        cycle-id: (var-get cycle-id),
        user: tx-sender,
      }))
      ERR_RATIO_NOT_PROPOSED
    )
    (asserts!
      (is-none (map-get? ratio-used { cycle-id: (var-get cycle-id) }))
      ERR_ALREADY_VALIDATED_RATIO
    )
    (map-set proposed-ratio {
      cycle-id: (var-get cycle-id),
      user: tx-sender,
    } {
      golden-ratio: ratio,
      participants-counted: u0,
      sbtc-below: u0,
      sbtc-above: u0,
      sbtc-equal: u0,
    })
    (ok true)
  )
)

;; Tally participant ratios relative to proposed golden ratio
;; Accumulates sBTC amounts above/below the proposed ratio for validation
(define-public (tally-participant-ratios (principals (list 900 principal)))
  (let (
      (proposed-ratio-map (unwrap!
        (map-get? proposed-ratio {
          cycle-id: (var-get cycle-id),
          user: tx-sender,
        })
        ERR_RATIO_NOT_PROPOSED
      ))
      (golden-ratio (get golden-ratio proposed-ratio-map))
      (participants-count (get participants-counted proposed-ratio-map))
    )
    (asserts!
      (is-none (map-get? ratio-used { cycle-id: (var-get cycle-id) }))
      ERR_ALREADY_VALIDATED_RATIO
    )
    (asserts!
      (< participants-count (var-get current-cycle-participants-count))
      ERR_COMPUTED_RATIO_ALL_PARTICIPANTS
    )
    (var-set processing-ratio golden-ratio)
    (fold tally-user-ratio principals u0)
    (ok true)
  )
)

;; Helper function to tally user ratio relative to proposed golden ratio
(define-private (tally-user-ratio
    (address principal)
    (random-irrelevant uint)
  )
  (let (
      (current-cycle-id (var-get cycle-id))
      (participant-state (unwrap-panic (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash
          (var-get current-cycle-stacks-block-height)
        ))
        (map-get? participants { address: address })
      )))
      (stacking-address (get stacking-address participant-state))
      (stacking-state (unwrap-panic (map-get? stacking-holding {
        stacking-address: stacking-address,
        cycle-id: current-cycle-id,
      })))
      (stx-user-amount (get amount stacking-state))
      (tracking-address (get tracking-address participant-state))
      (tracking-state (unwrap-panic (map-get? tracking-holding {
        tracking-address: tracking-address,
        cycle-id: current-cycle-id,
      })))
      (sbtc-user-amount (get amount tracking-state))
      (current-proposed-ratio (var-get processing-ratio))
      (proposed-ratio-map (unwrap-panic (map-get? proposed-ratio {
        cycle-id: current-cycle-id,
        user: tx-sender,
      })))
      (proposed-participants-counted (get participants-counted proposed-ratio-map))
      (sbtc-below (get sbtc-below proposed-ratio-map))
      (sbtc-above (get sbtc-above proposed-ratio-map))
      (sbtc-equal (get sbtc-equal proposed-ratio-map))
    )
    (if (is-some (map-get? track-participant-computed-proposed-ratio {
        cycle-id: current-cycle-id,
        user: tx-sender,
        ratio: current-proposed-ratio,
        user-address: address,
      }))
      u0
      (begin
        (print {
          cycle-id: current-cycle-id,
          enrolled-address: address,
          stacking-address: stacking-address,
          tracking-address: tracking-address,
          function-name: "count-golden-ratio",
          stx-user-amount: stx-user-amount,
          sbtc-user-amount: sbtc-user-amount,
          tx-sender: tx-sender,
        })
        (map-set track-participant-computed-proposed-ratio {
          cycle-id: current-cycle-id,
          user: tx-sender,
          ratio: current-proposed-ratio,
          user-address: address,
        } { computed: true }
        )
        (map-set proposed-ratio {
          cycle-id: current-cycle-id,
          user: tx-sender,
        }
          (merge proposed-ratio-map { participants-counted: (+ proposed-participants-counted u1) })
        )
        (if (or
            (is-eq sbtc-user-amount u0)
            (is-some (map-get?
              track-participant-tracking-computed-proposed-ratio {
              cycle-id: current-cycle-id,
              user: tx-sender,
              ratio: current-proposed-ratio,
              user-tracking-address: tracking-address,
            }))
          )
          u0
          (let (
              (proposed-ratio-map-v2 (unwrap-panic (map-get? proposed-ratio {
                cycle-id: current-cycle-id,
                user: tx-sender,
              })))
              (user-ratio (/ (* stx-user-amount RATIO_PRECISION_HELPER_VALUE)
                sbtc-user-amount
              ))
            )
            (map-set track-participant-tracking-computed-proposed-ratio {
              cycle-id: current-cycle-id,
              user: tx-sender,
              ratio: current-proposed-ratio,
              user-tracking-address: tracking-address,
            } { computed: true }
            )
            (if (< user-ratio current-proposed-ratio)
              (begin
                (print {
                  user-address: address,
                  user-ratio: user-ratio,
                  action: "below",
                  user-amount: sbtc-user-amount,
                })
                (map-set proposed-ratio {
                  cycle-id: current-cycle-id,
                  user: tx-sender,
                }
                  (merge proposed-ratio-map-v2 { sbtc-below: (+ sbtc-below sbtc-user-amount) })
                )
              )
              (if (is-eq user-ratio current-proposed-ratio)
                (begin
                  (print {
                    user-address: address,
                    user-ratio: user-ratio,
                    action: "equal",
                    user-amount: sbtc-user-amount,
                  })
                  (map-set proposed-ratio {
                    cycle-id: current-cycle-id,
                    user: tx-sender,
                  }
                    (merge proposed-ratio-map-v2 { sbtc-equal: (+ sbtc-equal sbtc-user-amount) })
                  )
                )
                (begin
                  (print {
                    user-address: address,
                    user-ratio: user-ratio,
                    action: "above",
                    user-amount: sbtc-user-amount,
                  })
                  (map-set proposed-ratio {
                    cycle-id: current-cycle-id,
                    user: tx-sender,
                  }
                    (merge proposed-ratio-map-v2 { sbtc-above: (+ sbtc-above sbtc-user-amount) })
                  )
                )
              )
            )
            u0
          )
        )
      )
    )
  )
)

;; Update the percentage threshold for sBTC above the proposed ratio (admin only)
(define-public (set-max-percentage-above-ratio (new-max-percentage-above-ratio uint))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set max-percentage-above-ratio new-max-percentage-above-ratio))
  )
)

;; Validate the proposed golden ratio based on participant distribution
(define-public (validate-ratio)
  (let (
      (proposed-ratio-map (unwrap!
        (map-get? proposed-ratio {
          cycle-id: (var-get cycle-id),
          user: tx-sender,
        })
        ERR_RATIO_NOT_PROPOSED
      ))
      (golden-ratio (get golden-ratio proposed-ratio-map))
      (participants-count (get participants-counted proposed-ratio-map))
      (sbtc-below (get sbtc-below proposed-ratio-map))
      (sbtc-above (get sbtc-above proposed-ratio-map))
      (sbtc-equal (get sbtc-equal proposed-ratio-map))
      (percentage-top-limit-ratio (/
        (* (var-get max-percentage-above-ratio)
          (var-get current-cycle-total-sbtc)
        )
        PRECISION_PERCENTAGE_RATIO
      ))
      (above-condition-respected (<= (* u100 sbtc-above) percentage-top-limit-ratio))
      (above-and-equal-condition-respected (>= (* u100 (+ sbtc-above sbtc-equal)) percentage-top-limit-ratio))
      (total-stx (var-get current-cycle-total-stx))
      (all-zero-stx (is-eq total-stx u0))
    )
    (print {
      sbtc-above: sbtc-above,
      sbtc-below: sbtc-below,
      sbtc-equal: sbtc-equal,
      sbtc-total: (var-get current-cycle-total-sbtc),
    })
    (asserts!
      (is-none (map-get? ratio-used { cycle-id: (var-get cycle-id) }))
      ERR_ALREADY_VALIDATED_RATIO
    )
    (asserts!
      (is-eq participants-count
        (var-get current-cycle-participants-count)
      )
      ERR_COMPUTE_RATIO_FOR_ALL_PARTICIPANTS_FIRST
    )

    ;; Note: Ratio of 0 is allowed (when all sBTC holders have no STX)
    ;; Division by zero is prevented in calculate functions by using max(D, MIN_GOLDEN_RATIO)
    ;; If no STX stacked anywhere, enforce D=1.0 (RATIO_PRECISION_HELPER_VALUE = 10^8)
    ;; This ensures baseline BTC-proportional distribution when no one stacks STX
    (asserts!
      (or (not all-zero-stx) (is-eq golden-ratio RATIO_PRECISION_HELPER_VALUE))
      ERR_INVALID_RATIO_FOR_ZERO_STX
    )

    ;; Golden ratio validation: ensures the proposed ratio represents a meaningful convergence point (5% of the sBTC enrolled)
    ;; 1. Ratio not too low: sbtc-above <= max% (not too many outliers above)
    ;; 2. Ratio not too high: (sbtc-above + sbtc-equal) >= max% (enough participants at/above)
    (if (not all-zero-stx)
      (begin
        (asserts! above-condition-respected ERR_RATIO_TOO_LOW)
        (asserts! above-and-equal-condition-respected
          ERR_RATIO_TOO_HIGH
        )
        false
      )
      false
    )

    (var-set is-ratio-validated true)
    (map-set ratio-used { cycle-id: (var-get cycle-id) } { used-ratio: golden-ratio })
    (var-set last-operation-done u3)
    ;; ratio-validated
    (ok true)
  )
)

;; Get ratio validation data for the current cycle
(define-read-only (get-ratio-data)
  (let ((proposed-ratio-map (unwrap!
      (map-get? proposed-ratio {
        cycle-id: (var-get cycle-id),
        user: tx-sender,
      })
      ERR_RATIO_NOT_PROPOSED
    )))
    (ok {
      sbtc-total-totals: (var-get current-cycle-total-sbtc),
      nr-snapshots: (var-get snapshots-per-cycle),
      sbtc-below: (get sbtc-below proposed-ratio-map),
      sbtc-above: (get sbtc-above proposed-ratio-map),
    })
  )
)

;; ===================================
;; WEIGHT COMPUTATION FUNCTIONS
;; ===================================

;; Calculate weights for all participants using the dual stacking formula
;; Must be called after validate-ratio and before set-is-distribution-enabled
(define-public (calculate-participant-weights (principals (list 900 principal)))
  (let (
      (stx-id-header-hash (unwrap!
        (get-stacks-block-info? id-header-hash
          (var-get current-cycle-stacks-block-height)
        )
        ERR_STX_BLOCK_IN_FUTURE
      ))
      (cycle-id-current (var-get cycle-id))
      (golden-ratio-data (unwrap! (map-get? ratio-used { cycle-id: cycle-id-current })
        ERR_RATIOS_NOT_CONCLUDED
      ))
      (D-raw (get used-ratio golden-ratio-data)) ;; This is the validated 95th percentile ratio
      ;; Apply minimum to prevent division by zero when all sBTC holders have 0 STX
      (D (if (> D-raw u0)
        D-raw
        MIN_GOLDEN_RATIO
      ))
    )
    (asserts! (var-get is-ratio-validated) ERR_RATIOS_NOT_CONCLUDED)
    (var-set snapshot-block-hash stx-id-header-hash)
    (let ((result (fold calculate-participant-weight principals {
        D: D,
        total: u0,
      })))
      (var-set total-weights-sum
        (+ (var-get total-weights-sum) (get total result))
      )
      (ok result)
    )
  )
)

;; Calculate weight for a single user and accumulate to total
(define-private (calculate-participant-weight
    (address principal)
    (acc {
      D: uint,
      total: uint,
    })
  )
  (let (
      (cycle-id-current (var-get cycle-id))
      (participant-state (unwrap-panic (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash
          (var-get current-cycle-stacks-block-height)
        ))
        (map-get? participants { address: address })
      )))
      (stacking-address (get stacking-address participant-state))
      (tracking-address (get tracking-address participant-state))
      (stacking-state (unwrap-panic (map-get? stacking-holding {
        stacking-address: stacking-address,
        cycle-id: cycle-id-current,
      })))
      (tracking-state (unwrap-panic (map-get? tracking-holding {
        tracking-address: tracking-address,
        cycle-id: cycle-id-current,
      })))
      (Si (get amount stacking-state)) ;; STX stacked by user
      (Bi (get amount tracking-state)) ;; sBTC held by user
      (M (var-get yield-boost-multiplier)) ;; Multiplier (default 9 for 10x max)
      (D (get D acc))
    )
    (if ;; already computed weight for this enrolled participant
      (is-some (map-get? participant-weight-tracked {
        cycle-id: cycle-id-current,
        enrolled-address: address,
      }))
      acc
      (if (is-some (map-get? participant-weights {
          cycle-id: cycle-id-current,
          tracking-address: tracking-address,
        }))
        (begin
          (var-set weights-computed-count
            (+ (var-get weights-computed-count) u1)
          )
          (print {
            cycle-id: cycle-id-current,
            enrolled-address: address,
            tracking-address: tracking-address,
            Bi: u0,
            weight: u0,
            function-name: "compute-weight",
          })
          acc
        )
        (if (is-eq Bi u0)
          ;; User has no sBTC, just set its map value and increase count
          (begin
            (map-set participant-weights {
              cycle-id: cycle-id-current,
              tracking-address: tracking-address,
            } { weight: u0 }
            )
            (map-set participant-weight-tracked {
              cycle-id: cycle-id-current,
              enrolled-address: address,
            } { computed: true }
            )
            (var-set weights-computed-count
              (+ (var-get weights-computed-count) u1)
            )
            (print {
              cycle-id: cycle-id-current,
              enrolled-address: address,
              tracking-address: tracking-address,
              Bi: u0,
              weight: u0,
              function-name: "compute-weight",
            })
            acc
          )
          (let (
              ;; Check if this tracking address is whitelisted for max boost
              (is-whitelisted (is-some (map-get? whitelisted-defi-tracking-addresses { address: tracking-address })))
              ;; Calculate di = Si/Bi (scaled by 10^8)
              (di (/ (* Si RATIO_PRECISION_HELPER_VALUE) Bi))
              ;; Calculate ri = min(di/D, 1) (scaled by 10^8)
              ;; If whitelisted, use ri = 1.0 for maximum boost
              ;; Note: D should already be >= MIN_GOLDEN_RATIO from calculate-participant-weights
              (ri (if is-whitelisted
                RATIO_PRECISION_HELPER_VALUE
                (if (< D MIN_GOLDEN_RATIO)
                  u0
                  (if (> di D)
                    RATIO_PRECISION_HELPER_VALUE
                    (/ (* di RATIO_PRECISION_HELPER_VALUE) D)
                  )
                )
              ))
              ;; Calculate sqrt(ri) using integer square root
              (sqrt-ri (sqrti ri))
              ;; Calculate wi = Bi * (1 + M * sqrt-ri)
              ;; wi = Bi * (10^8 + M * sqrt-ri * 10^4) / 10^8 / snapshots-per-cycle
              (weight (/
                (/
                  (* Bi
                    (+ RATIO_PRECISION_HELPER_VALUE
                      (* M sqrt-ri SQRT_RATIO_PRECISION_HELPER_VALUE)
                    ))
                  RATIO_PRECISION_HELPER_VALUE
                )
                (var-get snapshots-per-cycle)
              ))
            )
            ;; Store the weight for this tracking address
            (map-set participant-weights {
              cycle-id: cycle-id-current,
              tracking-address: tracking-address,
            } { weight: weight }
            )
            (map-set participant-weight-tracked {
              cycle-id: cycle-id-current,
              enrolled-address: address,
            } { computed: true }
            )
            (var-set weights-computed-count
              (+ (var-get weights-computed-count) u1)
            )
            (print {
              cycle-id: cycle-id-current,
              enrolled-address: address,
              tracking-address: tracking-address,
              Bi: Bi,
              Si: Si,
              di: di,
              D: D,
              ri: ri,
              sqrt-ri: sqrt-ri,
              weight: weight,
              is-whitelisted: is-whitelisted,
              function-name: "compute-weight",
            })
            ;; Accumulate total weight
            {
              D: D,
              total: (+ (get total acc) weight),
            }
          )
        )
      )
    )
  )
)

;; Finalize weight computation - stores the total
(define-public (finalize-weight-computation)
  (let ((cycle-id-current (var-get cycle-id)))
    (asserts! (var-get is-ratio-validated) ERR_RATIOS_NOT_CONCLUDED)
    (asserts! (not (var-get are-weights-computed))
      ERR_WEIGHTS_ALREADY_COMPUTED
    )
    (asserts!
      (is-eq (var-get weights-computed-count)
        (var-get current-cycle-participants-count)
      )
      ERR_NOT_ALL_WEIGHTS_COMPUTED
    )
    ;; Note: total-weights-sum should be set by summing during compute calls
    ;; This is a checkpoint to mark weights as computed
    (var-set are-weights-computed true)
    (print {
      cycle-id: cycle-id-current,
      total-weights-sum: (var-get total-weights-sum),
      function-name: "finalize-weights",
    })
    (var-set last-operation-done u4)
    ;; finalize-weight-computation
    (ok true)
  )
)

(define-read-only (get-weight-computation-status)
  {
    are-weights-computed: (var-get are-weights-computed),
    total-weights-sum: (var-get total-weights-sum),
    cycle-id: (var-get cycle-id),
  }
)

(define-read-only (get-participant-weight
    (cycle uint)
    (tracking-addr principal)
  )
  (map-get? participant-weights {
    cycle-id: cycle,
    tracking-address: tracking-addr,
  })
)

;; ===================================
;; REWARD DISTRIBUTION FUNCTIONS
;; ===================================

;; Enable reward distribution after validating cycle completion
(define-public (set-is-distribution-enabled)
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (not (var-get is-distribution-enabled))
      ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED
    )
    (asserts! (var-get are-weights-computed) ERR_WEIGHTS_NOT_COMPUTED)
    (let (
        (pool-rewards (at-block
          (unwrap-panic (get-stacks-block-info? id-header-hash
            (var-get current-snapshot-stacks-block-height)
          ))
          (unwrap-panic (contract-call?
            'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
            get-balance-available (as-contract contract-caller)
          ))
        ))
        ;; This is the real value
        (max-cap-rewards (/ (* (cycle-percentage-rate) (var-get total-weights-sum))
          (+ (var-get yield-boost-multiplier) u1)
        ))
        (local-rewards-to-distribute (if (< (* SCALING_FACTOR pool-rewards) max-cap-rewards)
          (* SCALING_FACTOR pool-rewards)
          max-cap-rewards
        ))
      )
      (var-set rewards-to-distribute local-rewards-to-distribute)
      (var-set last-operation-done u5)
      ;; set-can-distribute
      (ok (var-set is-distribution-enabled true))
    )
  )
)

;; Distribute rewards to a list of participants
(define-public (distribute-rewards (principals (list 900 principal)))
  (let ((stx-id-header-hash (unwrap!
      (get-stacks-block-info? id-header-hash
        (var-get current-cycle-stacks-block-height)
      )
      ERR_STX_BLOCK_IN_FUTURE
    )))
    (var-set snapshot-block-hash stx-id-header-hash)
    (asserts! (var-get is-distribution-enabled)
      ERR_CANNOT_DISTRIBUTE_REWARDS
    )
    (if (is-eq (var-get current-cycle-total-sbtc) u0)
      (begin
        (var-set participants-rewarded-count
          (var-get current-cycle-participants-count)
        )
        (ok (list))
      )
      (ok (map distribute-reward-user principals))
    )
  )
)

;; Distribute reward to a single user based on their computed weight
;; Note: Multiple enrolled addresses can share the same tracking/stacking/rewarded address
;; Rewards are aggregated and sent once per unique tracking-address to avoid duplicates
(define-private (distribute-reward-user (user principal))
  (let (
      (cycle-id-current (var-get cycle-id))
      (holding-state (unwrap!
        (map-get? participant-holding {
          address: user,
          cycle-id: cycle-id-current,
        })
        ERR_NOT_ENROLLED
      ))
      (participant-state (unwrap-panic (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash
          (var-get current-cycle-stacks-block-height)
        ))
        (map-get? participants { address: user })
      )))
      (stacking-address (get stacking-address participant-state))
      (stacking-state (unwrap!
        (map-get? stacking-holding {
          stacking-address: stacking-address,
          cycle-id: cycle-id-current,
        })
        ERR_NOT_ENROLLED
      ))
      (tracking-address (get tracking-address participant-state))
      (tracking-state (unwrap!
        (map-get? tracking-holding {
          tracking-address: tracking-address,
          cycle-id: cycle-id-current,
        })
        ERR_NOT_ENROLLED
      ))
      (rewarded-address (get rewarded-address participant-state))
      (already-rewarded-amount (default-to u0
        (get amount
          (map-get? rewards-holding {
            rewarded-address: rewarded-address,
            cycle-id: cycle-id-current,
          })
        )))
      (weight-data (unwrap!
        (map-get? participant-weights {
          cycle-id: cycle-id-current,
          tracking-address: tracking-address,
        })
        ERR_WEIGHTS_NOT_COMPUTED
      ))
      (user-weight (get weight weight-data))
      (total-weight (var-get total-weights-sum))
      (stx-user-amount (get amount stacking-state))
      (sbtc-user-amount (get amount tracking-state))
      (user-theoretical-ratio (if (is-eq sbtc-user-amount u0)
        u0
        (/ (* stx-user-amount RATIO_PRECISION_HELPER_VALUE)
          sbtc-user-amount
        )
      ))
      (golden-ratio (unwrap!
        (get used-ratio
          (map-get? ratio-used { cycle-id: cycle-id-current })
        )
        ERR_RATIOS_NOT_CONCLUDED
      ))
      (is-whitelisted (get-is-whitelisted-defi tracking-address))
      (user-ratio (if (or is-whitelisted (> user-theoretical-ratio golden-ratio))
        golden-ratio
        user-theoretical-ratio
      ))
      (reward-amount (if (is-eq total-weight u0)
        u0
        (/ (* user-weight (var-get rewards-to-distribute))
          (* total-weight SCALING_FACTOR)
        )
      ))
    )
    (if (get rewarded holding-state)
      ERR_ALREADY_REWARDED
      (begin
        (var-set participants-rewarded-count
          (+ (var-get participants-rewarded-count) u1)
        )
        (map-set participant-holding {
          address: user,
          cycle-id: cycle-id-current,
        }
          (merge holding-state {
            rewarded: true,
            reward-amount: reward-amount,
          })
        )
        ;; if the tracking address linked to the current holding address was already rewarded 
        ;; -> consider current holding address as rewarded as well
        (if (not (get rewarded tracking-state)) ;; is false and it wasn't already rewarded
          (begin
            (map-set rewards-holding {
              rewarded-address: rewarded-address,
              cycle-id: cycle-id-current,
            } { amount: (+ already-rewarded-amount reward-amount) }
            )
            (map-set tracking-holding {
              tracking-address: tracking-address,
              cycle-id: cycle-id-current,
            }
              (merge tracking-state { rewarded: true })
            )
            (print {
              cycle-id: cycle-id-current,
              enrolled-address: user,
              reward-address: rewarded-address,
              stacking-address: stacking-address,
              tracking-address: tracking-address,
              amount: reward-amount,
              weight: user-weight,
              ratio: user-ratio,
              function-name: "distribute-rewards",
            })
            (if (> reward-amount u0)
              (try! (as-contract (contract-call?
                'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                transfer reward-amount tx-sender rewarded-address
                none
              )))
              false
            )
          )
          (begin
            (print {
              cycle-id: cycle-id-current,
              enrolled-address: user,
              reward-address: rewarded-address,
              stacking-address: stacking-address,
              tracking-address: tracking-address,
              amount: u0,
              weight: u0,
              ratio: u0,
              function-name: "distribute-rewards",
            })
            false ;; does nothing
          )
        )
        (ok true)
      )
    )
  )
)

;; Finalize reward distribution for the current cycle
(define-public (finalize-reward-distribution)
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (is-eq (var-get current-cycle-participants-count)
        (var-get participants-rewarded-count)
      )
      ERR_NOT_REWARDED_ALL
    )
    (asserts! (var-get is-distribution-enabled) ERR_CANNOT_FINALIZE)
    (asserts!
      (is-none (map-get? distribution-finalized-stx-block-height-when-called { cycle-id: (var-get cycle-id) }))
      ERR_ALREADY_FINALIZED
    )

    (print {
      bitcoin-block-height: burn-block-height,
      cycle-id: (var-get cycle-id),
      function-name: "finalize-reward-distribution",
    })
    (var-set last-operation-done u6) ;; finalized
    ;; Used by DeFi apps to call their rewards distribution afterward it is finalized here
    (ok (map-set distribution-finalized-stx-block-height-when-called { cycle-id: (var-get cycle-id) } { stx-block-height: stacks-block-height }))
  )
)

;; ===================================
;; CYCLE MANAGEMENT FUNCTIONS
;; ===================================

;; Advance to the next cycle
(define-public (advance-to-next-cycle (stx-block-height uint))
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (>= burn-block-height (var-get next-cycle-bitcoin-block-height))
      ERR_NOT_NEW_CYCLE_YET
    )
    (asserts!
      (is-eq (var-get current-cycle-participants-count)
        (var-get participants-rewarded-count)
      )
      ERR_NOT_REWARDED_ALL
    )
    (asserts!
      (is-some (map-get? distribution-finalized-stx-block-height-when-called { cycle-id: (var-get cycle-id) }))
      ERR_REWARDS_NOT_SENT_YET
    )
    (asserts!
      (unwrap-panic (contract-call? .bitcoin-block-buffer
        validate-stx-block-brackets-btc-block stx-block-height
        (var-get next-cycle-bitcoin-block-height)
      ))
      ERR_STX_BLOCK_NOT_MATCHING
    )

    (var-set current-cycle-bitcoin-block-height
      (+ (var-get current-cycle-bitcoin-block-height)
        (* (var-get blocks-per-snapshot) (var-get snapshots-per-cycle))
      ))
    (var-set cycle-id (+ (var-get cycle-id) u1))
    (reset-state-for-cycle stx-block-height)
    (var-set next-cycle-bitcoin-block-height
      (+ (var-get current-cycle-bitcoin-block-height)
        (* (var-get blocks-per-snapshot) (var-get snapshots-per-cycle))
      ))
    (update-snapshot-for-new-cycle stx-block-height)

    (ok (map-set cycle-snapshot-to-stx-block-height {
      cycle-id: (var-get cycle-id),
      snapshot-id: (var-get current-snapshot-index),
    } {
      stx-block-height: stx-block-height,
      bitcoin-block-height-stored: (var-get current-cycle-bitcoin-block-height),
    }))
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS - Cycle Info
;; ===================================

(define-read-only (get-current-cycle-id)
  (var-get cycle-id)
)

(define-read-only (cycle-data)
  {
    cycle-id: (var-get cycle-id),
    current-cycle-bitcoin-block-height: (var-get current-cycle-bitcoin-block-height),
    next-cycle-bitcoin-block-height: (var-get next-cycle-bitcoin-block-height),
    current-cycle-stacks-block-height: (var-get current-cycle-stacks-block-height),
    participants-count: (var-get current-cycle-participants-count),
    snapshots-per-cycle: (var-get snapshots-per-cycle),
    blocks-per-snapshot: (var-get blocks-per-snapshot),
    current-snapshot-index: (var-get current-snapshot-index),
  }
)

(define-read-only (get-cycle-current-state)
  {
    cycle-id: (var-get cycle-id),
    first-bitcoin-block: (var-get current-cycle-bitcoin-block-height),
    last-bitcoin-block: (- (var-get next-cycle-bitcoin-block-height) u1),
  }
)

(define-read-only (current-overview-data)
  {
    cycle-id: (var-get cycle-id),
    snapshot-index: (var-get current-snapshot-index),
    snapshots-per-cycle: (var-get snapshots-per-cycle),
  }
)

(define-read-only (get-yield-cycle-data (cycle uint))
  (map-get? yield-cycles-data { cycle-id: cycle })
)

;; ===================================
;; READ-ONLY FUNCTIONS - Snapshot Info
;; ===================================

(define-read-only (snapshot-data)
  {
    current-snapshot-bitcoin-block-height: (var-get current-snapshot-bitcoin-block-height),
    current-snapshot-stacks-block-height: (var-get current-snapshot-stacks-block-height),
    current-snapshot-count: (var-get current-snapshot-count),
    current-snapshot-total-sbtc: (var-get current-snapshot-total-sbtc),
    current-snapshot-total-stx: (var-get current-snapshot-total-stx),
    current-snapshot-index: (var-get current-snapshot-index),
    blocks-per-snapshot: (var-get blocks-per-snapshot),
  }
)

(define-read-only (get-stacks-block-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (get stx-block-height
    (map-get? cycle-snapshot-to-stx-block-height {
      cycle-id: checked-cycle-id,
      snapshot-id: checked-snapshot-id,
    })
  )
)

(define-read-only (get-bitcoin-block-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (get bitcoin-block-height-stored
    (map-get? cycle-snapshot-to-stx-block-height {
      cycle-id: checked-cycle-id,
      snapshot-id: checked-snapshot-id,
    })
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS - Reward Info
;; ===================================

(define-read-only (get-reward-distribution-status)
  {
    participants-rewarded-count: (var-get participants-rewarded-count),
    is-distribution-enabled: (var-get is-distribution-enabled),
  }
)

(define-read-only (is-distribution-ready)
  (var-get is-distribution-enabled)
)

(define-read-only (reward-amount-for-cycle-and-address
    (wanted-cycle-id uint)
    (address principal)
  )
  (get reward-amount
    (map-get? participant-holding {
      cycle-id: wanted-cycle-id,
      address: address,
    })
  )
)

(define-read-only (reward-amount-for-cycle-and-reward-address
    (wanted-cycle-id uint)
    (reward-address principal)
  )
  (get amount
    (map-get? rewards-holding {
      cycle-id: wanted-cycle-id,
      rewarded-address: reward-address,
    })
  )
)

(define-read-only (is-distribution-finalized-for-current-cycle)
  (is-some (map-get? distribution-finalized-stx-block-height-when-called { cycle-id: (var-get cycle-id) }))
)

(define-read-only (get-distribution-finalized-at-height (wanted-cycle-id uint))
  (map-get? distribution-finalized-stx-block-height-when-called { cycle-id: wanted-cycle-id })
)

;; ===================================
;; READ-ONLY FUNCTIONS - State & Config
;; ===================================

(define-read-only (get-last-operation-state)
  (var-get last-operation-done)
)

(define-read-only (get-admin)
  (var-get admin)
)

(define-read-only (get-is-contract-active)
  (var-get is-contract-active)
)

(define-read-only (get-current-bitcoin-block-height)
  burn-block-height
)

(define-read-only (get-minimum-enrollment-amount)
  (var-get min-sbtc-hold-required-for-enrollment)
)

;; If SC not initialized, returns bitcoin-block block height for it
;; else returns the bitcoin-block block height for next snapshot/cycle
(define-read-only (get-next-action-bitcoin-height)
  (if (var-get is-contract-active)
    (+ (var-get current-snapshot-bitcoin-block-height)
      (var-get blocks-per-snapshot)
    )
    (var-get current-cycle-bitcoin-block-height)
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS - Participant Info
;; ===================================

(define-read-only (is-enrolled-in-next-cycle (address principal))
  (is-some (map-get? participants { address: address }))
)

(define-read-only (is-enrolled-this-cycle (address principal))
  (is-some (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash
      (var-get current-cycle-stacks-block-height)
    ))
    (map-get? participants { address: address })
  ))
)

(define-read-only (get-is-blacklisted (address principal))
  (is-some (map-get? blacklist { address: address }))
)

(define-read-only (get-is-blacklisted-list (addresses (list 900 principal)))
  (map is-blacklisted addresses)
)

(define-read-only (get-is-whitelisted-defi (address principal))
  (is-some (map-get? whitelisted-defi-tracking-addresses { address: address }))
)

;; Helper for blacklist checking
(define-private (is-blacklisted (address principal))
  (is-some (map-get? blacklist { address: address }))
)

(define-read-only (get-latest-reward-address (address principal))
  (get rewarded-address (map-get? participants { address: address }))
)

(define-read-only (get-participant-cycle-info
    (address principal)
    (cycle uint)
  )
  (let (
      (participant-info (at-block
        (unwrap-panic (get-stacks-block-info? id-header-hash
          (unwrap!
            (get start-stx-block-height
              (map-get? yield-cycles-data { cycle-id: cycle })
            )
            ERR_CYCLE_IN_FUTURE
          )))
        (map-get? participants { address: address })
      ))
      (tracking-address (unwrap! (get tracking-address participant-info) ERR_NOT_ENROLLED))
      (stacking-address (unwrap! (get stacking-address participant-info) ERR_NOT_ENROLLED))
    )
    (ok {
      participant-data: participant-info,
      holding-data: (map-get? participant-holding {
        cycle-id: cycle,
        address: address,
      }),
      tracking-data: (map-get? tracking-holding {
        cycle-id: cycle,
        tracking-address: tracking-address,
      }),
      stacking-data: (map-get? stacking-holding {
        cycle-id: cycle,
        stacking-address: stacking-address,
      }),
    })
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS - APR Calculations
;; ===================================

;; Number of cycles per year - average number of blocks in a year / number of
;; blocks in a cycle. When blocks-per-snapshot or next-snapshots-per-cycle are
;; updated, this value is recalculated.
(define-read-only (nr-cycles-year)
  (/ (var-get bitcoin-blocks-per-year)
    (* (var-get blocks-per-snapshot) (var-get snapshots-per-cycle))
  )
)

;; Cycle percentage rate scaled by 10^8. This represents the maximum
;; percentage of the sBTC yield contributors are ready to give away as rewards
;; in a cycle.
;; CPR = APR / nr-cycles-per-year
;; When APR or nr-cycles-per-year are updated, this value is recalculated.
(define-read-only (cycle-percentage-rate)
  (/ (var-get APR) (nr-cycles-year))
)

;; ===================================
;; READ-ONLY FUNCTIONS - Validation
;; ===================================

(define-read-only (get-amount-stx-stacked (address principal))
  (get locked (stx-account address))
)

(define-read-only (get-amount-stx-stacked-at-block-height
    (address principal)
    (stx-block-height uint)
  )
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
    (get locked (stx-account address))
  )
)

(define-read-only (get-amount-stacked-at-block-height-mainnet
    (address principal)
    (stx-block-height uint)
  )
  (if (var-get is-liquid-stacking-enabled)
    (+
      (contract-call? .liquid-stacking
        get-user-liquid-stx-stacked-at-block-height address
        stx-block-height
      )
      (get-amount-stx-stacked-at-block-height address stx-block-height)
    )
    (get-amount-stx-stacked-at-block-height address stx-block-height)
  )
)

;; Get total amount of STX stacked (native + liquid stacking if enabled) at given block-height
(define-read-only (get-amount-stacked-at-block-height
    (address principal)
    (stx-block-height uint)
  )
  (get-amount-stacked-at-block-height-mainnet address stx-block-height)
)

(define-read-only (get-amount-stacked-now (address principal))
  (get-amount-stacked-at-block-height address
    (- stacks-block-height u1)
  )
)

(define-read-only (get-apr-data)
  {
    MULTIPLIER: (+ (var-get yield-boost-multiplier) u1),
    MAX_APR: (var-get APR),
    MIN_APR: (/ (var-get APR) (+ (var-get yield-boost-multiplier) u1)),
  }
)
