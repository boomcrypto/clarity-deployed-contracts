(use-trait liquidity-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-trait-v4c.liquidity-token-trait)
(use-trait oracle-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackwap-oracle-trait-v1b.oracle-trait)

(define-constant ERR_STAKING_NOT_AVAILABLE u4300)  
(define-constant ERR_CANNOT_STAKE u4301)
(define-constant ERR_INSUFFICIENT_BALANCE u4302)
(define-constant ERR_REWARD_ROUND_NOT_COMPLETED u4303)
(define-constant ERR_NOTHING_TO_REDEEM u4304)
(define-constant ERR_PERMISSION_DENIED u4305)
(define-constant ERR_INVALID_ROUTER u4306)
(define-constant ERR_INVALID_STSW_TOKEN u4309)
(define-constant ERR_ALREADY_MIGRATED u4310)
(define-constant ERR_ROUTING_FAIL u4311)
(define-constant ERR_TRANSFER_FAIL u4312)
(define-constant ERR_POOL_NOT_ENROLLED u4312)
(define-constant ERR_TOKEN_ALREADY_IN_POOL u4313)
(define-constant ERR_FARM_ENDED u4314)
(define-constant ERR_FARM_NOT_ENDED u4315)
(define-constant ERR_UNSTAKELIST_FULL u4316)


;; Farm List Control


(define-data-var lp_count uint u0)

(define-read-only (getLPCount)
  (ok (var-get lp_count))
)

(define-map FarmablePools
  principal 
  {
    token : (string-ascii 12),
    type : bool
  }
)
(define-map FarmablePoolsIdx
  uint 
  principal
)

(define-read-only (getFarmContracts (farm-id uint))
  (unwrap-panic (map-get? FarmablePoolsIdx farm-id))
)

(define-read-only (isFarmAvailable (pool principal))
    (is-some (map-get? FarmablePools pool))
)

;; Farming Constants

(define-constant FIRST_FARMING_BLOCK u38083)        
(define-constant REWARD_ROUND_LENGTH u1008)          ;; how long a reward round is (144 * 7) u1008
(define-constant MAX_REWARD_ROUNDS u64)  
(define-constant REWARD_ROUND_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63))

;; FARMING CONFIGURATION
;; BASIC_BLOCK_MINING_REWARD : u952000000
;; BASIC_ROUND_MINING_REWARD = BASIC_BLOCK_MINING_REWARD * 144 * 7 * 0.7
(define-constant MIN_STAKING_ROUND_REWARDS u10000000)       


;;Farming Variables & DATA

(define-data-var farm_end_round uint u9999999999)

;; set before the 'change round' start
;; during the round, one can't change the block reward
(define-data-var reward_per_round uint u671731200000)


(define-map LPTotalData
  principal ;; LP
  {
    amountLP: uint,
    weight: uint
  }
)

(define-read-only (getLPTotalData (pool principal))
  (map-get? LPTotalData pool)
)

(define-private (getLPTotalDataOrDefault (pool principal))
  (default-to { amountLP: u0, weight: u1 } 
    (map-get? LPTotalData pool))
)


(define-map LPUserData
  {
    user: principal,
    pool: principal
  }
  {
    amountLP: uint,
    unclaimedList: (list 200 uint)
  }
)

(define-read-only (getLPUserData (pool principal) (user principal))
  (map-get? LPUserData { user: user, pool: pool })
)

(define-private (getLPUserDataOrDefault (pool principal) (user principal))
  (default-to 
    { 
      amountLP: u0,
      unclaimedList: (list )
    }
    (map-get? LPUserData { user: user, pool: pool }))
)


(define-map TotalRoundData
  uint ;; round
  {
    value: uint,
    reward: uint
  }
)

(define-read-only (getTotalRoundData (round uint))
  (map-get? TotalRoundData round)
)

(define-private (getTotalRoundDataOrDefault (round uint))
  (default-to 
    { 
      value: u0,
      reward: u0
    }
    (map-get? TotalRoundData round))
)

