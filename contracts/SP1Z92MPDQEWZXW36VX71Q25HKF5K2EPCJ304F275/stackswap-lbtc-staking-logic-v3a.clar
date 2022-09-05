
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

;; (define-read-only (staking-active-at-cycle (rewardCycle uint))
;;   (is-some
;;     (get amountlBTC (map-get? StakingStatsAtCycle rewardCycle))
;;   )
;; )

(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ FIRST_STAKING_BLOCK (* REWARD_CYCLE_LENGTH rewardCycle))
)

(define-read-only (get-staking-reward-per-user (user principal) (targetCycle uint) ) ;;this is read-only function..
  (get-entitled-staking-reward user targetCycle block-height)
)

(define-private (get-entitled-staking-reward (user principal) (targetCycle uint) (stacksHeight uint))
  (let
    (
      (rewardCycleStats (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-at-cycle-or-default targetCycle user))
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
      (staker-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-or-default user))
      (new-list (unwrap! (unwrap-panic (contract-call? .stackswap-list-helper-v1 add-items-to-list (get staked_list staker-info) lockPeriod targetCycle)) (err ERR_UNSTAKELIST_FULL)))

    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES))
      (err ERR_CANNOT_STAKE))
    (asserts! (< targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STAKE))
    (unwrap! (contract-call? .lbtc-token-v1c transfer amountTokens user .stackswap-lbtc-staking-data-v3a none) (err ERR_TRANSFER_FAIL))
    (try! (contract-call? .stackswap-lbtc-staking-data-v3a add-new-nft-vault {
        cooldownBlock: (+ block-height (* lockPeriod REWARD_CYCLE_LENGTH)),
        reclaimBlock: u0,
        amountReturn: amountTokens
      }))
    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staker user {
        staked_list : new-list,
        amountReturn: (+ amountTokens (get amountReturn staker-info))
      }))
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
              (try! (set-tokens-staked stakerId targetCycle amountlBTC amountReturn))
              (try! (set-tokens-staked stakerId targetCycle amountlBTC u0))
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
      (rewardCycleStats (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-stats-at-cycle-or-default targetCycle))
      (stakerAtCycle (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-at-cycle-or-default targetCycle user))
    )

    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staking-stats-at-cycle targetCycle {
        amountReturn: (+ toReturn (get amountReturn rewardCycleStats)),
        amountlBTC: (+ amountStaked (get amountlBTC rewardCycleStats)),
        amountRewardBase: (get amountRewardBase rewardCycleStats)
      }))

    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staker-at-cycle {
        rewardCycle: targetCycle,
        user: user,
      } {
        amountReturn: (+ toReturn (get amountReturn stakerAtCycle)),
        amountlBTC: (+ amountStaked (get amountlBTC stakerAtCycle))
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
      (stakerAtCycle (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-at-cycle-or-default targetCycle user))
      (toReturn (get amountReturn stakerAtCycle))
      (staker-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-or-default user))
      (new-list (unwrap-panic (contract-call? .stackswap-list-helper-v1 delete-item-from-list (get staked_list staker-info) targetCycle)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledReward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= targetCycle (var-get stake-end-cycle)) (err ERR_STAKE_ENDED))

    (try! (contract-call? .stackswap-lbtc-staking-data-v3a delete-staker-at-cycle {
        rewardCycle: targetCycle,
        user: user,
      }))
    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staker user
      {
        staked_list : new-list,
        amountReturn: (get amountReturn staker-info)
        ;; amountReturn: (- (get amountReturn staker-info) toReturn)
      }))
    
    (if (> entitledReward u0)
      (try! (contract-call? .stackswap-lbtc-staking-data-v3a transfer-reward user entitledReward))  
      true
    )
    (ok true)
 )
  
)

