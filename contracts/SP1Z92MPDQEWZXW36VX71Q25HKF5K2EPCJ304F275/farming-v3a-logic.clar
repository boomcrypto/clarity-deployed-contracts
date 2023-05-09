(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)
(use-trait oracle-trait .stackwap-oracle-trait-v1b.oracle-trait)
(define-constant ERR_ZERO_LP_INPUT u4301)
(define-constant ERR_INSUFFICIENT_LP_BALANCE u4302)
(define-constant ERR_PERMISSION_DENIED u4305)
(define-constant ERR_INVALID_ROUTER u4306)
(define-constant ERR_POOL_NOT_FARMABLE u4307)
(define-constant ERR_FARM_ENDED u4314)
(define-constant ERR_CLAIMABLE_ROUNDS_EXCEEDED u4316)
(define-constant FIRST_FARMING_BLOCK u70843)
(define-constant REWARD_ROUND_LENGTH u504)
(define-constant MAX_REWARD_ROUNDS u64)
(define-constant REWARD_ROUND_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63))
(define-constant MIN_STAKING_ROUND_REWARDS u10000000)
(define-data-var farm_end_round uint u9999999999)
(define-data-var farm_start_round uint u65)

(define-read-only (getFarmingRound (stacksHeight uint))
 (if (>= stacksHeight FIRST_FARMING_BLOCK) (/ (- stacksHeight FIRST_FARMING_BLOCK) REWARD_ROUND_LENGTH) u0))

(define-read-only (getGroupRewardsPerRound (target_round uint) (reward_basis uint))
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

(define-private (claimRewardInner (user principal) (round uint) (amount_staked uint) (pool principal) (group uint))
  (let
    (
        (GroupHistory_ (contract-call? .stackswap-farming-v3-data getGroupHistoryOrDefault group round))
        (LPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault pool round))
        (userTVL (* (* (get Weight LPHistory_) (get Price LPHistory_)) amount_staked))
        (currentRound (getFarmingRound block-height))
    )
    (if (or (<= currentRound round) (is-eq u0 userTVL) (< (var-get farm_end_round) round) (is-eq u0 (get GroupWeightedTVL GroupHistory_)))
        true
    (let (
        (rewardAmt (/ (* (getGroupRewardsPerRound round (get GroupRewardAmt GroupHistory_)) userTVL) (get GroupWeightedTVL GroupHistory_)))
        )
        (if (> rewardAmt u0)
            (begin  
                (try! (contract-call? .stackswap-farming-v3-data transferReward user rewardAmt))
            )
            false
        )
    )
    )
    (ok true)
  )
)

(define-private (claimRewardClosure (reward_round_idx uint)
  (commitmentResponse (response 
    {
      user: principal,
      StakingLockedAmt: uint,
      StartRoundAmt: uint,
      pool: principal,
      first: uint,
      last: uint,
      group: uint,
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
            (if (is-eq round (get first commitment))
                (try! (claimRewardInner (get user commitment) round (get StartRoundAmt commitment) (get pool commitment) (get group commitment)))
                (try! (claimRewardInner (get user commitment) round (get StakingLockedAmt commitment) (get pool commitment) (get group commitment)))
            )
            false
        )
        commitmentResponse
      )
    )
    errValue commitmentResponse
  )
)

(define-private (claimRewardPrivate (pool principal)) 
    (let (
            (user tx-sender)
            (current_round (getFarmingRound block-height))
            (LPUser_ (contract-call? .stackswap-farming-v3-data getLPUserOrDefault pool user))
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault pool))
            (CurLPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault pool current_round))   
            (end_round1 (if 
                (or 
                    (< current_round (get WithdrawEndRound LPUser_)) 
                    (is-eq (get WithdrawEndRound LPUser_) u0)
                )
                current_round
                (+ (get WithdrawEndRound LPUser_) u1)))         
            (end_round (if 
                (< end_round1 (+ u64 (get StartRound LPUser_)))
                end_round1
                (+ u64 (get StartRound LPUser_))
                ))         
        )
        (asserts! (contract-call? .stackswap-farming-v3-data isFarmAvailable  pool) (err ERR_POOL_NOT_FARMABLE))
        (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
        (if (and (> (+ (get StakingLockedAmt LPUser_) (get StartRoundAmt LPUser_)) u0) (>= end_round (+ (get StartRound LPUser_) u1)))
            (begin
                (try! (contract-call? .stackswap-farming-v3-data setLPUser
                    pool
                    user
                    (merge LPUser_ {
                        StartRound: end_round,
                        StartRoundAmt: (get StakingLockedAmt LPUser_),
                    })
                ))
                (try! (match (fold claimRewardClosure REWARD_ROUND_INDEXES (ok {
                        user: user,
                        StakingLockedAmt: (get StakingLockedAmt LPUser_),
                        StartRoundAmt: (get StartRoundAmt LPUser_),
                        pool: pool,
                        first: (get StartRound LPUser_),
                        last: end_round,
                        group: (get Group LP_),
                    }))
                    okValue (ok true)
                    errValue (err errValue)
                ))
                (ok (contract-call? .stackswap-farming-v3-data getLPUserOrDefault pool user))
            )
            (ok LPUser_)
        )

        
    )
)