(define-map LPRoundData
  {
    pool: principal,
    round: uint
  }
  {
    value: uint,
    weight: uint,
    amountLP: uint,
    price: uint
  }
)

(define-read-only (getLPRoundData (pool principal) (round uint))
  (map-get? LPRoundData { pool: pool, round: round })
)

(define-private (getLPRoundDataOrDefault (pool principal) (round uint))
  (default-to 
    { 
      value: u0,
      weight: u0,
      amountLP: u0,
      price: u0
    }
    (map-get? LPRoundData { pool: pool, round: round }))
)

(define-map LPUserRoundData
  {
    pool: principal,
    user: principal,
    round: uint
  }
  {
    amountLP: uint,
    returnLP: uint
  }
)

(define-read-only (getLPUserRoundData (pool principal) (user principal) (round uint))
  (map-get? LPUserRoundData { pool: pool, user: user, round: round })
)

(define-private (getLPUserRoundDataOrDefault (pool principal) (user principal) (round uint))
  (default-to 
    { 
      amountLP: u0,
      returnLP: u0
    }
    (map-get? LPUserRoundData { pool: pool, user: user, round: round }))
)

;; Farming Functions

(define-read-only (getRewardRound (stacksHeight uint))
  (if (>= stacksHeight FIRST_FARMING_BLOCK)
    (some (/ (- stacksHeight FIRST_FARMING_BLOCK) REWARD_ROUND_LENGTH))
    none)
)

(define-read-only (getFirstBlockOfRound (round uint))
  (+ FIRST_FARMING_BLOCK (* REWARD_ROUND_LENGTH round))
)

(define-read-only (getStackingReward (pool principal) (user principal) (round uint) )
  (getEntitledStakingReward user round block-height pool)
)

(define-private (getEntitledStakingReward (user principal) (round uint) (stacksHeight uint) (pool principal))
  (let
    (
      (tempTotalData (getTotalRoundDataOrDefault round))
      (tempLPRoundData (getLPRoundDataOrDefault pool round))
      (tempLPUserRoundData (getLPUserRoundDataOrDefault pool user round))
      (userValue (* (* (get weight tempLPRoundData) (get price tempLPRoundData)) (get amountLP tempLPUserRoundData)))
    )
    (match (getRewardRound stacksHeight)
      currentRound
      (if (or (or (<= currentRound round) (is-eq u0 userValue) (< (var-get farm_end_round) round)))
        {reward: u0, returnLP: (get returnLP tempLPUserRoundData)}
        {reward: (/ (* (getStakingRewardsPerRound round (get reward tempTotalData)) userValue) (get value tempTotalData)),
        returnLP: (get returnLP tempLPUserRoundData)}
      )
      {reward: u0, returnLP: (get returnLP tempLPUserRoundData)}
    )
  )
)

;; ;; STAKING ACTIONS

