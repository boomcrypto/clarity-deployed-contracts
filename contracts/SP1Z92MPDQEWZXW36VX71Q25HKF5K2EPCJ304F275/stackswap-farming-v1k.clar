(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-constant ERR_STAKING_NOT_AVAILABLE u4300)  
(define-constant ERR_CANNOT_STAKE u4301)
(define-constant ERR_INSUFFICIENT_BALANCE u4302)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u4303)
(define-constant ERR_NOTHING_TO_REDEEM u4304)
(define-constant ERR_PERMISSION_DENIED u4305)
(define-constant ERR_INVALID_ROUTER u4306)
(define-constant ERR_INVALID_WSTX_TOKEN u4309)
(define-constant ERR_TRANSFER_FAIL u4311)
(define-constant ERR_POOL_NOT_ENROLLED u4312)
(define-constant ERR_TOKEN_ALREADY_IN_POOL u4313)
(define-constant ERR_FARM_ENDED u4314)
(define-constant ERR_FARM_NOT_ENDED u4315)
(define-constant ERR_UNSTAKELIST_FULL u4316)


(define-data-var farm-count uint u0)

(define-data-var farm-end-cycle uint u9999999999)

(define-read-only (get-farm-count)
  (ok (var-get farm-count))
)

(define-map Farmable-pools
  principal 
  uint
)
(define-map Farmable-pools-idx
  uint 
  principal
)

(define-read-only (get-farm-contracts (farm-id uint))
  (unwrap-panic (map-get? Farmable-pools-idx farm-id))
)

(define-read-only (is-farm-available (pool principal))
    (is-some (map-get? Farmable-pools pool))
)

(define-public (add-pools (new-pool <liquidity-token>))
  (let
    (
      (tokens (try! (contract-call? new-pool get-tokens)))
      (wstx-is-x (is-eq .wstx-token-v4a (get token-x tokens)))
      (wstx-is-y (is-eq .wstx-token-v4a (get token-y tokens)))
      (new-pool-principal (contract-of new-pool))
    )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (asserts! (not (is-farm-available new-pool-principal)) (err ERR_TOKEN_ALREADY_IN_POOL))
    (asserts! (or wstx-is-x wstx-is-y) (err ERR_INVALID_WSTX_TOKEN))
    (var-set farm-count (+ (var-get farm-count) u1))
    (map-set Farmable-pools-idx (var-get farm-count) new-pool-principal )
    (if wstx-is-x
      (map-set Farmable-pools new-pool-principal u1)
      (map-set Farmable-pools new-pool-principal u2)
    )
    (ok true)
  )
)

(define-public (remove-pools (remove-pool principal)) 
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (ok (map-delete Farmable-pools remove-pool))
  )
)

(define-public (set-farm-end-cycle (end-cycle uint)) 
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (ok (var-set farm-end-cycle end-cycle))
  )
)

(define-read-only (get-farm-end-cycle)
  (var-get farm-end-cycle) 
)

(define-constant FIRST_FARMING_BLOCK u38083)        
(define-constant REWARD_CYCLE_LENGTH u1008)          ;; how long a reward cycle is (144 * 7) u1008
(define-constant MAX_REWARD_CYCLES u64)  
(define-constant REWARD_CYCLE_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63))


(define-map StakingStatsAtCycle
  uint
  {
    amountUstx: uint,
    amountSTSW: uint
  }
)

(define-read-only (get-staking-stats-at-cycle (rewardCycle uint))
  (map-get? StakingStatsAtCycle rewardCycle)
)

(define-private (get-staking-stats-at-cycle-or-default (rewardCycle uint))
  (default-to { amountUstx: u0, amountSTSW: u0 } 
    (map-get? StakingStatsAtCycle rewardCycle))
)

(define-map StakerInfo
  {
    user: principal,
    pool: principal
  }
  {
    amountUstx: uint,
    unclaimedList: (list 200 uint)
  }
)

(define-read-only (get-staker (user principal) (pool principal))
  (map-get? StakerInfo { user: user, pool: pool })
)

(define-private (get-staker-or-default (user principal) (pool principal))
  (default-to 
    { 
      amountUstx: u0,
      unclaimedList: (list )
    }
    (map-get? StakerInfo { user: user, pool: pool }))
)