(define-public (stake (pool <liquidity-token>) (amount uint) (oracle <oracle-trait>))
    (let (
            (user tx-sender)
            (current_round (getFarmingRound block-height))
            (start_round (var-get farm_start_round)) 
            (round (if (> start_round current_round) start_round current_round))
            (LPUser_ (try! (claimRewardPrivate (contract-of pool))))
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault (contract-of pool)))
            (CurLPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault (contract-of pool) round))
        )
        (asserts! (contract-call? .stackswap-farming-v3-data isFarmAvailable  (contract-of pool)) (err ERR_POOL_NOT_FARMABLE))
        (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
        (asserts! (<= round (var-get farm_end_round)) (err ERR_FARM_ENDED))
        (asserts! (> amount u0) (err ERR_ZERO_LP_INPUT))
        (asserts! (or (is-eq (get StartRound LPUser_) u0) (is-eq (get StartRound LPUser_) current_round)) (err ERR_CLAIMABLE_ROUNDS_EXCEEDED))

        (unwrap! (contract-call? pool transfer amount user .stackswap-farming-v3-data none) (err ERR_INSUFFICIENT_LP_BALANCE))
        (try! (contract-call? .stackswap-farming-v3-data setLPUser
             (contract-of pool) user
            (merge LPUser_ {
                ViewAmt: (+ (get ViewAmt LPUser_) amount),
                StakingLockedAmt: (+ (get StakingLockedAmt LPUser_) amount),
                StartRound: round,
            })
        ))
        (try! (contract-call? .stackswap-farming-v3-data setLPHistory 
             (contract-of pool) round
            (merge CurLPHistory_ {
                NextDepositAmt: (+ (get NextDepositAmt CurLPHistory_) amount),
            })
        ))
        (try! (updateRoundStatus pool current_round oracle))
        (ok true)
    )
)

(define-public (withdrawDirect (pool <liquidity-token>) (amount uint) (oracle <oracle-trait>))
    (let (
            (user tx-sender)
            (current_round (getFarmingRound block-height))
            (start_round (var-get farm_start_round)) 
            (round (if (> start_round current_round) start_round current_round))
            (LPUser_ (try! (claimRewardPrivate (contract-of pool))))
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault (contract-of pool)))
            (LPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault (contract-of pool) round))
        )
        (asserts! (contract-call? .stackswap-farming-v3-data isFarmAvailable  (contract-of pool)) (err ERR_POOL_NOT_FARMABLE))
        (asserts! (contract-call? .stackswap-security-list-v1a is-secure-router-or-user contract-caller) (err ERR_INVALID_ROUTER))
        (asserts! (or (> round (get WithdrawEndRound LPUser_)) (> round (var-get farm_end_round))) (err ERR_FARM_ENDED)) 
        (asserts! (<= amount (get StakingLockedAmt LPUser_)) (err u9990))
        (asserts! (or (is-eq (get StartRound LPUser_) u0) (is-eq (get StartRound LPUser_) current_round)) (err ERR_CLAIMABLE_ROUNDS_EXCEEDED))
        (if (<= amount (- (get StakingLockedAmt LPUser_) (get StartRoundAmt LPUser_)) )
            (begin  
                (try! (contract-call? .stackswap-farming-v3-data setLPUser
                    (contract-of pool)
                    user
                    (merge LPUser_ {
                        ViewAmt: (- (get ViewAmt LPUser_) amount),
                        StakingLockedAmt: (- (get StakingLockedAmt LPUser_) amount),
                    })
                ))
                (try! (contract-call? .stackswap-farming-v3-data setLPHistory 
                    (contract-of pool)
                    round
                    (merge LPHistory_ {
                        NextDepositAmt: (- (get NextDepositAmt LPHistory_) amount),
                    })
                ))
            )
            (begin
                (try! (contract-call? .stackswap-farming-v3-data setLPUser
                    (contract-of pool)
                    user
                    (merge LPUser_ {
                        ViewAmt: (- (get ViewAmt LPUser_) amount),
                        StakingLockedAmt: (- (get StakingLockedAmt LPUser_) amount),
                        StartRoundAmt: (- (get StartRoundAmt LPUser_) (- amount (- (get StakingLockedAmt LPUser_) (get StartRoundAmt LPUser_)))),
                    })
                ))
                (try! (contract-call? .stackswap-farming-v3-data setLPHistory 
                    (contract-of pool)
                    round
                    (merge LPHistory_ {
                        LockedAmt: (- (get LockedAmt LPHistory_) (- amount (- (get StakingLockedAmt LPUser_) (get StartRoundAmt LPUser_)))),
                        NextDepositAmt: (- (get NextDepositAmt LPHistory_) (- (get StakingLockedAmt LPUser_) (get StartRoundAmt LPUser_))),
                    })
                ))
            )
        )

        (if (is-eq amount (get StakingLockedAmt LPUser_))
            (try! (contract-call? .stackswap-farming-v3-data deleteLPUser
                (contract-of pool) user
            ))
            false
        )
        (try! (contract-call? .stackswap-farming-v3-data transferAsset pool user amount))
        (try! (updateRoundStatus pool current_round oracle))
        (ok true)
    )
)