(define-public (stakeTokens (amount_tokens uint) (pool <liquidity-token>) (lock_period uint) (oracle <oracle-trait>))
  (begin
    (asserts! (isFarmAvailable (contract-of pool)) (err ERR_POOL_NOT_ENROLLED))
    (asserts! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (let (
        (user tx-sender)
        (startHeight block-height)
        (current_round (unwrap! (getRewardRound startHeight) (err ERR_STAKING_NOT_AVAILABLE)))
        (round (+ u1 current_round))
        (tempLPUserData (getLPUserDataOrDefault (contract-of pool) user))
        (tempLPTotalData (getLPTotalDataOrDefault (contract-of pool)))
        (new_list (unwrap! (addItemsToList (get unclaimedList tempLPUserData) lock_period round) (err ERR_UNSTAKELIST_FULL)))
      )
      (asserts! (and (> lock_period u0) (<= lock_period MAX_REWARD_ROUNDS))
        (err ERR_CANNOT_STAKE))
      (asserts! (<= (+ round lock_period) (var-get farm_end_round)) (err ERR_FARM_ENDED))
      (asserts! (> amount_tokens u0) (err ERR_CANNOT_STAKE))
      (unwrap! (contract-call? pool transfer amount_tokens user (as-contract tx-sender) none)
          (err ERR_INSUFFICIENT_BALANCE))
      (map-set LPTotalData
        (contract-of pool)
        {
          amountLP: (+ (get amountLP tempLPTotalData) amount_tokens),
          weight: (get weight tempLPTotalData)
        }
      )
      (map-set LPUserData
        {
          user: user,
          pool: (contract-of pool)
        }
        { 
          amountLP: (+ (get amountLP tempLPUserData) amount_tokens),
          unclaimedList: new_list
        }
      )
      (try! (match (fold stakeTokensClosure REWARD_ROUND_INDEXES (ok {
          user: user,
          amountLP: amount_tokens,
          pool: (contract-of pool),
          first: round,
          last: (+ round lock_period)
        }))
        okValue (ok true)
        errValue (err errValue)
      ))
      (try! (updateRoundStatus pool current_round oracle))
    )
    (ok true)
  )
)

(define-private (stakeTokensClosure (reward_round_idx uint)
  (commitmentResponse (response 
    {
      user: principal,
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
        (round (+ (get first commitment) reward_round_idx))
      )
      (begin
        (if (and (>= round (get first commitment)) (< round (get last commitment)))
          (begin
            (if (is-eq round (- (get last commitment) u1))
              (setTokensStaked (get user commitment) round (get amountLP commitment) (get amountLP commitment) (get pool commitment))
              (setTokensStaked (get user commitment) round (get amountLP commitment) u0 (get pool commitment))
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

(define-private (setTokensStaked (user principal) (round uint) (amount_staked uint) (to_return uint) (pool principal))
  (let
    (
      (tempLPRoundData (getLPRoundDataOrDefault pool round))
      (tempLPUserRoundData (getLPUserRoundDataOrDefault pool user round))
    )
    (map-set LPRoundData
      {
        pool: pool,
        round: round
      }
      (merge tempLPRoundData {
          amountLP: (+ amount_staked (get amountLP tempLPRoundData))
        }
      )
    )
    (map-set LPUserRoundData
      {
        pool: pool,
        user: user,
        round: round
      }
      {
        amountLP: (+ amount_staked (get amountLP tempLPUserRoundData)),
        returnLP: (+ to_return (get returnLP tempLPUserRoundData))
      }
    )
  )
)

(define-public (claimStakingReward (round uint) (pool <liquidity-token>) (oracle <oracle-trait>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (current_round (unwrap! (getRewardRound stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (entitled_reward_res (getEntitledStakingReward user round stacksHeight (contract-of pool)))
      (entitled_reward (get reward entitled_reward_res))
      (to_return (get returnLP entitled_reward_res))
      (tempLPUserData (getLPUserDataOrDefault (contract-of pool) user))
      (tempLPTotalData (getLPTotalDataOrDefault (contract-of pool)))
    )
    (asserts! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! 
      (> current_round round)
      (err ERR_REWARD_ROUND_NOT_COMPLETED))
    (asserts! (or (> to_return u0) (> entitled_reward u0)) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (<= round (var-get farm_end_round)) (err ERR_FARM_ENDED))

    (map-delete LPUserRoundData
      {
        pool: (contract-of pool),
        user: user,
        round: round
      }
    )
    (if (> to_return u0)
      (begin
        (try! (as-contract (contract-call? pool transfer to_return tx-sender user none)))
        (map-set LPUserData
          {
            pool: (contract-of pool),
            user: user
          }
          {   
            amountLP: (- (get amountLP tempLPUserData) to_return),
            unclaimedList: (deleteItemFromList (get unclaimedList tempLPUserData) round)
          }
        )
        (map-set LPTotalData
          (contract-of pool)
          (merge tempLPTotalData {amountLP : (- (get amountLP tempLPTotalData) to_return)})
        )
      )
      (map-set LPUserData
        {
          pool: (contract-of pool),
          user: user
        }
        {   
          amountLP: (get amountLP tempLPUserData),
          unclaimedList: (deleteItemFromList (get unclaimedList tempLPUserData) round)
        }
      )
    )
    (if (> entitled_reward u0)
      (unwrap! (as-contract (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a transfer entitled_reward tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (try! (updateRoundStatus pool current_round oracle))
    (ok true)
  )
)

(define-public (updateLPCurrentRoundStatus (pool <liquidity-token>) (oracle <oracle-trait>))
  (let (
      (stacksHeight block-height)
      (user tx-sender)
      (current_round (unwrap! (getRewardRound stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
    )
    (asserts! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (try! (updateRoundStatus pool current_round oracle))
    (ok true)
  )
)

(define-private (updateRoundStatus (pool <liquidity-token>) (round uint) (oracle <oracle-trait>))
  (let  (
      (tempLPTotalData (getLPTotalDataOrDefault (contract-of pool)))
      (tempTotalRoundData (getTotalRoundDataOrDefault round))
      (tempLPRoundData (getLPRoundDataOrDefault (contract-of pool) round))
      (price (try! (getLPPrice pool oracle)))
      (new_lp_value (* (* (get amountLP tempLPRoundData) (get weight tempLPTotalData)) price))
    )
    (asserts! (isFarmAvailable (contract-of pool)) (err ERR_POOL_NOT_ENROLLED))
    (map-set TotalRoundData
      round
      {
        value : (- (+ (get value tempTotalRoundData) new_lp_value) (get value tempLPRoundData)),
        reward : (var-get reward_per_round)
      }
    )
    (map-set LPRoundData
      {
        pool : (contract-of pool),
        round : round
      }
      {
        value : new_lp_value,
        weight : (get weight tempLPTotalData),
        price : price,
        amountLP: (get amountLP tempLPRoundData)
      }
    )
    (ok true)
  )
)


(define-public (unstakeLP (round uint) (pool <liquidity-token>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (current_round (unwrap! (getRewardRound stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (tempLPUserRoundData (getLPUserRoundDataOrDefault (contract-of pool) user round))
      (tempLPUserData (getLPUserDataOrDefault (contract-of pool) user))
      (tempLPTotalData (getLPTotalDataOrDefault (contract-of pool)))
      (to_return (get returnLP tempLPUserRoundData))
    )
    (asserts! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
    (asserts! (> to_return u0) (err ERR_NOTHING_TO_REDEEM))
    (asserts! (> round (var-get farm_end_round)) (err ERR_FARM_NOT_ENDED))
    (map-set LPUserRoundData
      {
        pool: (contract-of pool),
        user: user,
        round: round
      }
      (merge tempLPUserRoundData {returnLP : u0} )
    )
    (if (> to_return u0)
      (begin
        (try! (as-contract (contract-call? pool transfer to_return tx-sender user none)))
        (map-set LPUserData
          {
            pool: (contract-of pool),
            user: user
          }
          (merge tempLPUserData
            {   
              amountLP: (- (get amountLP tempLPUserData) to_return),
            }
          )
        )
        (map-set LPTotalData
          (contract-of pool)
          (merge tempLPTotalData {amountLP : (- (get amountLP tempLPTotalData) to_return)})
        )
        true
      )
      false
    )
    (ok true)
  )
)



(define-read-only (getStakingRewardsPerRound (target_round uint) (reward_basis uint))
  (let (
    (rounds_per_year u52)
    (year_number (+ (/ target_round rounds_per_year) u1))
    (staking_rewards_divider (pow u2 (/ (- year_number u1) u4)))
    (actual_round_rewards (/ reward_basis staking_rewards_divider))
  )
      (if (>= actual_round_rewards MIN_STAKING_ROUND_REWARDS)
        actual_round_rewards
        MIN_STAKING_ROUND_REWARDS
    )
  )
)


(define-read-only (getFarmingRewardFromList (user principal) (pool principal) (unclaimedList (list 100 uint)))
  (fold getEntitledStakingRewardClosure unclaimedList {
        stakerId: user,
        pool: pool,
        rewardSum: u0
      })
)

(define-private (getEntitledStakingRewardClosure (round uint)
  (commitment 
      {
      stakerId: principal,
      pool: principal,
      rewardSum: uint
    }
  ))
  (merge 
    commitment
    {
      rewardSum: (+ (get rewardSum commitment) (get reward (getEntitledStakingReward (get stakerId commitment) round block-height (get pool commitment))))
    }
  )
)

;; inner functions

;; 1 : STSW - X
;; 2 : X - STSW
;; 3 : STX - X
;; 4 : X - STX
;; 5 : lbtc - X
;; 6 : X - lbtc

(define-private (getLPPrice (pool <liquidity-token>) (oracle <oracle-trait>))
  (let  (
      (lp_data (try! (contract-call? pool get-lp-data)))
      (calc_type (unwrap-panic (map-get? FarmablePools (contract-of pool))))
      (price (unwrap-panic (contract-call? oracle fetch-price (get token calc_type))))
    )
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR_PERMISSION_DENIED))
    (ok
      (if (get type calc_type)
        (/ (/ (* (* u1000000 (get balance-x lp_data)) (get last-price price)) (get shares-total lp_data)) (get decimals price))
        (/ (/ (* (* u1000000 (get balance-y lp_data)) (get last-price price)) (get shares-total lp_data)) (get decimals price))
      )
    )
  )
)    


  ;; this is for claim lists
(define-data-var rem_item uint u0)
(define-private (removeFilter (a uint)) (not (is-eq a (var-get rem_item))))

(define-data-var size_item uint u0)
(define-data-var add_num uint u0)
(define-private (sizeFilter (a uint)) (< a (var-get size_item)))

(define-data-var check_list (list 200 uint) (list ))
(define-private (checkFilter (a uint))
 (is-none (index-of (var-get check_list) a))
)

(define-private (deleteItemFromList (idx_list (list 200 uint)) (ritem uint))
  (begin 
    (var-set rem_item ritem)
    (unwrap-panic (as-max-len? (filter removeFilter idx_list) u200))
  )
)

(define-private (addNumFunc (num uint))
    (+ num (var-get add_num))
)

(define-private (cutSizedList (sizeitem uint) (addnum uint))
  (begin 
    (var-set size_item sizeitem)
    (var-set add_num addnum)
    (map addNumFunc (unwrap-panic (as-max-len? (filter sizeFilter REWARD_ROUND_INDEXES) u64)))
  )
)
(define-private (checkItemFromList (idx_list (list 200 uint)) (new_list (list 64 uint)))
  (begin 
    (var-set check_list idx_list)
    (unwrap-panic (as-max-len? (filter checkFilter new_list) u64))
  )
)

(define-private (addItemsToList (idx_list (list 200 uint)) (sizeitem uint) (addnum uint))
  (as-max-len? (concat idx_list (checkItemFromList idx_list (cutSizedList sizeitem addnum))) u200)
)

(define-private (cutSizedInverseList (sizeitem uint) (addnum uint))
  (begin 
    (var-set size_item sizeitem)
    (var-set add_num addnum)
    (fold inverseNumFunc (unwrap-panic (as-max-len? (filter sizeFilter REWARD_ROUND_INDEXES) u200)) (list ))
  )
)

(define-private (inverseNumFunc (num uint) (idx_list (list 200 uint)))
  (unwrap-panic (as-max-len? (concat (list (+ num (var-get add_num))) idx_list) u200))
)

;; manage 

(define-public (setFarmEndRound (end_round uint)) 
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (ok (var-set farm_end_round end_round))
  )
)

(define-read-only (getFarmEndRound)
  (var-get farm_end_round) 
)


(define-public (addPool (new-pool <liquidity-token>) (type bool) (token (string-ascii 12)))
  (let
    (
      (tokens (try! (contract-call? new-pool get-tokens)))
      (new_pool_principal (contract-of new-pool))
    )
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (if (isFarmAvailable new_pool_principal)
      (map-set FarmablePools new_pool_principal {type: type, token : token})
      (begin
        (var-set lp_count (+ (var-get lp_count) u1))
        (map-set FarmablePoolsIdx (var-get lp_count) new_pool_principal )
        (map-set FarmablePools new_pool_principal {type: type, token : token})
      )
    )
    (ok true)
  )
)

(define-public (removePool (remove-pool <liquidity-token>) (oracle <oracle-trait>)) 
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-qualified-name-by-name "farm-adder"))) (err ERR_PERMISSION_DENIED))
    (try! (changeLPWeight u0 remove-pool oracle))
    (ok (map-delete FarmablePools (contract-of remove-pool)))
  )
)

(define-public (changeRewardAmount (to_change uint))
  (begin
    (asserts! (is-eq contract-caller (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-dao-owner)) (err ERR_PERMISSION_DENIED))
    (var-set reward_per_round to_change)
    (let  (
        (current_round (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)))
        (tempTotalRoundData (getTotalRoundDataOrDefault current_round))
      )
      (map-set TotalRoundData 
        current_round
        {
          value: (get value tempTotalRoundData),
          reward: to_change
        }
      )
    )
    (ok true)
  )
)


(define-public (changeLPWeight (to_change uint) (pool <liquidity-token>) (oracle <oracle-trait>))
  (begin
    (asserts! (is-eq contract-caller (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-dao-owner)) (err ERR_PERMISSION_DENIED))
    (let  (
        (current_round (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)))
        (tempLPTotalData (getLPTotalDataOrDefault (contract-of pool)))
      )
      (map-set LPTotalData 
        (contract-of pool)
        {
          amountLP: (get amountLP tempLPTotalData),
          weight: to_change
        }
      )
      (try! (updateRoundStatus pool current_round oracle))
    )
    (ok true)
  )
)

(define-constant REWARD_CYCLE_INDEXES_REV (list u63 u62 u61 u60 u59 u58 u57 u56 u55 u54 u53 u52 u51 u50 u49 u48 u47 u46 u45 u44 u43 u42 u41 u40 u39 u38 u37 u36 u35 u34 u33 u32 u31 u30 u29 u28 u27 u26 u25 u24 u23 u22 u21 u20 u19 u18 u17 u16 u15 u14 u13 u12 u11 u10 u9 u8 u7 u6 u5 u4 u3 u2 u1 u0))

(define-map UserMigrated
  {
    user: principal,
    pool: principal
  }
  bool
)

(define-read-only (isUserMigrated (pool principal) (user principal))
  (is-none (map-get? UserMigrated { user: user, pool: pool }))
)

(define-public (migrateFromVersion1 (pool principal))
  (let  (
      (user tx-sender)
      (from tx-sender)
      (farm1_end_round (+ (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-farm-end-cycle) u1))
      (tempLPUserData (getLPUserDataOrDefault pool user))
      (unclaimed_list (get unclaimedList (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-staker from pool) (err ERR_NOTHING_TO_REDEEM))))
      (current_round (+ (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)) u1))
      (start_round (if (> farm1_end_round current_round) farm1_end_round current_round))
      (inversedList (cutSizedInverseList (+ (- (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1))) start_round) u1) start_round))
      (migration_result (fold migrateFromVersion1Closure inversedList {
        user: user,
        from: from,
        pool: pool,
        amountLP: u0,
        current: (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)),
      }))
    )
    ;; (print {list: inversedList, start_round : start_round})
    (asserts! (isFarmAvailable pool) (err ERR_POOL_NOT_ENROLLED))
    (asserts! (isUserMigrated pool from) (err ERR_ALREADY_MIGRATED))
    (map-set UserMigrated {user: from, pool: pool} true)
    (map-set LPUserData
      {pool: pool, user: user}
      (merge tempLPUserData 
      {
        unclaimedList : (unwrap! (addItemsToList (get unclaimedList tempLPUserData) 
        (+ 
          (- 
            (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1)))
            start_round)
        u1)
        start_round) (err ERR_UNSTAKELIST_FULL))})
    )
    (ok true)
  )
)


(define-public (migrateFromVersion2 (pool principal) (farm1_end_round uint))
  (let  (
      (user tx-sender)
      (from tx-sender)
      (tempLPUserData (getLPUserDataOrDefault pool user))
      (unclaimed_list (get unclaimedList (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-staker from pool) (err ERR_NOTHING_TO_REDEEM))))
      (current_round (+ (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)) u1))
      (start_round (if (> farm1_end_round current_round) farm1_end_round current_round))
      (inversedList (cutSizedInverseList (+ (- (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1))) start_round) u1) start_round))
      (migration_result (fold migrateFromVersion1Closure inversedList {
        user: user,
        from: from,
        pool: pool,
        amountLP: u0,
        current: (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)),
      }))
    )
    ;; (print {list: inversedList, start_round : start_round})
    (asserts! (isFarmAvailable pool) (err ERR_POOL_NOT_ENROLLED))
    (asserts! (isUserMigrated pool from) (err ERR_ALREADY_MIGRATED))
    ;; (map-set UserMigrated {user: from, pool: pool} true)
    (map-set LPUserData
      {pool: pool, user: user}
      (merge tempLPUserData 
      {
        unclaimedList : (unwrap! (addItemsToList (get unclaimedList tempLPUserData) 
        (+ 
          (- 
            (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1)))
            start_round)
        u1)
        start_round) (err ERR_UNSTAKELIST_FULL))})
    )
    (ok true)
  )
)


