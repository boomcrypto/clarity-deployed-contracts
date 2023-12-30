(impl-trait .trait-initializable-farm-v1a.initializable-farm-trait)

(use-trait sip-010-token .sip-010-v1a.sip-010-trait)


(define-constant ERR_UNAUTHORIZED u4201)
(define-constant ERR_INVALID_INPUT u4202)
(define-constant ERR_ALREADY_INITIALIZED u4203)
(define-constant ERR_NOT_INITIALIZED u4204)
(define-constant ERR_INVALID_TOKEN u4206)
(define-constant ERR_STAKINGTOKEN_NOT_ENROLLED u4208)
(define-constant ERR_STAKING_NOT_AVAILABLE u4209)
(define-constant ERR_DAO_ACCESS u4210)
(define-constant ERR_UNSTAKELIST_FULL u4211)
(define-constant ERR_CANNOT_STAKE u4212)
(define-constant ERR_FARM_ENDED u4213)
(define-constant ERR_INSUFFICIENT_BALANCE u4214)
(define-constant ERR_REWARD_ROUND_NOT_COMPLETED u4215)
(define-constant ERR_NOTHING_TO_REDEEM u4216)
(define-constant ERR_TRANSFER_FAIL u4217)
(define-constant ERR_TOO_MANY_GOLD_PASS u4218)
(define-constant ERR_NFT_TRANSFER_FAIL u4219)


(define-constant NULL_PRINCIPAL tx-sender)

(define-data-var is_initialized bool false)

(define-data-var name (string-ascii 32) "")
(define-data-var website (string-utf8 256) u"")

(define-data-var project_token principal tx-sender)
(define-data-var project_lp_token principal tx-sender)

(define-data-var lp_lock_amount uint u0)

(define-data-var contract-owner principal tx-sender)

(define-data-var reward_token_1 principal .null-token-v1a)
(define-data-var reward_token_2 principal .null-token-v1a)
(define-data-var reward_token_3 principal .null-token-v1a)
(define-data-var reward_token_4 principal .null-token-v1a)
   
(define-data-var first_farming_block uint u99999999999999999)
(define-data-var reward_round_length uint u300)
(define-data-var max_farming_rounds uint u15)

(define-data-var nft_end_block uint u99999999999999999)
(define-data-var nft_count_limit uint u30)
(define-data-var nft_count_takes uint u30)

(define-constant MAX_REWARD_ROUNDS u64)  
(define-constant REWARD_ROUND_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63))