(define-private (updateRoundStatus (pool <liquidity-token>) (round uint) (oracle <oracle-trait>))
  (let  (
        (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault (contract-of pool)))
        (Group_ (contract-call? .stackswap-farming-v3-data getGroupOrDefault (get Group LP_)))
        (GroupHistory_ (contract-call? .stackswap-farming-v3-data getGroupHistoryOrDefault (get Group LP_) round))
        (LPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault (contract-of pool) round))
        (price (try! (getLPPrice pool oracle)))
        (new_lp_TVL (* (* (get LockedAmt LPHistory_) (get CurWeight LP_)) price))
    )
    (asserts! (contract-call? .stackswap-farming-v3-data isFarmAvailable  (contract-of pool)) (err ERR_POOL_NOT_FARMABLE))
    (try! (contract-call? .stackswap-farming-v3-data setGroupHistory
         (get Group LP_) round
        {
            GroupWeightedTVL : (- (+ (get GroupWeightedTVL GroupHistory_) new_lp_TVL) (get WeightedTVL LPHistory_)),
            GroupRewardAmt : (get CurRewardAmt Group_)
        }
    ))
    (try! (contract-call? .stackswap-farming-v3-data setLPHistory
        (contract-of pool) round 
        (merge LPHistory_
            {
                Price: price,
                Weight: (get CurWeight LP_),
                WeightedTVL: new_lp_TVL,
            }
        )))
    (ok true)
  )
)

(define-public (claimReward (pool <liquidity-token>) (oracle <oracle-trait>))
    (begin
        (try! (claimRewardPrivate (contract-of pool)))
        (try! (updateRoundStatus pool (getFarmingRound block-height) oracle))
        (ok true)
    )
)

(define-public (updateCurrentRoundStatus (pool <liquidity-token>) (oracle <oracle-trait>))
    (begin
        (try! (updateRoundStatus pool (getFarmingRound block-height) oracle))
        (ok true)
    )
)

(define-read-only (getFirstBlockOfRound (round uint)) (+ FIRST_FARMING_BLOCK (* REWARD_ROUND_LENGTH round)))

(define-private (getLPPrice (pool <liquidity-token>) (oracle <oracle-trait>))
  (let  (
      (lp_data (try! (contract-call? pool get-lp-data)))
      (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault (contract-of pool)))
      (price (unwrap-panic (contract-call? oracle fetch-price (get QuoteToken LP_))))
    )
    (asserts! (is-eq (contract-of oracle) (unwrap-panic (contract-call? .stackswap-dao-v5k get-qualified-name-by-name "oracle-l"))) (err ERR_PERMISSION_DENIED))
    (ok
      (if (get QuoteSide LP_)
        (/ (/ (* (* u1000000 (get balance-x lp_data)) (get last-price price)) (get shares-total lp_data)) (get decimals price))
        (/ (/ (* (* u1000000 (get balance-y lp_data)) (get last-price price)) (get shares-total lp_data)) (get decimals price))
      )
    )
  )
)    


(define-private (getUserStakingRewardAtRound_ (group uint) (pool principal) (round uint) (userStartRound uint) (userStartRoundAmt uint) (userStakingLockedAmt uint))
  (let
    (
        (GroupHistory_ (contract-call? .stackswap-farming-v3-data getGroupHistoryOrDefault group round))
        (LPHistory_ (contract-call? .stackswap-farming-v3-data getLPHistoryOrDefault pool round))
        (userTVL (* (* (get Weight LPHistory_) (get Price LPHistory_)) (if (is-eq round userStartRound)
            userStartRoundAmt userStakingLockedAmt
        )))
        (current_round (getFarmingRound block-height))
    )
    (if (or (<= current_round round) (is-eq u0 userTVL) (< (var-get farm_end_round) round) (< round userStartRound) (is-eq u0 (get GroupWeightedTVL GroupHistory_)))
        u0
        (/ (* (getGroupRewardsPerRound round (get GroupRewardAmt GroupHistory_)) userTVL) (get GroupWeightedTVL GroupHistory_))
    )

  )
)

