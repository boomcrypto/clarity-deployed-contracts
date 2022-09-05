
;; Staking ERRORS 4330~4349
(define-constant ERR_STAKING_NOT_AVAILABLE u5330)  
(define-constant ERR_CANNOT_STAKE u5331)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u5332)
(define-constant ERR_NOTHING_TO_REDEEM u5333)
(define-constant ERR_INVALID_ROUTER u5334)
(define-constant ERR_TRANSFER_FAIL u5335)
(define-constant ERR_STAKE_NOT_ENDED u5336)
(define-constant ERR_STAKE_ENDED u5337)
(define-constant ERR_UNSTAKELIST_FULL u5338)
(define-constant ERR_NOT_AUTHORIZED u5339)
(define-constant ERR_COOLDOWN_ALREADY_SET u5340)
(define-constant ERR_COOLDOWN_NOT_SET u5341)
(define-constant ERR_COOLDOWN_NOT_REACHED u5342)
(define-constant ERR_BLOCK_HEIGHT_NOT_REACHED u5343)
(define-constant ERR_NOTHING_TO_RETURN u5344)
(define-constant ERR_NOT_STARTED u5345)
(define-constant ERR_STARTED u5346)
(define-constant ERR_PERMISSION_DENIED u5347)

(define-constant FIRST_STAKING_BLOCK u38083) 
(define-constant REWARD_CYCLE_LENGTH u4320)          ;; how long a reward cycle is (144 * 30) u4320
(define-constant COOLDOWN_CYCLE u1008)   
(define-constant MAX_REWARD_CYCLES u36)             
(define-constant REWARD_CYCLE_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35))

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


(define-map StakerInfo
  principal
  {
    staked_list: (list 100 uint),
    amountReturn: uint
  }
)

(define-read-only (get-staker (user principal))
  (map-get? StakerInfo user)
)

(define-read-only (get-staker-or-default (user principal))
  (default-to 
    {
      staked_list: (list ),
      amountReturn: u0
    }
    (map-get? StakerInfo user))
)

(define-public (set-staker (user principal) (data     {
    staked_list: (list 100 uint),
    amountReturn: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (ok (map-set StakerInfo user data))
  )  
)

(define-map StakingStatsAtCycle
  uint
  {
    amountlBTC: uint,
    amountReturn: uint,
    amountRewardBase: uint
  }
)

(define-read-only (get-staking-stats-at-cycle (rewardCycle uint))
  (map-get? StakingStatsAtCycle rewardCycle)
)

(define-read-only (get-staking-stats-at-cycle-or-default (rewardCycle uint))
  (default-to { amountlBTC: u0, amountReturn: u0, amountRewardBase: (var-get BASIC_CYCLE_MINING_REWARD)}
    (map-get? StakingStatsAtCycle rewardCycle))
)

(define-public (set-staking-stats-at-cycle (rewardCycle uint) (data   {
    amountlBTC: uint,
    amountReturn: uint,
    amountRewardBase: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (ok (map-set StakingStatsAtCycle rewardCycle data))
  )  
)

(define-map StakerAtCycle
  {
    rewardCycle: uint,
    user: principal
  }
  {
    amountlBTC: uint,
    amountReturn: uint
  }
)

(define-read-only (get-staker-at-cycle (rewardCycle uint) (user principal))
  (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user })
)

(define-read-only (get-staker-at-cycle-or-default (rewardCycle uint) (user principal))
  (default-to { amountlBTC: u0, amountReturn: u0 }
    (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user }))
)

(define-public (set-staker-at-cycle (index   {
    rewardCycle: uint,
    user: principal
  }) (data     {
    amountlBTC: uint,
    amountReturn: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (ok (map-set StakerAtCycle index data))
  )  
)

(define-public (delete-staker-at-cycle (index   {
    rewardCycle: uint,
    user: principal
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (ok (map-delete StakerAtCycle index))
  )  
)


(define-non-fungible-token lBTC-staking-vault uint)
(define-data-var nft-id uint u0)

(define-map StakingVault
  uint ;; nft id
  {
    cooldownBlock: uint,
    reclaimBlock: uint,
    amountReturn: uint
  }
)


(define-read-only (get-staking-vault (vault-id uint))
  (map-get? StakingVault vault-id)
)

(define-read-only (get-staking-vault-or-default (vault-id uint))
  (default-to   {
    cooldownBlock: u0,
    reclaimBlock: u0,
    amountReturn: u0
  }
    (map-get? StakingVault vault-id))
)

(define-read-only (get-staking-vault-owner (vault-id uint))
  (nft-get-owner? lBTC-staking-vault vault-id)
)

(define-public (set-staking-vault (index uint) (data     {
    cooldownBlock: uint,
    reclaimBlock: uint,
    amountReturn: uint
  }))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (ok (map-set StakingVault index data))
  )  
)

(define-public (delete-staking-vault (index uint))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (try! (nft-burn? lBTC-staking-vault index tx-sender))
    (ok (map-delete StakingVault index))
  )
)


(define-public (transfer-reward (user principal) (amount uint))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (try! (as-contract (contract-call? .stsw-token-v4a transfer amount tx-sender user none)))
    (ok true)
  )
)

(define-public (transfer-asset (user principal) (amount uint))
  (begin 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (try! (as-contract (contract-call? .lbtc-token-v1c transfer amount tx-sender user none)))
    (ok true)
  )
)

(define-public (add-new-nft-vault (data {
        cooldownBlock: uint,
        reclaimBlock: uint,
        amountReturn: uint
      }))
  (let
    (
      (next-id (+ (var-get nft-id) u1))
    ) 
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "lbtc-staking-manager"))) (err ERR_PERMISSION_DENIED))
    (var-set nft-id next-id)
    (try! (nft-mint? lBTC-staking-vault next-id tx-sender))
    (map-set StakingVault
      next-id
      data
    )
    (ok next-id)
  )  
)