(define-public (initialize 
      (name-to-set (string-ascii 32)) (uri-to-set (string-utf8 256))
      (project_token_in <sip-010-token>) (project_lp_token_in <sip-010-token>) (lp_lock_amount_in uint) 
      (reward_token_1_in <sip-010-token>) (reward_token_2_in <sip-010-token>)
      (reward_token_3_in <sip-010-token>) (reward_token_4_in <sip-010-token>)
      (pj_reward_list (list 4 uint)) (pj_lp_reward_list (list 4 uint)) (nft_reward_list (list 4 uint))
      (first_farming_block_in uint) (reward_round_length_in uint) (max_farming_rounds_in uint)
      (nft_end_block_in uint) (nft_count_limit_in uint) (nft_count_takes_in uint)
    )
  (begin
    (print "token-group-farm.init")
    (print contract-caller)
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "one-step-mint-group-farm"))) (err ERR_DAO_ACCESS))
    (asserts! (not (var-get is_initialized)) (err ERR_ALREADY_INITIALIZED))
    (asserts! (< nft_count_takes_in u100) (err ERR_INVALID_INPUT))
    (var-set name name-to-set)
    (var-set website uri-to-set)
    (var-set project_token (contract-of project_token_in))
    (var-set project_lp_token (contract-of project_lp_token_in))
    (var-set lp_lock_amount lp_lock_amount_in)
    (var-set first_farming_block first_farming_block_in)
    (var-set reward_round_length reward_round_length_in)
    (var-set max_farming_rounds max_farming_rounds_in)
    (var-set nft_end_block nft_end_block_in)
    (var-set nft_count_limit nft_count_limit_in)
    (var-set nft_count_takes nft_count_takes_in)
    (var-set contract-owner tx-sender)
    (try! (contract-call? project_lp_token_in transfer lp_lock_amount_in tx-sender (as-contract tx-sender) none))
    (if (is-eq .null-token-v1a (contract-of reward_token_1_in))
      false
      (begin
        (var-set reward_token_1 (contract-of reward_token_1_in))
        (map-set RewardData {
            stakingToken: (contract-of project_token_in),
            rewardToken: (contract-of reward_token_1_in)
          }
          (unwrap-panic (element-at pj_reward_list u0))
        )
        (map-set RewardData {
            stakingToken: (contract-of project_lp_token_in),
            rewardToken: (contract-of reward_token_1_in)
          }
          (unwrap-panic (element-at pj_lp_reward_list u0))
        )
        (map-set RewardData {
            stakingToken: .stackswap-gold-pass-v1b,
            rewardToken: (contract-of reward_token_1_in)
          }
          (unwrap-panic (element-at nft_reward_list u0))
        )
        (try! (contract-call? reward_token_1_in transfer 
          (+ (+ (unwrap-panic (element-at pj_reward_list u0)) (unwrap-panic (element-at pj_lp_reward_list u0))) (unwrap-panic (element-at nft_reward_list u0)))
          tx-sender (as-contract tx-sender) none))
      )
    )    
    (if (is-eq .null-token-v1a (contract-of reward_token_2_in))
      false
      (begin
        (var-set reward_token_2 (contract-of reward_token_2_in))
        (map-set RewardData {
            stakingToken: (contract-of project_token_in),
            rewardToken: (contract-of reward_token_2_in)
          }
          (unwrap-panic (element-at pj_reward_list u1))
        )
        (map-set RewardData {
            stakingToken: (contract-of project_lp_token_in),
            rewardToken: (contract-of reward_token_2_in)
          }
          (unwrap-panic (element-at pj_lp_reward_list u1))
        )
        (map-set RewardData {
            stakingToken: .stackswap-gold-pass-v1b,
            rewardToken: (contract-of reward_token_2_in)
          }
          (unwrap-panic (element-at nft_reward_list u1))
        )
        (try! (contract-call? reward_token_2_in transfer 
          (+ (+ (unwrap-panic (element-at pj_reward_list u1)) (unwrap-panic (element-at pj_lp_reward_list u1))) (unwrap-panic (element-at nft_reward_list u1)))
          tx-sender (as-contract tx-sender) none))
      )
    )      
    (if (is-eq .null-token-v1a (contract-of reward_token_3_in))
      false
      (begin
        (var-set reward_token_3 (contract-of reward_token_3_in))
        (map-set RewardData {
            stakingToken: (contract-of project_token_in),
            rewardToken: (contract-of reward_token_3_in)
          }
          (unwrap-panic (element-at pj_reward_list u2))
        )
        (map-set RewardData {
            stakingToken: (contract-of project_lp_token_in),
            rewardToken: (contract-of reward_token_3_in)
          }
          (unwrap-panic (element-at pj_lp_reward_list u2))
        )
        (map-set RewardData {
            stakingToken: .stackswap-gold-pass-v1b,
            rewardToken: (contract-of reward_token_3_in)
          }
          (unwrap-panic (element-at nft_reward_list u2))
        )
        (try! (contract-call? reward_token_3_in transfer 
          (+ (+ (unwrap-panic (element-at pj_reward_list u2)) (unwrap-panic (element-at pj_lp_reward_list u2))) (unwrap-panic (element-at nft_reward_list u2)))
          tx-sender (as-contract tx-sender) none))
      )
    )
    (if (is-eq .null-token-v1a (contract-of reward_token_4_in))
      false
      (begin
        (var-set reward_token_4 (contract-of reward_token_4_in))
        (map-set RewardData {
            stakingToken: (contract-of project_token_in),
            rewardToken: (contract-of reward_token_4_in)
          }
          (unwrap-panic (element-at pj_reward_list u3))
        )
        (map-set RewardData {
            stakingToken: (contract-of project_lp_token_in),
            rewardToken: (contract-of reward_token_4_in)
          }
          (unwrap-panic (element-at pj_lp_reward_list u3))
        )
        (map-set RewardData {
            stakingToken: .stackswap-gold-pass-v1b,
            rewardToken: (contract-of reward_token_4_in)
          }
          (unwrap-panic (element-at nft_reward_list u3))
        )
        (try! (contract-call? reward_token_4_in transfer 
          (+ (+ (unwrap-panic (element-at pj_reward_list u3)) (unwrap-panic (element-at pj_lp_reward_list u3))) (unwrap-panic (element-at nft_reward_list u3)))
          tx-sender (as-contract tx-sender) none))
      )
    )  
    (var-set is_initialized true)
    (ok u0)
  )
)