(define-data-var rem-item uint u0)
(define-private (remove-filter (a uint)) (not (is-eq a (var-get rem-item))))

(define-data-var size-item uint u0)
(define-data-var add-num uint u0)
(define-private (size-filter (a uint)) (< a (var-get size-item)))

(define-data-var check-list (list 200 uint) (list ))
(define-private (check-filter (a uint))
 (is-none (index-of (var-get check-list) a))
)

(define-private (delete-item-from-list (idx-list (list 200 uint)) (ritem uint))
  (begin 
    (var-set rem-item ritem)
    (unwrap-panic (as-max-len? (filter remove-filter idx-list) u200))
  )
)

(define-private (add-items-to-list (idx-list (list 200 uint)) (sizeitem uint) (addnum uint))
    (as-max-len? (concat idx-list (check-item-from-list idx-list (cut-sized-list sizeitem addnum))) u200)
)

(define-private (add-num-func (num uint))
    (+ num (var-get add-num))
)
(define-private (cut-sized-list (sizeitem uint) (addnum uint))
  (begin 
    (var-set size-item sizeitem)
    (var-set add-num addnum)
    (map add-num-func (unwrap-panic (as-max-len? (filter size-filter REWARD_CYCLE_INDEXES) u64)))
  )
)
(define-private (check-item-from-list (idx-list (list 200 uint)) (new-list (list 64 uint)))
  (begin 
    (var-set check-list idx-list)
    (unwrap-panic (as-max-len? (filter check-filter new-list) u64))
  )
)

(define-map StakerPerPoolAtCycle
  {
    rewardCycle: uint,
    user: principal,
    pool: principal
  }
  {
    amountUstx: uint,
    amountSTSW: uint,
    toReturn: uint
  }
)

(define-read-only (get-staker-at-cycle (rewardCycle uint) (user principal) (pool principal))
  (map-get? StakerPerPoolAtCycle { rewardCycle: rewardCycle, user: user, pool: pool })
)

(define-private (get-staker-at-cycle-or-default (rewardCycle uint) (user principal) (pool principal))
  (default-to { amountUstx: u0, amountSTSW: u0, toReturn: u0 }
    (map-get? StakerPerPoolAtCycle { rewardCycle: rewardCycle, user: user, pool: pool }))
)

(define-read-only (get-reward-cycle (stacksHeight uint))
  (let
    (
      (firstStakingBlock FIRST_FARMING_BLOCK)
      (rcLen REWARD_CYCLE_LENGTH)
    )
    (if (>= stacksHeight firstStakingBlock)
      (some (/ (- stacksHeight firstStakingBlock) rcLen))
      none)
  )
)

(define-read-only (staking-active-at-cycle (rewardCycle uint))
  (is-some
    (get amountUstx (map-get? StakingStatsAtCycle rewardCycle))
  )
)

(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ FIRST_FARMING_BLOCK (* REWARD_CYCLE_LENGTH rewardCycle))
)

(define-read-only (get-staking-reward-per-user (user principal) (pool principal) (targetCycle uint) )
  (get-entitled-staking-reward user targetCycle block-height pool)
)

