
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

(define-constant FIRST_STAKING_BLOCK u38083) 
(define-constant REWARD_CYCLE_LENGTH u4320)          ;; how long a reward cycle is (144 * 30) u4320
(define-constant COOLDOWN_CYCLE u1008)   
(define-constant MAX_REWARD_CYCLES u36)             
(define-constant REWARD_CYCLE_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35))

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

(define-private (get-staker-or-default (user principal))
  (default-to 
    {
      staked_list: (list ),
      amountReturn: u0
    }
    (map-get? StakerInfo user))
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
    (get amountlBTC (map-get? StakingStatsAtCycle rewardCycle))
  )
)

(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ FIRST_STAKING_BLOCK (* REWARD_CYCLE_LENGTH rewardCycle))
)

(define-read-only (get-staking-reward-per-user (user principal) (targetCycle uint) )
  (get-entitled-staking-reward user targetCycle block-height)
)

(define-private (get-entitled-staking-reward (user principal) (targetCycle uint) (stacksHeight uint))
  (let
    (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user))
      (totalRewardThisCycle (get-staking-rewards-per-cycle-num targetCycle)) 
      (totalStakedThisCycle (get amountlBTC rewardCycleStats))
      (userStakedThisCycle (get amountlBTC stakerAtCycle))
    )
    (match (get-reward-cycle stacksHeight)
      currentCycle
      (if (or (<= currentCycle targetCycle) (is-eq u0 userStakedThisCycle))
        u0
        (/ (* totalRewardThisCycle userStakedThisCycle) totalStakedThisCycle)
      )
      u0
    )
  )
)

(define-constant POW_LIST (list u1000	u1059	u1122	u1189	u1260	u1335	u1414	u1498	u1587	u1682	u1782	u1888	u2000	u2119	u2245	u2378	u2520	u2670	u2828	u2997	u3175	u3364	u3564	u3775	u4000	u4238	u4490	u4757	u5040	u5339	u5657	u5993	u6350	u6727	u7127	u7551	u8000))

(define-read-only (get-amount (amount uint) (month uint))
  (/ (* amount (unwrap-panic (element-at POW_LIST month))) u1000)
)


(define-public (stake-tokens (amountTokens uint) (lockPeriod uint))
  (let
    (
      (user tx-sender)
      (startHeight block-height)
      (currentCycle (unwrap! (get-reward-cycle startHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (targetCycle (+ u1 currentCycle))
      (stake-result (get-amount amountTokens lockPeriod))
      (commitment {
        stakerId: user,
        amountReturn: amountTokens,
        amountlBTC: stake-result,
        first: targetCycle,
        last: (+ targetCycle lockPeriod)
      })
      (staker-info (get-staker-or-default user))
      (new-list (unwrap! (add-items-to-list (get staked_list staker-info) lockPeriod targetCycle) (err ERR_UNSTAKELIST_FULL)))
      (next-id (+ (var-get nft-id) u1))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES))
      (err ERR_CANNOT_STAKE))
    (asserts! (< targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STAKE))
    (unwrap! (contract-call? .lbtc-token-v1c transfer amountTokens user (as-contract tx-sender) none) (err ERR_TRANSFER_FAIL))
    (try! (nft-mint? lBTC-staking-vault next-id tx-sender))
    (var-set nft-id next-id)
    (map-set StakingVault
      next-id
      {
        cooldownBlock: (+ block-height (* lockPeriod REWARD_CYCLE_LENGTH)),
        reclaimBlock: u0,
        amountReturn: amountTokens
      }
    )
    (map-set StakerInfo
      user
      {
        staked_list : new-list,
        amountReturn: (+ amountTokens (get amountReturn staker-info))
      }
    )
    (match (fold stake-tokens-closure REWARD_CYCLE_INDEXES (ok commitment))
      okValue (ok true)
      errValue (err errValue)
    )
  )
)


(define-private (stake-tokens-closure (rewardCycleIdx uint)
  (commitmentResponse (response 
    {
      stakerId: principal,
      amountReturn: uint,
      amountlBTC: uint,
      first: uint,
      last: uint
    }
    uint
  )))

  (match commitmentResponse
    commitment 
    (let
      (
        (stakerId (get stakerId commitment))
        (amountReturn (get amountReturn commitment))
        (amountlBTC (get amountlBTC commitment))
        (firstCycle (get first commitment))
        (lastCycle (get last commitment))
        (targetCycle (+ firstCycle rewardCycleIdx))
      )
      (begin
        (if (and (>= targetCycle firstCycle) (< targetCycle lastCycle))
          (begin
            (if (is-eq targetCycle (- lastCycle u1))
              (set-tokens-staked stakerId targetCycle amountlBTC amountReturn)
              (set-tokens-staked stakerId targetCycle amountlBTC u0)
            )
            true
          )
          false
        )
        commitmentResponse
      )
    )
    errValue commitmentResponse
  )
)

(define-private (set-tokens-staked (user principal) (targetCycle uint) (amountStaked uint) (toReturn uint) )
  (let
    (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user))
    )
    (map-set StakingStatsAtCycle
      targetCycle
      {
        amountReturn: (+ toReturn (get amountReturn rewardCycleStats)),
        amountlBTC: (+ amountStaked (get amountlBTC rewardCycleStats)),
        amountRewardBase: (get amountRewardBase rewardCycleStats)
      }
    )
    (map-set StakerAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
      }
      {
        amountReturn: (+ toReturn (get amountReturn stakerAtCycle)),
        amountlBTC: (+ amountStaked (get amountlBTC stakerAtCycle))
      }
    )
  )
)