(define-data-var is-started bool false)

(define-public (migrate-rounds (nft-id-new uint) (rounds (list 100 uint))) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (let (
        (contract-v2-amount (unwrap-panic (contract-call? .lbtc-token-v1c get-balance .stackswap-lbtc-staking-v2a)))
      )
      (if (> contract-v2-amount u0)
        (try! (contract-call? .lbtc-token-v1c revoke-for-dao contract-v2-amount .stackswap-lbtc-staking-v2a (as-contract tx-sender)))
        false
      )
    )
    (var-set is-started true)
    (var-set nft-id nft-id-new)
    (map migrate-contract-closure rounds)
    (ok true)
  )
)

(define-private (migrate-contract-closure (round uint))
  (let (
      (rewardCycleStats (contract-call? .stackswap-lbtc-staking-v2a get-staking-stats-at-cycle-or-default round))
    )
    (map-set StakingStatsAtCycle
      round
      rewardCycleStats
    )
  )
)



(define-public (migrate-user (user principal)) 
  (let (
      (user-data (contract-call? .stackswap-lbtc-staking-v2a get-staker user))
    )
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (match (get staked_list user-data) staked_list 
      (begin
        (map-set StakerInfo
          user
          {
            staked_list : staked_list,
            amountReturn: u0
          }
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
      (user-round-data (contract-call? .stackswap-lbtc-staking-v2a get-staker-at-cycle-or-default round user))
    )
    (map-set StakerAtCycle
      {
        rewardCycle: round,
        user: user,
      }
      {
        amountReturn: (get amountReturn user-round-data),
        amountlBTC: (get amountlBTC user-round-data)
      }
    )
    user
  )
)

(define-public (migrate-user-vaults (datas (list 100 {user: principal, vaultID: uint}))) 
  (begin 
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (map migrate-user-vault-closure datas)
    (ok true) 
  )
)


(define-private (migrate-user-vault-closure (data {user: principal, vaultID: uint})) 
  (let (
      (user-vault-data (contract-call? .stackswap-lbtc-staking-v2a get-staking-vault-or-default (get vaultID data)))
      (staker-info (get-staker-or-default (get user data)))
    )
    (map-set StakingVault
      (get vaultID data)
      user-vault-data
    )
    (map-set StakerInfo
      (get user data)
      {
        staked_list : (get staked_list staker-info),
        amountReturn: (+ (get amountReturn staker-info) (get amountReturn user-vault-data))
      }
    )
    (try! (nft-mint? lBTC-staking-vault (get vaultID data) (get user data)))
    (ok true)
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