(define-map TotalData
  principal ;; stakingToken
  uint
)

(define-read-only (getTotalData (stakingToken principal))
  (map-get? TotalData stakingToken)
)

(define-private (getTotalDataOrDefault (stakingToken principal))
  (default-to 
    u0
    (map-get? TotalData stakingToken))
)
(define-map RewardData
  {
    stakingToken: principal,
    rewardToken: principal
  } ;; Token
  uint
)

(define-read-only (getRewardData (stakingToken principal) (rewardToken principal))
  (map-get? RewardData {
    stakingToken: stakingToken,
    rewardToken: rewardToken
  })
)

(define-private (getRewardDataOrDefault  (stakingToken principal) (rewardToken principal))
  (default-to 
    u0
    (map-get? RewardData {
    stakingToken: stakingToken,
    rewardToken: rewardToken
  }))
)

(define-read-only (getAllDatas)
  (ok
    {
      name: (var-get name),
      website: (var-get website),
      project_token: (var-get project_token),
      project_lp_token: (var-get project_lp_token),
      contract_owner: (var-get contract-owner),
      lp_lock_amount: (var-get lp_lock_amount),
      first_farming_block: (var-get first_farming_block),
      reward_round_length: (var-get reward_round_length),
      max_farming_rounds: (var-get max_farming_rounds),
      nft_end_block: (var-get nft_end_block),
      nft_count_limit: (var-get nft_count_limit),
      nft_count_takes: (var-get nft_count_takes),
      nft_staked_gold: (getTotalDataOrDefault .stackswap-gold-pass-v1b),
      nft_staked_silver: (getTotalDataOrDefault .stackswap-silver-pass-v1b),
      silver_start_block: (+ (var-get first_farming_block) (/ (- (var-get nft_end_block) (var-get first_farming_block)) u4))
    }
  )
)

(define-read-only (getAllRewardData)
  (let (
      (reward_token_1_temp (var-get reward_token_1))
      (reward_token_2_temp (var-get reward_token_2))
      (reward_token_3_temp (var-get reward_token_3))
      (reward_token_4_temp (var-get reward_token_4))
      (project_token_temp (var-get project_token))
      (project_lp_token_temp (var-get project_lp_token))
  )
  (ok
    {
      reward_token_1: reward_token_1_temp,
      reward_token_2: reward_token_2_temp,
      reward_token_3: reward_token_3_temp,
      reward_token_4: reward_token_4_temp,

      project_token_reward: 
      (list 
        (getRewardDataOrDefault project_token_temp reward_token_1_temp)
        (getRewardDataOrDefault project_token_temp reward_token_2_temp)
        (getRewardDataOrDefault project_token_temp reward_token_3_temp)
        (getRewardDataOrDefault project_token_temp reward_token_4_temp)
      ),
      project_lp_token_reward: 
      (list 
        (getRewardDataOrDefault project_lp_token_temp reward_token_1_temp)
        (getRewardDataOrDefault project_lp_token_temp reward_token_2_temp)
        (getRewardDataOrDefault project_lp_token_temp reward_token_3_temp)
        (getRewardDataOrDefault project_lp_token_temp reward_token_4_temp)
      ),
      nft_reward: 
      (list 
        (getRewardDataOrDefault .stackswap-gold-pass-v1b reward_token_1_temp)
        (getRewardDataOrDefault .stackswap-gold-pass-v1b reward_token_2_temp)
        (getRewardDataOrDefault .stackswap-gold-pass-v1b reward_token_3_temp)
        (getRewardDataOrDefault .stackswap-gold-pass-v1b reward_token_4_temp)
      ),
    }
  )
)
)