(define-public (claim-staking-reward (targetCycle uint))
 (let
    (
      (stacksHeight block-height)
      (user contract-caller)
      (currentCycle (unwrap! (get-reward-cycle stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (entitledReward (get-entitled-staking-reward user targetCycle stacksHeight))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user))
      (toReturn (get amountReturn stakerAtCycle))
      (staker-info (get-staker-or-default user))
      (new-list (delete-item-from-list (get staked_list staker-info) targetCycle))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledReward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))

    (map-delete StakerAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
      }
    )
    (map-set StakerInfo
      user
      {
        staked_list : new-list,
        amountReturn: (get amountReturn staker-info)
        ;; amountReturn: (- (get amountReturn staker-info) toReturn)
      }
    )
    (if (> entitledReward u0)
      (unwrap! (as-contract (contract-call? .stsw-token-v4a transfer entitledReward tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    ;; (if (> toReturn u0)
    ;;   (begin
    ;;     (unwrap! (as-contract (contract-call? .lbtc-token-v1c transfer toReturn tx-sender user none)) (err ERR_TRANSFER_FAIL))
    ;;   )
    ;;   true
    ;; )
    (ok true)
 )
  
)

(define-public (unstake-tokens (idx uint))
  (let (
      (user tx-sender)
      (staker-info (get-staker-or-default user))
      (vault-info (get-staking-vault-or-default idx))
      (owner (unwrap! (nft-get-owner? lBTC-staking-vault idx) (err ERR_NOTHING_TO_RETURN)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (is-eq tx-sender owner) (err ERR_NOT_AUTHORIZED))
    (asserts! (>= block-height (get cooldownBlock vault-info)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))
    (asserts! (is-eq (get reclaimBlock vault-info) u0) (err ERR_COOLDOWN_ALREADY_SET))
    (map-set StakingVault idx (merge vault-info {reclaimBlock: (+ block-height COOLDOWN_CYCLE)}))
    (ok true)
  )
)

(define-public (reclaim-tokens (idx uint))
  (let (
      (user tx-sender)
      (staker-info (get-staker-or-default user))
      (vault-info (get-staking-vault-or-default idx))
      (owner (unwrap! (nft-get-owner? lBTC-staking-vault idx) (err ERR_NOTHING_TO_RETURN)))
    )    
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (not (is-eq (get cooldownBlock vault-info) u0)) (err ERR_COOLDOWN_NOT_SET))
    (asserts! (< (get reclaimBlock vault-info) block-height) (err ERR_COOLDOWN_NOT_REACHED))
    (asserts! (is-eq tx-sender owner) (err ERR_NOT_AUTHORIZED))

    (try! (nft-burn? lBTC-staking-vault idx tx-sender))
    (try! (as-contract (contract-call? .lbtc-token-v1c transfer (get amountReturn vault-info) tx-sender user none)))
    (map-set StakerInfo
      user
      {
        staked_list : (get staked_list staker-info),
        amountReturn: (- (get amountReturn staker-info) (get amountReturn vault-info))
      }
    )
    (map-delete StakingVault idx)
    (ok true)
  )
)

;;;;;;;;;; REWARD CALC ;;;;;;;;;

;; BASIC_BLOCK_MINING_REWARD : u952000000
;; BASIC_CYCLE_MINING_REWARD = BASIC_BLOCK_MINING_REWARD * 144 * 30 * 0.3
(define-data-var BASIC_CYCLE_MINING_REWARD uint u1233792000000)
(define-constant MIN_STAKING_CYCLE_REWARDS u1000000000)

(define-private (get-staking-rewards-per-cycle-num (target-cycle uint))
  (get actual-cycle-rewards (unwrap! (get-staking-rewards-per-cycle target-cycle) u0))
)

(define-read-only (get-staking-rewards-per-cycle (target-cycle uint))
  (let (
    (cycles-per-year u12)
    (year-number (+ (/ target-cycle cycles-per-year) u1))
    (staking-rewards-divider (pow u2 (/ (- year-number u1) u4)))
    (rewardCycleStats (get-staking-stats-at-cycle-or-default target-cycle))
    (actual-cycle-rewards (/ (get amountRewardBase rewardCycleStats) staking-rewards-divider))
  )
        (if (>= actual-cycle-rewards MIN_STAKING_CYCLE_REWARDS)
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: actual-cycle-rewards})
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: MIN_STAKING_CYCLE_REWARDS})
    )
  )
)