(define-read-only (getUserStakingRewardAtRound (pool principal) (user principal) (round uint))
    (let
        (
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault pool))
            (LPUser_ (contract-call? .stackswap-farming-v3-data getLPUserOrDefault pool user))
        )
        (ok (getUserStakingRewardAtRound_ (get Group LP_) pool round (get StartRound LPUser_) (get StartRoundAmt LPUser_) (get StakingLockedAmt LPUser_)))
    )
)

(define-private (getEntitledStakingRewardClosure (round uint)
    (commitment 
        {   
            group: uint,
            pool: principal,
            rewardSum: uint,
            userStartRound: uint,
            userStartRoundAmt: uint, 
            userStakingLockedAmt: uint,
        }
    ))
    (merge 
        commitment
        {
            rewardSum: (+ (get rewardSum commitment) (getUserStakingRewardAtRound_ (get group commitment) (get pool commitment) round (get userStartRound commitment) (get userStartRoundAmt commitment) (get userStakingLockedAmt commitment)))
        }
    )
)

(define-read-only (getFarmingRewardFromList (user principal) (pool principal) (unclaimedList (list 64 uint)))
    (let
        (
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault pool))
            (LPUser_ (contract-call? .stackswap-farming-v3-data getLPUserOrDefault pool user))
        )
    (ok (fold getEntitledStakingRewardClosure unclaimedList {
            group: (get Group LP_),
            pool: pool,
            rewardSum: u0,  
            userStartRound: (get StartRound LPUser_),
            userStartRoundAmt: (get StartRoundAmt LPUser_), 
            userStakingLockedAmt: (get StakingLockedAmt LPUser_),
        }))
    )
)

(define-private (is-dao (user principal)) 
    (ok (asserts! (is-eq user (contract-call? .stackswap-dao-v5k get-dao-owner)) (err ERR_PERMISSION_DENIED))))


(define-public (addPool (new-pool <liquidity-token>) (quoteSide bool) (quoteToken (string-ascii 12)) (group uint) (weight uint)) 
    (let 
        (
            (new_pool_principal (contract-of new-pool))
        ) 
        (try! (is-dao contract-caller)) 
        (try! (contract-call? .stackswap-farming-v3-data setLP new_pool_principal     {
                Group: group,
                CurWeight: weight,
                QuoteSide: quoteSide,
                QuoteToken: quoteToken,
            }))
        (ok true)))



(define-public (removePool (remove-pool <liquidity-token>) (oracle <oracle-trait>)) 
  (begin
    (try! (is-dao contract-caller))  
    (try! (changeLPWeight remove-pool u0 oracle))
    (ok (try! (contract-call? .stackswap-farming-v3-data deleteLP (contract-of remove-pool))))
  )
)

(define-public (changeRewardAmount (group uint) (to_change uint))
    (let  (
            (current_round (getFarmingRound block-height))
            (GroupHistory_ (contract-call? .stackswap-farming-v3-data getGroupHistoryOrDefault group current_round))
        )
        (try! (is-dao contract-caller))  
        (try! (contract-call? .stackswap-farming-v3-data setGroup group
            {
                CurRewardAmt: to_change,
            }
        ))
       (try! (contract-call? .stackswap-farming-v3-data setGroupHistory group current_round
            (merge GroupHistory_
                {
                    GroupRewardAmt: to_change
                }
             )  
        ))
        (ok true)
    )
)


(define-public (changeLPWeight (pool <liquidity-token>) (to_change uint) (oracle <oracle-trait>))
    (let  (
            (current_round (getFarmingRound block-height))
            (LP_ (contract-call? .stackswap-farming-v3-data getLPOrDefault (contract-of pool)))
        )
        (try! (is-dao contract-caller))  

        (try! (contract-call? .stackswap-farming-v3-data setLP 
            (contract-of pool)
            (merge LP_
                {
                    CurWeight: to_change
                })
        ))
        (try! (updateRoundStatus pool current_round oracle))
        (ok true)
    )
)

(define-public (setFarmEndRound (end_round uint)) 
  (begin
    (try! (is-dao contract-caller))  
    (ok (var-set farm_end_round end_round))
  )
)

(define-read-only (getFarmEndRound)
  (var-get farm_end_round) 
)

(define-public (setFarmStartRound (start_round uint)) 
  (begin
    (try! (is-dao contract-caller))  
    (ok (var-set farm_start_round start_round))
  )
)

(define-read-only (getFarmStartRound)
  (var-get farm_start_round) 
)