(define-map UserData
  {
    user: principal,
    stakingToken: principal
  }
  {
    amountToken: uint,
    unclaimedList: (list 200 uint)
  }
)

(define-read-only (getUserData (stakingToken principal) (user principal))
  (map-get? UserData { user: user, stakingToken: stakingToken })
)

(define-private (getUserDataOrDefault (stakingToken principal) (user principal))
  (default-to 
    { 
      amountToken: u0,
      unclaimedList: (list )
    }
    (map-get? UserData { user: user, stakingToken: stakingToken }))
)

(define-map RoundData
  {
    stakingToken: principal,
    round: uint
  }
  uint
)

(define-read-only (getRoundData (stakingToken principal) (round uint))
  (map-get? RoundData { stakingToken: stakingToken, round: round })
)

(define-private (getRoundDataOrDefault (stakingToken principal) (round uint))
  (default-to 
    u0
    (map-get? RoundData { stakingToken: stakingToken, round: round }))
)

(define-map UserRoundData
  {
    stakingToken: principal,
    user: principal,
    round: uint
  }
  {
    amountToken: uint,
    returnToken: uint
  }
)

(define-read-only (getUserRoundData (stakingToken principal) (user principal) (round uint))
  (map-get? UserRoundData { stakingToken: stakingToken, user: user, round: round })
)

(define-private (getUserRoundDataOrDefault (stakingToken principal) (user principal) (round uint))
  (default-to 
    { 
      amountToken: u0,
      returnToken: u0
    }
    (map-get? UserRoundData { stakingToken: stakingToken, user: user, round: round }))
)



;; Farming Functions

(define-read-only (getRewardRound (stacksHeight uint))
  (if (>= stacksHeight (var-get first_farming_block))
    (some (/ (- stacksHeight (var-get first_farming_block)) (var-get reward_round_length)))
    none)
)

(define-read-only (getFirstBlockOfRound (round uint))
  (+ (var-get first_farming_block) (* (var-get reward_round_length) round))
)

(define-read-only (getFarmingReward (stakingToken principal) (user principal) (round uint) )
  (getEntitledStakingReward user round block-height stakingToken)
)

(define-private (getEntitledStakingReward (user principal) (round uint) (stacksHeight uint) (stakingToken principal))
  (let
    (
      (tempRoundData (getRoundDataOrDefault stakingToken round))
      (tempUserRoundData (getUserRoundDataOrDefault stakingToken user round))
    )
    (match (getRewardRound stacksHeight)
      currentRound
      (if (or (<= currentRound round) (is-eq u0 (get amountToken tempUserRoundData)) (< (var-get max_farming_rounds) round) (is-eq u0 tempRoundData))
        {reward1: u0, reward2: u0, reward3: u0, reward4: u0, returnToken: (get returnToken tempUserRoundData)}
        {
          reward1: (getUserRewardP stakingToken (var-get reward_token_1) tempRoundData (get amountToken tempUserRoundData)),
          reward2: (getUserRewardP stakingToken (var-get reward_token_2) tempRoundData (get amountToken tempUserRoundData)),
          reward3: (getUserRewardP stakingToken (var-get reward_token_3) tempRoundData (get amountToken tempUserRoundData)),
          reward4: (getUserRewardP stakingToken (var-get reward_token_4) tempRoundData (get amountToken tempUserRoundData)),
          returnToken: (get returnToken tempUserRoundData)}

      )
      {reward1: u0, reward2: u0, reward3: u0, reward4: u0, returnToken: (get returnToken tempUserRoundData)}
    )
  )
)

