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
(define-constant ERR_STARTED u4342)
(define-constant ERR_NOT_STARTED u4343)


(define-constant FIRST_STAKING_BLOCK u38083) 
(define-constant REWARD_CYCLE_LENGTH u4320)          ;; how long a reward cycle is (144 * 30) u4320
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

(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ FIRST_STAKING_BLOCK (* REWARD_CYCLE_LENGTH rewardCycle))
)

(define-read-only (get-staking-reward-per-user (user principal) (targetCycle uint) )
  (get-entitled-staking-reward user targetCycle block-height)
)

(define-private (get-entitled-staking-reward (user principal) (targetCycle uint) (stacksHeight uint))
  (let
    (
      (rewardCycleStats (contract-call? .stackswap-stsw-staking-data-v2a get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (contract-call? .stackswap-stsw-staking-data-v2a get-staker-at-cycle-or-default targetCycle user))
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
      (staked-list (contract-call? .stackswap-stsw-staking-data-v2a get-staker-or-default user))
      (new-list (unwrap! (unwrap-panic (contract-call? .stackswap-list-helper-v1 add-items-to-list staked-list lockPeriod targetCycle)) (err ERR_UNSTAKELIST_FULL)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES))
      (err ERR_CANNOT_STAKE))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (< targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STAKE))
    (try! (contract-call? .stackswap-stsw-staking-data-v2a set-staker user new-list))
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
        (stakerAtCycle (contract-call? .stackswap-stsw-staking-data-v2a get-staker-at-cycle-or-default targetCycle stakerId))
        ;; (toReturn (get amountSTSW stakerAtCycle))
      )
      (begin
        (if (and (>= targetCycle firstCycle) (< targetCycle lastCycle))
          (begin
            (if (is-eq targetCycle (- lastCycle u1))
              (try! (set-tokens-staked stakerId targetCycle amountvSTSW amountSTSW))
              (try! (set-tokens-staked stakerId targetCycle amountvSTSW amountSTSW))
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
      (rewardCycleStats (contract-call? .stackswap-stsw-staking-data-v2a get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (contract-call? .stackswap-stsw-staking-data-v2a get-staker-at-cycle-or-default targetCycle user))
    )
    (try! (contract-call? .stackswap-stsw-staking-data-v2a set-staking-stats-at-cycle targetCycle {
        amountSTSW: (+ toReturn (get amountSTSW rewardCycleStats)),
        amountvSTSW: (+ amountStaked (get amountvSTSW rewardCycleStats)),
        amountRewardBase: (get amountRewardBase rewardCycleStats)
    }))
    (try! (contract-call? .stackswap-stsw-staking-data-v2a set-staker-at-cycle {
        rewardCycle: targetCycle,
        user: user,
      } {
        amountvSTSW: (+ amountStaked (get amountvSTSW stakerAtCycle)),
        amountSTSW: (+ toReturn (get amountSTSW stakerAtCycle))
      }))
      (ok true)
  )
)

(define-public (claim-staking-reward (targetCycle uint))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (currentCycle (unwrap! (get-reward-cycle stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (entitledReward (get-entitled-staking-reward user targetCycle stacksHeight))
      (stakerAtCycle (contract-call? .stackswap-stsw-staking-data-v2a get-staker-at-cycle-or-default targetCycle user))
      (toReturn (get amountSTSW stakerAtCycle))
      (staked-list (contract-call? .stackswap-stsw-staking-data-v2a get-staker-or-default user))
      (new-list (unwrap-panic (contract-call? .stackswap-list-helper-v1 delete-item-from-list staked-list targetCycle)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledReward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))

    (try! (contract-call? .stackswap-stsw-staking-data-v2a delete-staker-at-cycle {
        rewardCycle: targetCycle,
        user: user,
      }))
    (try! (contract-call? .stackswap-stsw-staking-data-v2a set-staker user new-list))
    (if (> entitledReward u0)
      (try! (contract-call? .stackswap-stsw-staking-data-v2a transfer-reward user entitledReward))  
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
    (rewardCycleStats (contract-call? .stackswap-stsw-staking-data-v2a get-staking-stats-at-cycle-or-default target-cycle))
    (actual-cycle-rewards (/ (get amountRewardBase rewardCycleStats) staking-rewards-divider))
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
      (staked-list (contract-call? .stackswap-stsw-staking-data-v2a get-staker-or-default user))
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

(define-public (awd-reclaim-reward) 
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (let (
        (stsw-amount (unwrap-panic (contract-call? .stsw-token-v4a get-balance .stackswap-stsw-staking-data-v2a)))
        (user tx-sender)
      )
      (if (> stsw-amount u0)
        (try! (contract-call? .stackswap-stsw-staking-data-v2a transfer-reward tx-sender stsw-amount))  
        false
      )
    )
    (ok true)
  )
)

(define-data-var is-started bool false)

(define-public (start-contract)
  (begin
    (asserts! (is-eq contract-caller (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_NOT_AUTHORIZED))
    (asserts! (not (var-get is-started)) (err ERR_STARTED))
    (var-set is-started true)
    (ok true)
  )
)