(define-read-only (get-staking-reward-from-list (user principal) (staked-list (list 100 uint)))
  (let 
    (
      (stacksHeight block-height)
      (commitment 
        {
          stakerId: user,
          stacksHeight: stacksHeight,
          rewardSum: u0
        }
      )
    )
    (fold get-entitled-staking-reward-closure staked-list commitment)
  )
)

(define-private (get-entitled-staking-reward-closure (targetCycle uint)
  (commitment 
      {
      stakerId: principal,
      stacksHeight: uint,
      rewardSum: uint
    }
  ))
  (let
    (
      (stakerId (get stakerId commitment))
      (stacksHeight (get stacksHeight commitment))
      (rewardSum (get rewardSum commitment))
      (cur-reward (get-entitled-staking-reward stakerId targetCycle stacksHeight))
    )
    {
      stakerId: stakerId,
      stacksHeight: stacksHeight,
      rewardSum: (+ rewardSum cur-reward)
    }
  )
)


;;;;;;;;;;;;;;;;;;;;;;;MANAGE;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var rem-item uint u0)
(define-private (remove-filter (a uint)) (not (is-eq a (var-get rem-item))))

(define-data-var size-item uint u0)
(define-data-var add-num uint u0)
(define-private (size-filter (a uint)) (< a (var-get size-item)))

(define-data-var check-list (list 100 uint) (list ))
(define-private (check-filter (a uint))
 (is-none (index-of (var-get check-list) a))
)

(define-private (delete-item-from-list (idx-list (list 100 uint)) (ritem uint))
  (begin 
    (var-set rem-item ritem)
    (unwrap-panic (as-max-len? (filter remove-filter idx-list) u100))
  )
)

(define-private (add-items-to-list (idx-list (list 100 uint)) (sizeitem uint) (addnum uint))
    (as-max-len? (concat idx-list (check-item-from-list idx-list (cut-sized-list sizeitem addnum))) u100)
)

(define-private (add-num-func (num uint))
    (+ num (var-get add-num))
)
(define-private (cut-sized-list (sizeitem uint) (addnum uint))
  (begin 
    (var-set size-item sizeitem)
    (var-set add-num addnum)
    (map add-num-func (unwrap-panic (as-max-len? (filter size-filter REWARD_CYCLE_INDEXES) u36)))
  )
)
(define-private (check-item-from-list (idx-list (list 100 uint)) (new-list (list 36 uint)))
  (begin 
    (var-set check-list idx-list)
    (unwrap-panic (as-max-len? (filter check-filter new-list) u36))
  )
)

(define-data-var stake-end-cycle uint u9999999999)


(define-public (set-stake-end-cycle (end-cycle uint)) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (ok (var-set stake-end-cycle end-cycle)) ;; Returns true
  )
)

(define-read-only (get-stake-end-cycle)
  (var-get stake-end-cycle) 
)

(define-public (set-mining-reward (amount uint)) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (var-set BASIC_CYCLE_MINING_REWARD amount)
    (let (
        (currentCycle (unwrap! (get-reward-cycle block-height) (err ERR_STAKING_NOT_AVAILABLE)))
      )
      (map set-mining-reward-closure (cut-sized-list u36 currentCycle))
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


(define-public (awd-reclaim-reward) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (let (
        (stsw-amount (unwrap-panic (contract-call? .stsw-token-v4a get-balance (as-contract tx-sender))))
        (user tx-sender)
      )
      (if (> stsw-amount u0)
        (try! (as-contract (contract-call? .stsw-token-v4a transfer stsw-amount tx-sender user none)))
        false
      )
    )
    (ok true)
  )
)


(define-data-var is-started bool false)

(define-public (start-contract (nft-id-new uint) (rounds (list 100 uint))) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (let (
        (contract-v1-amount (unwrap-panic (contract-call? .lbtc-token-v1c get-balance .stackswap-lbtc-staking-v1a)))
      )
      (if (> contract-v1-amount u0)
        (try! (contract-call? .lbtc-token-v1c revoke-for-dao contract-v1-amount .stackswap-lbtc-staking-v1a .stackswap-lbtc-staking-v2a))
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
      (rewardCycleStats (contract-call? .stackswap-lbtc-staking-v1a get-staking-stats-at-cycle-or-default round))
    )
    (map-set StakingStatsAtCycle
      round
      rewardCycleStats
    )
  )
)



(define-public (migrate-user (user principal)) 
  (let (
      (user-data (contract-call? .stackswap-lbtc-staking-v1a get-staker user))
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
      (user-round-data (contract-call? .stackswap-lbtc-staking-v1a get-staker-at-cycle-or-default round user))
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
      (user-vault-data (contract-call? .stackswap-lbtc-staking-v1a get-staking-vault-or-default (get vaultID data)))
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