(define-private (getUserRewardP (stakingToken principal) (rewardToken principal) (tvl uint) (uvl uint))
  (/ (/ (* (getRewardDataOrDefault stakingToken rewardToken) uvl) tvl) (var-get max_farming_rounds))
)

;; staking, claim

(define-read-only (isTokenAvailable (stakingToken principal))
  (or (is-eq (var-get project_token) stakingToken) (is-eq (var-get project_lp_token) stakingToken))
)

(define-public (stakeTokens (amount_tokens uint) (stakingToken <sip-010-token>) (lock_period uint))
  (begin
    (asserts! (isTokenAvailable (contract-of stakingToken)) (err ERR_STAKINGTOKEN_NOT_ENROLLED))
    (let (
        (user tx-sender)
        (startHeight block-height)
        (current_round (unwrap! (getRewardRound startHeight) (err ERR_STAKING_NOT_AVAILABLE)))
        (round (+ u1 current_round))
        (tempUserData (getUserDataOrDefault (contract-of stakingToken) user))
        (tempTotalData (getTotalDataOrDefault (contract-of stakingToken)))
        (new_list (unwrap! (addItemsToList (get unclaimedList tempUserData) lock_period round) (err ERR_UNSTAKELIST_FULL)))
      )
      (asserts! (and (> lock_period u0) (<= lock_period MAX_REWARD_ROUNDS))
        (err ERR_CANNOT_STAKE))
      (asserts! (<= (+ round lock_period) (+ (var-get max_farming_rounds) u1)) (err ERR_FARM_ENDED))
      (asserts! (> amount_tokens u0) (err ERR_CANNOT_STAKE))
      (unwrap! (contract-call? stakingToken transfer amount_tokens user (as-contract tx-sender) none)
        (err ERR_INSUFFICIENT_BALANCE))
      (map-set TotalData
        (contract-of stakingToken)
        (+ tempTotalData amount_tokens)
      )
      (map-set UserData
        {
          user: user,
          stakingToken: (contract-of stakingToken)
        }
        { 
          amountToken: (+ (get amountToken tempUserData) amount_tokens),
          unclaimedList: new_list
        }
      )
      (try! (match (fold stakeTokensClosure REWARD_ROUND_INDEXES (ok {
          user: user,
          amountToken: amount_tokens,
          stakingToken: (contract-of stakingToken),
          first: round,
          last: (+ round lock_period) ;; round > end round -> end round setting
        }))
        okValue (ok true)
        errValue (err errValue)
      ))
    )
    (ok true)
  )
)