(define-public (unstake-tokens (idx uint))
  (let (
      (user tx-sender)
      (staker-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-or-default user))
      (vault-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-vault-or-default idx))
      (owner (unwrap! (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-vault-owner idx) (err ERR_NOTHING_TO_RETURN)))
    )
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (is-eq tx-sender owner) (err ERR_NOT_AUTHORIZED))
    (asserts! (>= block-height (get cooldownBlock vault-info)) (err ERR_BLOCK_HEIGHT_NOT_REACHED))
    (asserts! (is-eq (get reclaimBlock vault-info) u0) (err ERR_COOLDOWN_ALREADY_SET))
    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staking-vault idx
      (merge vault-info {reclaimBlock: (+ block-height COOLDOWN_CYCLE)})))
    (ok true)
  )
)

(define-public (reclaim-tokens (idx uint))
  (let (
      (user tx-sender)
      (staker-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staker-or-default user))
      (vault-info (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-vault-or-default idx))
      (owner (unwrap! (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-vault-owner idx) (err ERR_NOTHING_TO_RETURN)))
    )    
    (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (var-get is-started) (err ERR_NOT_STARTED))
    (asserts! (not (is-eq (get cooldownBlock vault-info) u0)) (err ERR_COOLDOWN_NOT_SET))
    (asserts! (< (get reclaimBlock vault-info) block-height) (err ERR_COOLDOWN_NOT_REACHED))
    (asserts! (is-eq tx-sender owner) (err ERR_NOT_AUTHORIZED))

    (try! (contract-call? .stackswap-lbtc-staking-data-v3a transfer-asset user (get amountReturn vault-info)))  

    ;; (try! (as-contract (contract-call? .lbtc-token-v1c transfer (get amountReturn vault-info) tx-sender user none)))
    ;; (map-set StakerInfo
    ;;   user
    ;;   {
    ;;     staked_list : (get staked_list staker-info),
    ;;     amountReturn: (- (get amountReturn staker-info) (get amountReturn vault-info))
    ;;   }
    ;; )
    (try! (contract-call? .stackswap-lbtc-staking-data-v3a set-staker user
      {
        staked_list : (get staked_list staker-info),
        amountReturn: (- (get amountReturn staker-info) (get amountReturn vault-info))
      }))

    (try! (contract-call? .stackswap-lbtc-staking-data-v3a delete-staking-vault idx))
    ;; (map-delete StakingVault idx)
    (ok true)
  )
)

;;;;;;;;;; REWARD CALC ;;;;;;;;;

;; BASIC_BLOCK_MINING_REWARD : u952000000
;; BASIC_CYCLE_MINING_REWARD = BASIC_BLOCK_MINING_REWARD * 144 * 30 * 0.3
(define-constant MIN_STAKING_CYCLE_REWARDS u1000000000)

(define-private (get-staking-rewards-per-cycle-num (target-cycle uint))
  (get actual-cycle-rewards (unwrap! (get-staking-rewards-per-cycle target-cycle) u0))
)

(define-read-only (get-staking-rewards-per-cycle (target-cycle uint))
  (let (
    (cycles-per-year u12)
    (year-number (+ (/ target-cycle cycles-per-year) u1))
    (staking-rewards-divider (pow u2 (/ (- year-number u1) u4)))
    (rewardCycleStats (contract-call? .stackswap-lbtc-staking-data-v3a get-staking-stats-at-cycle-or-default target-cycle))
    (actual-cycle-rewards (/ (get amountRewardBase rewardCycleStats) staking-rewards-divider))
  )
        (if (>= actual-cycle-rewards MIN_STAKING_CYCLE_REWARDS)
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: actual-cycle-rewards})
      (ok {year-number: year-number, staking-rewards-divider: staking-rewards-divider, actual-cycle-rewards: MIN_STAKING_CYCLE_REWARDS})
    )
  )
)


(define-read-only (get-staking-reward-from-list (user principal) (staked-list (list 100 uint))) ;; this is read-only function
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
        (stsw-amount (unwrap-panic (contract-call? .stsw-token-v4a get-balance .stackswap-lbtc-staking-data-v3a)))
        (user tx-sender)
      )
      (if (> stsw-amount u0)
        (try! (contract-call? .stackswap-lbtc-staking-data-v3a transfer-reward tx-sender stsw-amount))  
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
