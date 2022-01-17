(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

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

(define-private (get-staker-or-default (user principal))
  (default-to 
    (list )
    (map-get? StakerInfo user))
)

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

(define-map StakingStatsAtCycle
  uint
  {
    amountvSTSW: uint
  }
)

(define-read-only (get-staking-stats-at-cycle (rewardCycle uint))
  (map-get? StakingStatsAtCycle rewardCycle)
)

(define-read-only (get-staking-stats-at-cycle-or-default (rewardCycle uint))
  (default-to { amountvSTSW: u0 }
    (map-get? StakingStatsAtCycle rewardCycle))
)

(define-map StakerAtCycle
  {
    rewardCycle: uint,
    user: principal,
  }
  {
    amountvSTSW: uint,
    toReturn: uint
  }
)

(define-read-only (get-staker-at-cycle (rewardCycle uint) (user principal))
  (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user })
)

(define-read-only (get-staker-at-cycle-or-default (rewardCycle uint) (user principal))
  (default-to { amountvSTSW: u0, toReturn: u0 }
    (map-get? StakerAtCycle { rewardCycle: rewardCycle, user: user }))
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

(define-read-only (get-staking-reward-per-user (user principal) (targetCycle uint) )
  (get-entitled-staking-reward user targetCycle block-height)
)

(define-private (get-entitled-staking-reward (user principal) (targetCycle uint) (stacksHeight uint))
  (let
    (
      (rewardCycleStats (get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (get-staker-at-cycle-or-default targetCycle user))
      (totalRewardThisCycle (get-staking-rewards-per-cycle-num targetCycle)) 
      (totalStakedThisCycle (get amountvSTSW rewardCycleStats))
      (userStakedThisCycle (get amountvSTSW stakerAtCycle))
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

(define-public (stake-tokens (amountTokens uint) (lockPeriod uint))
  (let
    (
      (user tx-sender)
      (startHeight block-height)
      (currentCycle (unwrap! (get-reward-cycle startHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (targetCycle (+ u1 currentCycle))
      (stake-result (try! (contract-call? .vstsw-token-v1k stake-tokens amountTokens lockPeriod)))
      (commitment {
        stakerId: user,
        amountSTSW: amountTokens,
        amountvSTSW: (get amount-vSTSW stake-result),
        first: targetCycle,
        last: (+ targetCycle lockPeriod)
      })
      (staked-list (get-staker-or-default user))
      (new-list (unwrap! (add-items-to-list staked-list lockPeriod targetCycle) (err ERR_UNSTAKELIST_FULL)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES))
      (err ERR_CANNOT_STAKE))
    (asserts! (< targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STAKE))
    (map-set StakerInfo
      user
      new-list
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
      amountSTSW: uint,
      amountvSTSW: uint,
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
        (amountSTSW (get amountSTSW commitment))
        (amountvSTSW (get amountvSTSW commitment))
        (firstCycle (get first commitment))
        (lastCycle (get last commitment))
        (targetCycle (+ firstCycle rewardCycleIdx))
        (stakerAtCycle (get-staker-at-cycle-or-default targetCycle stakerId))
        (toReturn (get toReturn stakerAtCycle))
      )
      (begin
        (if (and (>= targetCycle firstCycle) (< targetCycle lastCycle))
          (begin
            (if (is-eq targetCycle (- lastCycle u1))
              (set-tokens-staked stakerId targetCycle amountvSTSW amountSTSW)
              (set-tokens-staked stakerId targetCycle amountvSTSW u0)
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
        amountvSTSW: (+ amountStaked (get amountvSTSW rewardCycleStats))
      }
    )
    (map-set StakerAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
      }
      {
        amountvSTSW: (+ amountStaked (get amountvSTSW stakerAtCycle)),
        toReturn: (+ toReturn (get toReturn stakerAtCycle))
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
      (toReturn (get toReturn stakerAtCycle))
      (staked-list (get-staker-or-default user))
      (new-list (delete-item-from-list staked-list targetCycle))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledReward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))

    (map-set StakerAtCycle
      {
        rewardCycle: targetCycle,
        user: user,
      }
      {
        amountvSTSW: u0,
        toReturn: u0
      }
    )
    (map-set StakerInfo
      user
      new-list
    )
    (if (> entitledReward u0)
      (unwrap! (as-contract (contract-call? .stsw-token-v4a transfer entitledReward tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (ok true)
 )
  
)

;; BASIC_BLOCK_MINING_REWARD : u952000000
;; BASIC_CYCLE_MINING_REWARD = BASIC_BLOCK_MINING_REWARD * 144 * 30 * 0.3
(define-constant BASIC_CYCLE_MINING_REWARD u1233792000000)
(define-constant MIN_STAKING_CYCLE_REWARDS u1000000000)

(define-private (get-staking-rewards-per-cycle-num (target-cycle uint))
  (get actual-cycle-rewards (unwrap! (get-staking-rewards-per-cycle target-cycle) u0))
)

(define-read-only (get-staking-rewards-per-cycle (target-cycle uint))
  (let (
    (cycles-per-year u12)
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

(define-read-only (get-staking-reward-total (user principal))
  (let 
    (
      (stacksHeight block-height)
      (staked-list (get-staker-or-default user))
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