(define-private (stakeTokensClosure (reward_round_idx uint)
  (commitmentResponse (response 
    {
      user: principal,
      amountToken: uint,
      stakingToken: principal,
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
              (setTokensStaked (get user commitment) round (get amountToken commitment) (get amountToken commitment) (get stakingToken commitment))
              (setTokensStaked (get user commitment) round (get amountToken commitment) u0 (get stakingToken commitment))
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

(define-private (setTokensStaked (user principal) (round uint) (amount_staked uint) (to_return uint) (stakingToken principal))
  (let
    (
      (tempRoundData (getRoundDataOrDefault stakingToken round))
      (tempUserRoundData (getUserRoundDataOrDefault stakingToken user round))
    )
    (map-set RoundData
      {
        stakingToken: stakingToken,
        round: round
      }
      (+ amount_staked tempRoundData)
    )
    (map-set UserRoundData
      {
        stakingToken: stakingToken,
        user: user,
        round: round
      }
      {
        amountToken: (+ amount_staked (get amountToken tempUserRoundData)),
        returnToken: (+ to_return (get returnToken tempUserRoundData))
      }
    )
  )
)


(define-public (claimStakingReward (round uint) (stakingToken <sip-010-token>) (reward_token_1_in <sip-010-token>) (reward_token_2_in <sip-010-token>) (reward_token_3_in <sip-010-token>) (reward_token_4_in <sip-010-token>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (current_round (unwrap! (getRewardRound stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
      (entitled_reward_res (getEntitledStakingReward user round stacksHeight (contract-of stakingToken)))
      (to_return (get returnToken entitled_reward_res))
      (tempUserData (getUserDataOrDefault (contract-of stakingToken) user))
      (tempTotalData (getTotalDataOrDefault (contract-of stakingToken)))
    )
    (asserts! (isTokenAvailable (contract-of stakingToken)) (err ERR_STAKINGTOKEN_NOT_ENROLLED))
    (asserts! 
      (> current_round round)
      (err ERR_REWARD_ROUND_NOT_COMPLETED))
    (asserts! 
      (or 
        (> to_return u0) 
        (> (get reward1 entitled_reward_res) u0) 
        (> (get reward2 entitled_reward_res) u0) 
        (> (get reward3 entitled_reward_res) u0) 
        (> (get reward4 entitled_reward_res) u0)
      ) (err ERR_NOTHING_TO_REDEEM))
    (asserts! 
      (and
        (is-eq (var-get reward_token_1) (contract-of reward_token_1_in)) 
        (is-eq (var-get reward_token_2) (contract-of reward_token_2_in)) 
        (is-eq (var-get reward_token_3) (contract-of reward_token_3_in)) 
        (is-eq (var-get reward_token_4) (contract-of reward_token_4_in))
      ) (err ERR_INVALID_TOKEN))

    (asserts! (<= round (var-get max_farming_rounds)) (err ERR_FARM_ENDED))

    (map-delete UserRoundData
      {
        stakingToken: (contract-of stakingToken),
        user: user,
        round: round
      }
    )
    (if (> to_return u0)
      (begin
        (try! (as-contract (contract-call? stakingToken transfer to_return tx-sender user none)))
        (map-set UserData
          {
            stakingToken: (contract-of stakingToken),
            user: user
          }
          {   
            amountToken: (- (get amountToken tempUserData) to_return),
            unclaimedList: (deleteItemFromList (get unclaimedList tempUserData) round)
          }
        )
        (map-set TotalData
          (contract-of stakingToken)
          (- tempTotalData to_return)
        )
      )
      (map-set UserData
        {
          stakingToken: (contract-of stakingToken),
          user: user
        }
        {   
          amountToken: (get amountToken tempUserData),
          unclaimedList: (deleteItemFromList (get unclaimedList tempUserData) round)
        }
      )
    )
    (if (> (get reward1 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_1_in transfer (get reward1 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward2 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_2_in transfer (get reward2 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward3 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_3_in transfer (get reward3 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward4 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_4_in transfer (get reward4 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (ok entitled_reward_res)
  )
)


(define-map UserNFTData
  principal
  {
    amountSilver: uint,
    amountGold: uint,
    amountInCount: uint,
    unclaimedList: (list 50 uint)
  }
)

(define-read-only (getUserNFTData (user principal))
  (map-get? UserNFTData user)
)

(define-private (getUserNFTDataOrDefault (user principal))
  (default-to 
    { 
      amountSilver: u0,
      amountGold: u0,
      amountInCount: u0,
      unclaimedList: (list )
    }
    (map-get? UserNFTData user))
)


(define-private (transferToGolds (id uint))
  (contract-call? .stackswap-gold-pass-v1b transfer id tx-sender (as-contract tx-sender))
)

(define-private (transferToSilvers (id uint))
  (contract-call? .stackswap-silver-pass-v1b transfer id tx-sender (as-contract tx-sender))
)

(define-private (transferFromGolds (id uint))
  (let
    (
      (user tx-sender)
    )
    (as-contract (contract-call? .stackswap-gold-pass-v1b transfer id tx-sender user))
  )
)
(define-private (transferFromSilvers (id uint))
  (let
    (
      (user tx-sender)
    )
    (as-contract (contract-call? .stackswap-silver-pass-v1b transfer id tx-sender user))
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior 
    ok-value result
    err-value (err err-value)
  )
)

(define-public (stakeNFTs (gold_list (list 50 uint)) (silver_list (list 50 uint)))
  (let (
      (user tx-sender)
      (startHeight block-height)
      (tempUserNFTData (getUserNFTDataOrDefault user))
      (tempTotalGold (getTotalDataOrDefault .stackswap-gold-pass-v1b))
      (tempTotalSilver (getTotalDataOrDefault .stackswap-silver-pass-v1b))
      (total_amount (+ tempTotalGold tempTotalSilver))
      (amount_gold (len gold_list))
      (amount_silver (len silver_list))
      (amount_in_count_new 
        (if (>= total_amount (var-get nft_count_limit))
          u0
          (if (<= (+ total_amount (+ amount_gold amount_silver)) (var-get nft_count_limit))
            (+ amount_gold amount_silver)
            (- (var-get nft_count_limit) total_amount)
          )
        )
      )
    )
    (asserts! (and (> startHeight (var-get first_farming_block)) (<= startHeight (var-get nft_end_block)))
      (err ERR_STAKING_NOT_AVAILABLE))
    (asserts! (or (> amount_gold u0) (and (> startHeight (+ (var-get first_farming_block) (/ (- (var-get nft_end_block) (var-get first_farming_block)) u4))) (> amount_silver u0))) (err ERR_CANNOT_STAKE))

    (unwrap! (fold check-err (map transferToGolds gold_list) (ok true)) (err ERR_NFT_TRANSFER_FAIL))
    (unwrap! (fold check-err (map transferToSilvers silver_list) (ok true)) (err ERR_NFT_TRANSFER_FAIL))
    
    (map-set TotalData
      .stackswap-gold-pass-v1b
      (+ tempTotalGold amount_gold)
    )
    (map-set TotalData
      .stackswap-silver-pass-v1b
      (+ tempTotalSilver amount_silver)
    )
    (map-set UserNFTData
      user
      { 
        amountSilver: (+ (get amountSilver tempUserNFTData) amount_silver),
        amountGold: (+ (get amountGold tempUserNFTData) amount_gold),
        amountInCount: (+ (get amountInCount tempUserNFTData) amount_in_count_new),
        unclaimedList: (unwrap! (as-max-len? (concat (get unclaimedList tempUserNFTData) gold_list) u50) (err ERR_TOO_MANY_GOLD_PASS))
      }
    )
    (ok true)
  )
)

(define-private (getUserRewardP2 (rewardToken principal) (tvl uint) (uvl_total uint) (uvl_in_count uint) (nft_count_takes_t uint) (nft_count_limit_t uint))
  (let (
      (reward (getRewardDataOrDefault .stackswap-gold-pass-v1b rewardToken))
      (in_count_sum 
        (if (< tvl nft_count_limit_t)
          (/ (/ (* (* reward nft_count_takes_t) uvl_in_count) tvl) u100)
          (if (is-eq nft_count_limit_t u0)
            (/ (/ (* (* reward nft_count_takes_t) uvl_total) tvl) u100)
          (/ (/ (* (* reward nft_count_takes_t) uvl_in_count) nft_count_limit_t) u100)
          )
        )
      )
      (out_count_sum (/ (/ (* (* reward (- u100 nft_count_takes_t ) ) uvl_total) tvl) u100))
    )
    (+ in_count_sum out_count_sum)
  )
)

(define-read-only (getNFTFarmingReward (user principal) )
  (getEntitledNFTStakingReward user block-height)
)

(define-private (getEntitledNFTStakingReward (user principal) (stacksHeight uint))
  (let
    (
      (silverTotalData (getTotalDataOrDefault .stackswap-silver-pass-v1b))
      (goldTotalData (getTotalDataOrDefault .stackswap-gold-pass-v1b))
      (tvl (+ goldTotalData silverTotalData))
      (tempUserNFTData (getUserNFTDataOrDefault user))
      (uvl (+ (get amountSilver tempUserNFTData) (get amountGold tempUserNFTData)))
      (nft_count_takes_t (var-get nft_count_takes))
      (nft_count_limit_t (var-get nft_count_limit))
    )

    (if (or ;;(<= currentRound round) estimated
      (is-eq u0 (+ (get amountSilver tempUserNFTData) (get amountGold tempUserNFTData))) (is-eq u0 (+ silverTotalData goldTotalData)))
      {reward1: u0, reward2: u0, reward3: u0, reward4: u0, returnNFTS: (get unclaimedList tempUserNFTData)}
      {
        reward1: (getUserRewardP2 (var-get reward_token_1) tvl uvl (get amountInCount tempUserNFTData) nft_count_takes_t nft_count_limit_t),
        reward2: (getUserRewardP2 (var-get reward_token_2) tvl uvl (get amountInCount tempUserNFTData) nft_count_takes_t nft_count_limit_t),
        reward3: (getUserRewardP2 (var-get reward_token_3) tvl uvl (get amountInCount tempUserNFTData) nft_count_takes_t nft_count_limit_t),
        reward4: (getUserRewardP2 (var-get reward_token_4) tvl uvl (get amountInCount tempUserNFTData) nft_count_takes_t nft_count_limit_t),
        returnNFTS: (get unclaimedList tempUserNFTData)}
    )
  )
)

(define-public (claimNFTStakingReward (reward_token_1_in <sip-010-token>) (reward_token_2_in <sip-010-token>) (reward_token_3_in <sip-010-token>) (reward_token_4_in <sip-010-token>))
 (let
    (
      (user tx-sender)
      (entitled_reward_res (getEntitledNFTStakingReward user block-height))
      (to_return (get returnNFTS entitled_reward_res))
      (tempUserNFTData (getUserNFTDataOrDefault user))
    )
    (asserts! 
      (> block-height (var-get nft_end_block))
      (err ERR_REWARD_ROUND_NOT_COMPLETED))
    (asserts! 
      (or 
        (> (len to_return) u0) 
        (> (get reward1 entitled_reward_res) u0) 
        (> (get reward2 entitled_reward_res) u0) 
        (> (get reward3 entitled_reward_res) u0) 
        (> (get reward4 entitled_reward_res) u0)
      ) (err ERR_NOTHING_TO_REDEEM))
    (asserts! 
      (and
        (is-eq (var-get reward_token_1) (contract-of reward_token_1_in)) 
        (is-eq (var-get reward_token_2) (contract-of reward_token_2_in)) 
        (is-eq (var-get reward_token_3) (contract-of reward_token_3_in)) 
        (is-eq (var-get reward_token_4) (contract-of reward_token_4_in))
      ) (err ERR_INVALID_TOKEN))

    (map-delete UserNFTData user)
    (map transferFromGolds to_return)

    (if (> (get reward1 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_1_in transfer (get reward1 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward2 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_2_in transfer (get reward2 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward3 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_3_in transfer (get reward3 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (if (> (get reward4 entitled_reward_res) u0)
      (unwrap! (as-contract (contract-call? reward_token_4_in transfer (get reward4 entitled_reward_res) tx-sender user none)) (err ERR_TRANSFER_FAIL))
      true
    )
    (ok entitled_reward_res)
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

(define-public (reclaimLPs  (project_lp_token_in <sip-010-token>))
 (let
    (
      (stacksHeight block-height)
      (user tx-sender)
      (current_round (unwrap! (getRewardRound stacksHeight) (err ERR_STAKING_NOT_AVAILABLE)))
    )
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err ERR_UNAUTHORIZED))
    (asserts! 
      (> current_round (var-get max_farming_rounds))
      (err ERR_REWARD_ROUND_NOT_COMPLETED))
    (try! (as-contract (contract-call? project_lp_token_in transfer (var-get lp_lock_amount) tx-sender user none)))
    (var-set lp_lock_amount u0)
    (ok true)
  )
)