(define-private (migrateFromVersion1Closure (round uint)
  (commitment
    {
      user: principal,
      from: principal,
      pool: principal,
      amountLP: uint,
      current: uint,
    }
  ))
  (if (>= (get current commitment) round)
    commitment
    (let  (
      (farm_info (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-staker-at-cycle round (get from commitment) (get pool commitment)))
      (amountLP (match farm_info 
          res (+ (get toReturn res) (get amountLP commitment))
          (get amountLP commitment)
        ))
    )
      (if (> amountLP u0) 
        (begin
          (setTokensStaked (get user commitment) round amountLP u0 (get pool commitment))
          (merge commitment {amountLP : amountLP})
        )
        commitment
      )
    )
  )
)

(define-public (migrateFromVersion1Manual (pool principal) (from principal) (user principal))
  (let  (
      (farm1_end_round (+ (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-farm-end-cycle) u1))
      (tempLPUserData (getLPUserDataOrDefault pool user))
      (unclaimed_list (get unclaimedList (unwrap! (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-farming-v1l get-staker from pool) (err ERR_NOTHING_TO_REDEEM))))
      (current_round (+ (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)) u1))
      (start_round (if (> farm1_end_round current_round) farm1_end_round current_round))
      (inversedList (cutSizedInverseList (+ (- (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1))) start_round) u1) start_round))
      (migration_result (fold migrateFromVersion1Closure inversedList {
        user: user,
        from: from,
        pool: pool,
        amountLP: u0,
        current: (unwrap! (getRewardRound block-height) (err ERR_STAKING_NOT_AVAILABLE)),
      }))
    )
    (asserts! (is-eq contract-caller (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5k get-dao-owner)) (err ERR_PERMISSION_DENIED))
    (asserts! (isFarmAvailable pool) (err ERR_POOL_NOT_ENROLLED))
    (asserts! (isUserMigrated pool from) (err ERR_ALREADY_MIGRATED))
    (map-set UserMigrated {user: from, pool: pool} true)
    (map-set LPUserData
      {pool: pool, user: user}
      (merge tempLPUserData 
      {
        unclaimedList : (unwrap! (addItemsToList (get unclaimedList tempLPUserData) 
        (+ 
          (- 
            (unwrap-panic (element-at unclaimed_list (- (len unclaimed_list) u1)))
            start_round)
        u1)
        start_round) (err ERR_UNSTAKELIST_FULL))})
    )
    (ok true)
  )
)