(define-private (get-entitled-staking-reward (user principal) (targetCycle uint) (stacksHeight uint) (pool principal))
  (let
    (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user pool))
      (totalRewardThisCycle (get-staking-rewards-per-cycle-num targetCycle))
      (totalStakedThisCycle (get amountUstx rewardCycleStats))
      (userStakedThisCycle (get amountUstx stakerAtCycle))
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

;; STAKING ACTIONS

(define-public (stake-tokens (amountTokens uint) (pool <liquidity-token>) (lockPeriod uint))
  (begin
    (asserts! (is-farm-available (contract-of pool)) (err ERR_POOL_NOT_ENROLLED))
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (try! (stake-tokens-at-cycle contract-caller amountTokens pool block-height lockPeriod))
    (ok true)
  )
)

(define-private (stake-tokens-at-cycle (user principal) (amountTokens uint) (pool <liquidity-token>) (startHeight uint) (lockPeriod uint))
  (let
    (
      (currentCycle (unwrap! (get-reward-cycle startHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (targetCycle (+ u1 currentCycle))
      (amount-stx (try! (get-lp-wstx-amount pool amountTokens)))
      (amount-staked-total (get-staker-or-default user (contract-of pool)))
      (commitment {
        stakerId: user,
        amountWstx: amount-stx,
        amountLP: amountTokens,
        pool: (contract-of pool),
        first: targetCycle,
        last: (+ targetCycle lockPeriod)
      })
      (new-list (unwrap! (add-items-to-list (get unclaimedList amount-staked-total) lockPeriod targetCycle) (err ERR_UNSTAKELIST_FULL)))
    )
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES))
      (err ERR_CANNOT_STAKE))
    (asserts! (< targetCycle (var-get farm-end-cycle)) (err ERR_FARM_ENDED))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STAKE))
    (unwrap! (contract-call? pool transfer amountTokens user (as-contract tx-sender) none)
        (err ERR_INSUFFICIENT_BALANCE))
    (map-set StakerInfo
      {
        user: user,
        pool: (contract-of pool)
      }
      { 
        amountUstx: (+ (get amountUstx amount-staked-total) amountTokens),
        unclaimedList: new-list
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
      amountWstx: uint,
      amountLP: uint,
      pool: principal,
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
        (amountWstx (get amountWstx commitment))
        (amountLP (get amountLP commitment))
        (firstCycle (get first commitment))
        (lastCycle (get last commitment))
        (targetCycle (+ firstCycle rewardCycleIdx))
        (pool (get pool commitment))
        (stakerAtCycle (get-staker-at-cycle-or-default targetCycle stakerId pool))
        (toReturn (get toReturn stakerAtCycle))
      )
      (begin
        (if (and (>= targetCycle firstCycle) (< targetCycle lastCycle))
          (begin
            (if (is-eq targetCycle (- lastCycle u1))
              (set-tokens-staked stakerId targetCycle amountWstx amountLP pool)
              (set-tokens-staked stakerId targetCycle amountWstx u0 pool)
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

(define-private (set-tokens-staked (user principal) (targetCycle uint) (amountStaked uint) (toReturn uint) (pool principal))
  (let
    (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user pool))
    )
    (map-set StakingStatsAtCycle
      targetCycle
      {
        amountSTSW: u0,
        amountUstx: (+ amountStaked (get amountUstx rewardCycleStats))
      }
    )
    (map-set StakerPerPoolAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
        pool: pool
      }
      {
        amountUstx: (+ amountStaked (get amountUstx stakerAtCycle)),
        amountSTSW: u0,
        toReturn: (+ toReturn (get toReturn stakerAtCycle))
      }
    )
  )
)

(define-public (claim-staking-reward (targetCycle uint) (pool <liquidity-token>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (currentCycle (unwrap! (get-reward-cycle stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (entitledReward (get-entitled-staking-reward user targetCycle stacksHeight (contract-of pool)))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user (contract-of pool)))
      (toReturn (get toReturn stakerAtCycle))
      (amount-staked-total (get-staker-or-default user (contract-of pool)))
      (new-list (delete-item-from-list (get unclaimedList amount-staked-total) targetCycle))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledReward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= targetCycle (var-get farm-end-cycle)) (err ERR_FARM_ENDED))

    (map-set StakerPerPoolAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
        pool: (contract-of pool)
      }
      {
        amountUstx: u0,
        amountSTSW: entitledReward,
        toReturn: u0
      }
    )
    (if (> toReturn u0)
      (begin
        (try! (as-contract (contract-call? pool transfer toReturn tx-sender user none)))
        (map-set StakerInfo
          {
            user: user,
            pool: (contract-of pool)
          }
          {   
            amountUstx: (- (get amountUstx amount-staked-total) toReturn),
            unclaimedList: new-list
          }
        )
      )
      (map-set StakerInfo
        {
          user: user,
          pool: (contract-of pool)
        }
        {   
          amountUstx: (get amountUstx amount-staked-total),
          unclaimedList: new-list
        }
      )
    )
    (if (> entitledReward u0)
      (unwrap! (as-contract (contract-call? .stsw-token-v4a transfer entitledReward tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (ok true)
  )
)

(define-public (unstake-from-farming (targetCycle uint) (pool <liquidity-token>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (currentCycle (unwrap! (get-reward-cycle stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user (contract-of pool)))
      (toReturn (get toReturn stakerAtCycle))
      (amount-staked-total (get-staker-or-default user (contract-of pool)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (> currentCycle (var-get farm-end-cycle)) (err ERR_FARM_NOT_ENDED))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (> toReturn u0) (err ERR_NOTHING_TO_REDEEM))

    (map-set StakerPerPoolAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
        pool: (contract-of pool)
      }
      (merge stakerAtCycle {toReturn: u0})
    )
    (if (> toReturn u0)
      (begin
        (try! (as-contract (contract-call? pool transfer toReturn tx-sender user none)))
        (map-set StakerInfo
          {
            user: user,
            pool: (contract-of pool)
          }
          (merge amount-staked-total  
            {   
              amountUstx: (- (get amountUstx amount-staked-total) toReturn)
            }
          )
        )
      )
      true
    )

    (ok true)
  )
)

;; STAKING CONFIGURATION
;; BASIC_BLOCK_MINING_REWARD : u952000000
;; BASIC_CYCLE_MINING_REWARD = BASIC_BLOCK_MINING_REWARD * 144 * 7 * 0.7
(define-constant BASIC_CYCLE_MINING_REWARD u671731200000)      
(define-constant MIN_STAKING_CYCLE_REWARDS u10000000)       

(define-private (get-staking-rewards-per-cycle-num (target-cycle uint))
  (get actual-cycle-rewards (unwrap! (get-staking-rewards-per-cycle target-cycle) u0))
)

(define-read-only (get-staking-rewards-per-cycle (target-cycle uint))
  (let (
    (cycles-per-year u52)
    (year-number (+ (/ target-cycle cycles-per-year) u1))
    (staking-rewards-divider (pow u2 (/ (- year-number u1) u4)))
    (actual-cycle-rewards (/ BASIC_CYCLE_MINING_REWARD staking-rewards-divider))
  )
      (if (>= actual-cycle-rewards MIN_STAKING_CYCLE_REWARDS)
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: actual-cycle-rewards})
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: MIN_STAKING_CYCLE_REWARDS})
    )
  )
)

(define-public (get-lp-wstx-amount (pool <liquidity-token>) (lp-token-amount uint))
  (let 
    (
      (lp-data (try! (contract-call? pool get-lp-data)))
      (balance-x (get balance-x lp-data))
      (balance-y (get balance-y lp-data))
      (shares-total (get shares-total lp-data))
      (wstx-is-x (is-eq (unwrap-panic (map-get? Farmable-pools (contract-of pool))) u1))
    )
    (if wstx-is-x
      (ok (/ (* balance-x lp-token-amount) shares-total))
      (ok (/ (* balance-y lp-token-amount) shares-total))
    )
  )    
)


(define-read-only (get-farming-reward-total (user principal) (pool principal))
  (let 
    (
      (stacksHeight block-height)
      (amount-staked-total (get-staker-or-default user pool))
      (commitment 
        {
          stakerId: user,
          pool: pool,
          stacksHeight: stacksHeight,
          rewardSum: u0
        }
      )
    )
    (fold get-entitled-staking-reward-closure (get unclaimedList amount-staked-total) commitment)
  )
)

(define-read-only (get-farming-reward-from-list (user principal) (pool principal) (unclaimedList (list 100 uint)))
  (let 
    (
      (stacksHeight block-height)
      (commitment 
        {
          stakerId: user,
          pool: pool,
          stacksHeight: stacksHeight,
          rewardSum: u0
        }
      )
    )
    (fold get-entitled-staking-reward-closure unclaimedList commitment)
  )
)

(define-private (get-entitled-staking-reward-closure (targetCycle uint)
  (commitment 
      {
      stakerId: principal,
      pool: principal,
      stacksHeight: uint,
      rewardSum: uint
    }
  ))
  (let
    (
      (stakerId (get stakerId commitment))
      (stacksHeight (get stacksHeight commitment))
      (rewardSum (get rewardSum commitment))
      (pool (get pool commitment))
    )
    (merge 
      commitment
      {
        rewardSum: (+ rewardSum (get-entitled-staking-reward stakerId targetCycle stacksHeight pool))
      }
    )
  )
)
