;; Staking ERRORS 4330~4349
(define-constant ERR_STAKING_NOT_AVAILABLE u4330)  
(define-constant ERR_CANNOT_STAKE u4331)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u4333)
(define-constant ERR_NOTHING_TO_REDEEM u4334)
(define-constant ERR_INVALID_ROUTER u4335)
(define-constant ERR_TRANSFER_FAIL u4338)
(define-constant ERR_STAKE_ENDED u4339)
(define-constant ERR_UNSTAKELIST_FULL u4340)
(define-constant ERR_NOT_AUTHORIZED u4341)
(define-constant ERR_STARTED u4342)


(define-constant FIRST_STAKING_BLOCK u38083) 
(define-constant REWARD_CYCLE_LENGTH u4320)          ;; how long a reward cycle is (144 * 30) u4320
(define-constant MAX_REWARD_CYCLES u36)             
(define-constant REWARD_CYCLE_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35))

(define-map StakerInfo
  principal
  (list 100 uint)
)

(define-read-only (get-staker (user principal))
  (map-get? StakerInfo user)
)

(define-read-only (get-staker-or-default (user principal))
  (default-to 
    (list )
    (map-get? StakerInfo user))
)

(define-public (set-staker (user principal) (data (list 100 uint)))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stsw-staking-manager"))) (err ERR_NOT_AUTHORIZED))
    (ok (map-set StakerInfo user data))
  )  
)

(define-map StakingStatsAtCycle
  uint
  {
    amountSTSW: uint,
    amountvSTSW: uint,
    amountRewardBase: uint
  }
)

(define-read-only (get-staking-stats-at-cycle (rewardCycle uint))
  (map-get? StakingStatsAtCycle rewardCycle)
)

(define-read-only (get-staking-stats-at-cycle-or-default (rewardCycle uint))
  (default-to { amountvSTSW: u0, amountSTSW: u0, amountRewardBase: (var-get BASIC_CYCLE_MINING_REWARD)}
    (map-get? StakingStatsAtCycle rewardCycle))
)

(define-public (set-staking-stats-at-cycle (rewardCycle uint) (data   {
    amountSTSW: uint,
    amountvSTSW: uint,
    amountRewardBase: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stsw-staking-manager"))) (err ERR_NOT_AUTHORIZED))
    (ok (map-set StakingStatsAtCycle rewardCycle data))
  )  
)

(define-map StakerAtCycle
  {
    rewardCycle: uint,
    user: principal,
  }
  {
    amountvSTSW: uint,
    amountSTSW: uint
  }
)

(define-read-only (get-staker-at-cycle (rewardCycle uint) (user principal))
  (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user })
)

(define-read-only (get-staker-at-cycle-or-default (rewardCycle uint) (user principal))
  (default-to { amountvSTSW: u0, amountSTSW: u0 }
    (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user }))
)

(define-public (set-staker-at-cycle (index   {
    rewardCycle: uint,
    user: principal
  }) (data     {
    amountvSTSW: uint,
    amountSTSW: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stsw-staking-manager"))) (err ERR_NOT_AUTHORIZED))
    (ok (map-set StakerAtCycle index data))
  )  
)

(define-public (delete-staker-at-cycle (index   {
    rewardCycle: uint,
    user: principal
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stsw-staking-manager"))) (err ERR_NOT_AUTHORIZED))
    (ok (map-delete StakerAtCycle index))
  )  
)

(define-read-only (get-reward-cycle (stacksHeight uint))
  (let
    (
      (firstStakingBlock FIRST_STAKING_BLOCK)
      (rcLen REWARD_CYCLE_LENGTH)
    )
    (if (>= stacksHeight firstStakingBlock)
      (some (/ (- stacksHeight firstStakingBlock) rcLen))
      none)
  )
)

(define-read-only (staking-active-at-cycle (rewardCycle uint))
  (is-some
    (get amountvSTSW (map-get? StakingStatsAtCycle rewardCycle))
  )
)

(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ FIRST_STAKING_BLOCK (* REWARD_CYCLE_LENGTH rewardCycle))
)


(define-data-var is-started bool false)

(define-public (migrate-rounds (nft-id-new uint) (rounds (list 100 uint))) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (var-set is-started true)
    (map migrate-contract-closure rounds)
    (ok true)
  )
)

(define-private (migrate-contract-closure (round uint))
  (let (
      (rewardCycleStats (contract-call? .stackswap-staking-v1l get-staking-stats-at-cycle-or-default round))
    )
    (map-set StakingStatsAtCycle
      round
      (merge 
        {amountRewardBase: (var-get BASIC_CYCLE_MINING_REWARD)}
        rewardCycleStats
      )
      
    )
  )
)

(define-public (migrate-user (user principal)) 
  (let (
      (user-data (contract-call? .stackswap-staking-v1l get-staker user))
    )
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (match user-data staked_list 
      (begin
        (map-set StakerInfo
          user
          staked_list
        )
        (fold migrate-user-closure staked_list user)
        (ok true)
      )
      (ok true)
    )
  )
)


(define-private (migrate-user-closure (round uint) (user principal))
  (let (
      (user-round-data (contract-call? .stackswap-staking-v1l get-staker-at-cycle-or-default round user))
    )
    (map-set StakerAtCycle
      {
        rewardCycle: round,
        user: user,
      }
      user-round-data
    )
    user
  )
)


(define-data-var BASIC_CYCLE_MINING_REWARD uint u1233792000000)


(define-public (set-mining-reward (amount uint)) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (var-set BASIC_CYCLE_MINING_REWARD amount)
    (let (
        (currentCycle (unwrap! (get-reward-cycle block-height) (err ERR_STAKING_NOT_AVAILABLE)))
      )
      (map set-mining-reward-closure (unwrap-panic (contract-call? .stackswap-list-helper-v1 cut-sized-list u36 currentCycle)))
    )
    (ok true)
  )
)


(define-private (set-mining-reward-closure (targetCycle uint))
  (let (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
    )
    (map-set StakingStatsAtCycle
      targetCycle
      (merge rewardCycleStats {
        amountRewardBase: (var-get BASIC_CYCLE_MINING_REWARD)
      })
    )
  )
)


(define-public (transfer-reward (user principal) (amount uint))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "stsw-staking-manager"))) (err ERR_NOT_AUTHORIZED))
    (try! (as-contract (contract-call? .stsw-token-v4a transfer amount tx-sender user none)))
    (ok true)
  )
)