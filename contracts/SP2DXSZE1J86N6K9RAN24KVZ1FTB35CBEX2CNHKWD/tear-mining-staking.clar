;; TEAR Mining & Staking Contract
;; The contract that dictates the rules of mining STX for the distribution of TEAR & staking TEAR for STX
;; Written by UncleMantis, reviewed by ClarityClear/Setzeus & _____

;; Mining
;; 1.9B TEAR will minted as mining rewards until approximately ~2208. There will be an initial ~1.5 year-long bonus reward period that'll distribute 30% of TEAR.
;; Followed by the first halving distribution of 15%. This & the next 3 halving cycles are all approximately 4 years long (210240 blocks)
;; After the 4th halving, the mining reward will be 1% of remaining TEAR every 4 years / halving. This should conclude around ~2208

;; Staking
;; After block 95166 owners of TEAR will be able to stake TEAR for up to 32 cycles/periods of length 2016 blocks (~ 2 weeks)
;; When staking is active, 80% of the STX mined in any block is sent to a staking pool that builds up every cycle

;; Need to replace test addresses with real addresses

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars, & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;
;; Principals ;;
;;;;;;;;;;;;;;;;

;; standard principal of contract deployment transaction sender
(define-constant DEPLOYER tx-sender)

;; representing this contract's principle to be used for the temporary holding of STX and TEAR tokens to be sent and retrived throughout staking
(define-constant STAKING_POOL (as-contract tx-sender))

;; representing the principle address in which to send percentages of mining concenesus submissions to be used for ... to-do ...
(define-constant COMMUNITIES_FUND 'SP1KDKW9YNVY8J5A4ATZR9SGYK5W4S6YYRAKHPJCR)

;; representing the principle address in which to send percentages of mining concenesus submissions to be used for ... to-do ...
(define-constant TEAR_FUND 'SP3H75Q8J7TETSHB1J9A78FHD7037CQVJ61J87FPT)

;; percentage represented as a integer to be used in calculating the percentage of a mining block commitment to be distributed to the staking pool
(define-constant STAKING_POOL_PERCENTAGE u80)

;; percentage represented as a integer to be used in calculating the percentage of a mining block commitment to be distributed to the tear fund
(define-constant TEAR_FUND_PERCENTAGE u5)


;;;;;;;;;;;;;;;;;
;; Mining Cons ;;
;;;;;;;;;;;;;;;;;

;; block height at which first reward block can be mined and start of the first 1.5 year bonus reward cycle
(define-constant MINING_FIRST_BLOCK u68958)

;; length of the origin bonus mining reward cycle represented as blocks or approximately 1.5 years
(define-constant BLOCKS_PER_INITIAL_DISTRIBUTION u78840)

;; block height at which first staking cycle begins & TEAR begins collecting their fee of 5%
(define-constant STAKING_AND_TEAR_FUNDING_FIRST_BLOCK u95166)

;; block height at which the halving of the first mining reward is split in half
(define-constant HALVING_FIRST_BLOCK (+ BLOCKS_PER_INITIAL_DISTRIBUTION MINING_FIRST_BLOCK))

;; length of a mining reward halving cycle represented as blocks or approximately 4 years
(define-constant BLOCKS_PER_HALVING_DISTRIBUTION u210240)

;; number of integers represented as blocks required between reward block to be claimed and the block height at which the claim is being called
(define-constant MIN_BLOCK_CONFIRMS_TO_CLAIM_REWARD u200)

;;;;;;;;;;;;;;;;;;
;; Staking Cons ;;
;;;;;;;;;;;;;;;;;;

;; length of a staking cycle represented as blocks or approximately 2 weeks
(define-constant BLOCKS_PER_CYCLE u2016)

;; maximum length of a staking lockup represented as cycles
(define-constant MAX_CYCLES_PER_LOCK u32)

;; lock indxes for staking??
(define-constant LOCK_INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31))


;;;;;;;;;;;;;;;;
;; Error Cons ;;
;;;;;;;;;;;;;;;;

;; mining bid or staking delegation amount is less than the minimum commitment value
(define-constant ERR_INSUFFICIENT_COMMITMENT (err u2000))

;; miner has already bid on a specified block
(define-constant ERR_MINER_HAD_ALREADY_COMMITED_TO_BLOCK (err u2001))

;; reward has already been claimed for specified block
(define-constant ERR_BLOCK_REWARD_ALREADY_CLAIMED (err u2002))

;; reward maturity block not valid
(define-constant ERR_NO_VRF_SEED_FOUND (err u2003))

;; miner did not bid in block that reward is being claimed
(define-constant ERR_MINER_DID_NOT_COMMIT_TO_BLOCK (err u2004))

;; reward maturity block does not match block-height of claim submission
(define-constant ERR_CLAIMED_BEFORE_MATURITY (err u2005))

;; miner did not win the reward of block being claimed
(define-constant ERR_MINER_DID_NOT_WIN (err u2006))

;; unable to mint reward
(define-constant ERR_UNABLE_TO_MINT_REWARD (err u2010))

;; block-height is less than mining start block
(define-constant ERR_MINING_NOT_ACTIVE (err u2011))

;; staking is not available at given block-height
(define-constant ERR_STAKING_NOT_AVAILABLE (err u2012))

;; staker is claiming rewards for a cycle in progress
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED (err u2013))

;; staker is claiming a cycle that has neither tokens to return or stx to reward
(define-constant ERR_NOTHING_TO_REDEEM (err u2014))

;; number of sequencil cycles to stack is gTEARer than the maximum allowed or is zero
(define-constant ERR_LOCK_CYCLES_NOT_VALID (err u2015))

;; staking is not active at given block-height
(define-constant ERR_STAKING_NOT_ACTIVE (err u2016))

(define-constant ERR_REWARD_PAYOUT (err u2017))

(define-constant ERR_PROBLEM_REWARDING_TOKEN (err u2018))

;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;

;; The token max supply which is updated by the private function (get-token-max-supply)
(define-data-var tokenMaxSupply (optional uint) none)

;; Map the tracks mining activity by miner/principal & block
(define-map RewardBlockMiningCommit {block: uint, miner: principal}
  {
    amountUstx: uint,
    low: uint,
    high: uint
  }
)

;; Map that tracks the total stx in a mining/mined block, block -> uSTX
(define-map RewardBlockMiningTotal uint uint)

;; Map the tracks the miner that won/claimed a mined block, block -> principal
(define-map RewardBlockClaimed uint {winner: principal, amountUTEAR: uint})

;; Map that tracks staking commitments by cycle & staker
(define-map RewardCycleStakingCommit {cycle: uint, staker: principal}
  {
    amountUTEAR: uint,
    releaseUTEAR: uint
  }
)

;; Map that tracks the total TEAR & future STX rewards by cycle
(define-map RewardCycleStakingTotal uint
  {
    totalUTEAR: uint,
    totalUstx: uint
  }
)

;; Map that tracks temporary staking allocation from mining (aka what happens if a cycle doesn't have stakers but later does)
(define-map RewardCycleBackloggedStakingAllocation uint uint)

;; Map that tracks every user mine & user stake
;; Mine list is a list of blockheights mined by user
;; Stake list is a list of cycle numbers (not heights) staked by user
(define-map principal-data principal {mine: (list 5000 uint), stake: (list 5000 uint)})


;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Get block mining data
(define-read-only (get-block-mining-data (block uint)) 
  (let 
    (
      (stx-mined (default-to u0 (map-get? RewardBlockMiningTotal block)))
      (TEAR-rewarded (map-get? RewardBlockClaimed block))
    )

    ;; Check if reward has been claimed
    (if (is-some TEAR-rewarded)
      ;; has been claimed
      {
        stx-mined: stx-mined,
        TEAR-rewarded: (get winner TEAR-rewarded),
        TEAR-winner: (get amountUTEAR TEAR-rewarded)
      }
      ;; has not been claimed
      {
        stx-mined: stx-mined,
        TEAR-rewarded: none,
        TEAR-winner: none
      }
    )
  )
)

;; Get all user mining data
(define-read-only (get-user-mining (user principal)) 
  (let 
    (
      (user-data (unwrap! (map-get? principal-data user) (err "err-no-user-mines")))
      (user-mining (get mine user-data))
    )
    (ok (map get-all-principal-mining-data user-mining))
  )
)

(define-private (get-all-principal-mining-data (height uint)) 
  (let
    (
      (height-mining-map (get-reward-block-mining-commit height tx-sender))
      (height-mining-amount (get amountUstx height-mining-map))
    ) 
    {
      block: height,
      amountUstx: height-mining-amount,
    }
  )
)

;; Get all user staking data
(define-read-only (get-user-staking (user principal)) 
  (let 
    (
      (user-data (unwrap! (map-get? principal-data user) (err "err-no-user-stakes")))
      (user-staking (get stake user-data))
    )
    (ok (map get-all-principal-staking-data user-staking))
  )
)

(define-private (get-all-principal-staking-data (cycle uint)) 
  (let
    (
      (cycle-stake-map (get-reward-cycle-staking-commit-read cycle tx-sender))
      (cycle-stake-amount (get amountUTEAR cycle-stake-map))
    ) 
    {
      cycle: cycle,
      amountUstx: cycle-stake-amount,
    }
  )
)

;; Get current staking cycle index
(define-read-only (get-current-cycle-index)
  (get-staking-reward-cycle block-height)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Mining Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mine the next block
(define-public (mine-next-block (ustxAmount uint))
  (mine-many-blocks (list ustxAmount))
)

;; Mine many blocks (up to 200)
(define-public (mine-many-blocks (ustxAmounts (list 200 uint)))
  (match (fold commit-reward-block ustxAmounts (ok { communitiesTotal: u0, stakingTotal: u0, tearTotal: u0, block: block-height}))
    returnOk
    (let
      (
        (amounttear (get tearTotal returnOk))
        (amountStaking (get stakingTotal returnOk))
        (amountCommunities (get communitiesTotal returnOk))
      )
      (if (> amounttear u0)
        (try! (stx-transfer? amounttear tx-sender TEAR_FUND))
        false
      )
      (if (> amountStaking u0)
        (try! (stx-transfer? amountStaking tx-sender STAKING_POOL))
        false
      )
      (ok (try! (stx-transfer? amountCommunities tx-sender COMMUNITIES_FUND)))
    )
    returnErr (err u99999)
  )
)

;; Public get reward function for use when user is claiming the reward
(define-public (get-reward (block uint))
  (let
    (
      (initialRewardDistribution
        (/ (* u30 (get-token-max-supply)) u100)
      )
      (blockReward
        (begin
          (asserts! (>= block MINING_FIRST_BLOCK) (ok u0))
          (asserts! (>= block HALVING_FIRST_BLOCK) (ok (/ initialRewardDistribution BLOCKS_PER_INITIAL_DISTRIBUTION)))
          (if (>= (/ (- block HALVING_FIRST_BLOCK) BLOCKS_PER_HALVING_DISTRIBUTION) u4)
            (/ (/ (get-token-max-supply) u100) BLOCKS_PER_HALVING_DISTRIBUTION)
            (/ (/ initialRewardDistribution u2) (* BLOCKS_PER_HALVING_DISTRIBUTION (pow u2 (/ (- block HALVING_FIRST_BLOCK) BLOCKS_PER_HALVING_DISTRIBUTION))))
          )
        )
      )
    )
    (ok blockReward)
  )
)

;; Allows miners to check & claim blocks they previously committed to
(define-public (claim-reward-block (block uint))
  (let
    (
      (miner tx-sender)
      (validationBlock (+ block MIN_BLOCK_CONFIRMS_TO_CLAIM_REWARD))
      (totalUstx (get-reward-block-mining-total block))
      (lowRange (get low (get-reward-block-mining-commit block miner)))
      (highRange (get high (get-reward-block-mining-commit block miner)))
      (vrfSeed (unwrap! (contract-call? .vrf get-random-uint-at-block validationBlock) ERR_NO_VRF_SEED_FOUND))
      (randomNumber (mod vrfSeed totalUstx))
      (reward (unwrap! (get-reward block) ERR_REWARD_PAYOUT))
    )
    (asserts! (> block-height validationBlock) ERR_CLAIMED_BEFORE_MATURITY)
    (asserts! (and (>= randomNumber lowRange) (<= randomNumber highRange)) ERR_MINER_DID_NOT_WIN)
    (asserts! (is-none (map-get? RewardBlockClaimed block)) ERR_BLOCK_REWARD_ALREADY_CLAIMED)
    (map-insert RewardBlockClaimed block {winner: miner, amountUTEAR: reward})
    (ok (match (as-contract (contract-call? .tear-token mint reward miner))
      returnOk reward
      returnErr u0
    ))
  )
)

;;;;;;;;;; Private Helper Mining Functions ;;;;;;;;;;;;

;; Helper function that allocates the specific list mining commitments to each block & prepares to transfer all stx when finished
(define-private (commit-reward-block (ustxAmount uint)
  (return (response
    {
      communitiesTotal: uint,
      stakingTotal: uint,
      tearTotal: uint,
      block: uint
    }
    uint
  )))

  (match return
    returnOk
    (let
      (
        (communitiesTotal (get communitiesTotal returnOk))
        (stakingTotal (get stakingTotal returnOk))
        (tearTotal (get tearTotal returnOk))
        (block (get block returnOk))

        (current-cycle (default-to u0 (get-staking-reward-cycle block-height)))
        (cycle (default-to u0 (get-staking-reward-cycle block)))

        (rewardCycleStakingTotal (get-reward-cycle-staking-total cycle))
        (rewardBlockMiningCommit (get-reward-block-mining-commit block tx-sender))
        (backloggedStakingAllocation (default-to u0 (map-get? RewardCycleBackloggedStakingAllocation cycle)))

        (cycleTotalUTEAR (get totalUTEAR rewardCycleStakingTotal))
        (cycleTotalUstx (get totalUstx rewardCycleStakingTotal))
        (blockTotalUstx (get-reward-block-mining-total block))

        ;; the problem is:
        ;; a miner can mine for up to 200 blocks
        ;; stake cycles are 2016 blocks
        ;; it's very unlikely, but sometimes a miner might mine for 200 blocks that spans not one but TWO stake cycles: the current cycle & the NEXT cycle
        ;; in this case, when allocating for stakingAmount in the NEXT cycle, there might not be any stakers yet* so we don't allocate to staking
        ;; however, someone might then stake BEFORE that next staking cycle starts/locks up...now staking pool is missing what should've been allocated

        ;; notes
        ;; principals can't stake once a cycle has started...so as soon as block-height = block-height of new cycle all backloggedAllocation should either be moved to staked OR left in community
        ;; staking pool is this contract, aka (as-contract tx-sender), while communities fund another principal...therefore all backloggedAllocation should be temporarily preserved in STAKING
        ;; if there are no still stakers just before next cycle starts...move all backloggedAllocation from Staking to communities fund
        ;; the last block before a new cycle starts all backloggedAllocation should be cleared

        ;; is staking active?
        (stakingAmount
          (if (> block STAKING_AND_TEAR_FUNDING_FIRST_BLOCK)

              ;; staking is active, checking if target block cycle = current block cycle
              (if (is-eq current-cycle cycle)

                ;; in current cycle
                (begin
                  ;; check for existing backloggedAllocation, just in case we need to clear it
                  (if (> backloggedStakingAllocation u0)
                      ;; there is a backloggedStaking allocation (aka there aren't & won't be any stakers in the current cycle), need to transfer allocation, update RewardCycleBackloggedStakingAllocation to zero      & proceed normally
                      (begin
                        (as-contract (try! (stx-transfer? backloggedStakingAllocation (as-contract tx-sender) COMMUNITIES_FUND)))
                        (map-set RewardCycleBackloggedStakingAllocation cycle u0)
                      )
                      ;; no backloggedStakingAllocation, proceed normally
                      false
                  )
                  (if (> cycleTotalUTEAR u0)
                      (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100)
                      u0
                  )
                )

                ;; in NEXT cycle, checking if there are any stakers / existing stake amount in NEXT cycle
                (if (> cycleTotalUTEAR u0)

                    ;; there are stakers / there is a stake amount, checking if there is a current backlog allocation we need to clear
                    (if (> backloggedStakingAllocation u0)

                      ;; there is a backloggedAllocation though there are now stakers / stake amount so we need to move transfer all backlogged, clear backloggedAllocation key & proceed normally
                      (begin
                        (as-contract (try! (stx-transfer? backloggedStakingAllocation (as-contract tx-sender) COMMUNITIES_FUND)))
                        (map-set RewardCycleBackloggedStakingAllocation cycle u0)
                        (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100)
                      )

                      ;; there is no backloggedAllocation, this is the first mine in an empty stake
                      (begin
                        (map-set RewardCycleBackloggedStakingAllocation cycle (+ (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100) backloggedStakingAllocation))
                        (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100)
                      )
                    )

                    ;; there are zero stakers / there is no stake amount, mining in a potentially empty stake cycle, therefore adding new potential stake amount to backloggedAllocation
                    (begin
                      (map-set RewardCycleBackloggedStakingAllocation cycle (+ (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100) backloggedStakingAllocation))
                      (/ (* STAKING_POOL_PERCENTAGE ustxAmount) u100)
                    )
                )

            )

            ;; stacking is not active, set stakingAmount to u0
            u0

          )
        )

        (tearAmount (if (> block STAKING_AND_TEAR_FUNDING_FIRST_BLOCK)
            (/ (* TEAR_FUND_PERCENTAGE ustxAmount) u100)
            u0
          )
        )
        (communitiesAmount (- ustxAmount (+ tearAmount stakingAmount)))
      )
      (asserts! (is-eq (get amountUstx (get-reward-block-mining-commit block tx-sender)) u0) ERR_MINER_HAD_ALREADY_COMMITED_TO_BLOCK)
      (asserts! (> block MINING_FIRST_BLOCK) ERR_MINING_NOT_ACTIVE)
      (asserts! (> ustxAmount u999999) ERR_INSUFFICIENT_COMMITMENT)

      (map-set RewardBlockMiningCommit {block: block, miner: tx-sender}
        {
          amountUstx: ustxAmount,
          low: (if (> blockTotalUstx u0) (+ blockTotalUstx u1) u0),
          high: (+ blockTotalUstx ustxAmount)
        }
      )

      (map-set RewardBlockMiningTotal block (+ blockTotalUstx ustxAmount))

      ;; removed flag that checked whether cycleTotalTEAR > u0, not needed since we've asserted that staking is active
      (map-set RewardCycleStakingTotal cycle {totalUTEAR: cycleTotalUTEAR,totalUstx: (+ cycleTotalUstx stakingAmount)})

      ;; if first mine, else add to existing
      (if (is-none (map-get? principal-data tx-sender))
        (map-set principal-data tx-sender {mine: (list block), stake: (list )})
        (map-set principal-data tx-sender 
          (merge 
            (unwrap! (map-get? principal-data tx-sender) (err u1001))
            {mine: (unwrap! (as-max-len? (append (get mine (unwrap! (map-get? principal-data tx-sender) (err u1001))) block) u5000) (err u1002))}
          )
        ) 
      )

      ;;(define-map principal-data principal {mine: (list 5000 uint), stake: (list 5000 uint)})

      (ok (merge returnOk

        {
          communitiesTotal: (+ communitiesTotal communitiesAmount),
          stakingTotal: (+ stakingTotal stakingAmount),
          tearTotal: (+ tearTotal tearAmount),
          block: (+ block u1)
        }
      ))
    )
    errReturn (err errReturn)
  )
)

;; Get mining commitment by block & miner
(define-private (get-reward-block-mining-commit (block uint) (miner principal))
  (default-to
    {
      amountUstx: u0,
      low: u0,
      high: u0
    }
    (map-get? RewardBlockMiningCommit {block: block, miner: miner})
  )
)

;; Get the total stx committed to a block mining/mined
(define-private (get-reward-block-mining-total (block uint))
  (default-to u0 (map-get? RewardBlockMiningTotal block))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Staking Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stake TEAR for the next cycle (2016 blocks ~ 2 weeks)
(define-public (stake-next-cycle (uTEARAmount uint))
  (stake-many-cycles uTEARAmount u1)
)

;; Stake TEAR for up to the next 32 cycles (2016 blocks ~ 2 weeks)
(define-public (stake-many-cycles (uTEARAmount uint) (lockCycles uint))
  (let
    (
      (currentCycle (unwrap! (get-staking-reward-cycle block-height) ERR_STAKING_NOT_ACTIVE))
      (nextCycle (+ u1 currentCycle))
      (lastCycle (+ nextCycle lockCycles))
    )
    (asserts! (> uTEARAmount u0) ERR_INSUFFICIENT_COMMITMENT)
    (asserts! (and (> lockCycles u0) (<= lockCycles MAX_CYCLES_PER_LOCK)) ERR_LOCK_CYCLES_NOT_VALID)
    (try! (contract-call? .tear-token transfer uTEARAmount tx-sender STAKING_POOL))
    (match (fold commit-reward-cycle LOCK_INDEXES
      (ok { uTEARAmount: uTEARAmount, firstCycle: nextCycle, lastCycle: lastCycle}))
      responseOk (ok true)
      responseErr (err u888888)
    )
  )
)


(define-public (claim-reward-cycle (cycle uint))
  (let
    (
      (claimer tx-sender)
      (currentCycle (unwrap! (get-staking-reward-cycle block-height) ERR_STAKING_NOT_AVAILABLE))
      (ustxReward (get-staking-cycle-reward claimer cycle block-height))
      (releaseUTEAR (get releaseUTEAR (get-reward-cycle-staking-commit cycle tx-sender)))
    )
    (asserts! (> currentCycle cycle) ERR_REWARD_CYCLE_NOT_COMPLETED)
    (asserts! (or (> releaseUTEAR u0) (> ustxReward u0)) ERR_NOTHING_TO_REDEEM)

    (map-set RewardCycleStakingCommit
      {
        cycle: cycle,
        staker: tx-sender
      }
      {
        amountUTEAR: u0,
        releaseUTEAR: u0
      }
    )

    (if (> releaseUTEAR u0)
      (try! (as-contract (contract-call? .tear-token transfer releaseUTEAR STAKING_POOL claimer)))
      true
    )

    (if (> ustxReward u0)
      (try! (as-contract (stx-transfer? ustxReward STAKING_POOL claimer)))
      true
    )
    (ok true)
  )
)

;;;;;;;;;; Private Helper Mining Functions ;;;;;;;;;;;;

(define-private (commit-reward-cycle (cycleIndex uint)
  (return
    (response
      {
        uTEARAmount: uint,
        firstCycle: uint,
        lastCycle: uint
      }
      uint
    )
  ))

  (match return
    responseOk
    (let
      (
        (uTEARAmount (get uTEARAmount responseOk))
        (firstCycle (get firstCycle responseOk))
        (lastCycle (get lastCycle responseOk))

        (cycle (+ firstCycle cycleIndex))

        (rewardCycleStakingTotal (get-reward-cycle-staking-total cycle))
        (rewardCycleStakingCommit (get-reward-cycle-staking-commit cycle tx-sender))

        (totalUTEAR (get totalUTEAR rewardCycleStakingTotal))
        (totalUstx (get totalUstx rewardCycleStakingTotal))

        (amountUTEAR (get amountUTEAR rewardCycleStakingCommit))
      )

      ;;(define-map principal-data principal {mine: (list 5000 uint), stake: (list 5000 uint)})
      ;; if first mine, else add to existing
      (if (is-none (map-get? principal-data tx-sender))
        (map-set principal-data tx-sender {mine: (list ), stake: (list cycle)})
        (map-set principal-data tx-sender 
          (merge 
            (unwrap! (map-get? principal-data tx-sender) (err u1001))
            {stake: (unwrap! (as-max-len? (append (get stake (unwrap! (map-get? principal-data tx-sender) (err u1001))) cycle) u5000) (err u1002))}
          )
        ) 
      )

      (begin
        (if (< (+ firstCycle cycleIndex) lastCycle)
          (begin
            (map-set RewardCycleStakingTotal cycle
              {
                totalUTEAR: (+ uTEARAmount totalUTEAR),
                totalUstx: totalUstx
              }
            )
            (map-set RewardCycleStakingCommit {cycle: (+ firstCycle cycleIndex), staker: tx-sender}
              {
                amountUTEAR: (+ uTEARAmount amountUTEAR),
                releaseUTEAR: (+
                                (if (is-eq (+ (get firstCycle responseOk) cycleIndex) (- (get lastCycle responseOk) u1))
                                  (get uTEARAmount responseOk)
                                  u0
                                )
                                (get releaseUTEAR rewardCycleStakingCommit)
                              )
              }
            )
            true
          )
          false
        )
        return
      )
    )
    responseErr return
  )
)

(define-private (get-staking-cycle-reward (staker principal) (cycle uint) (block uint))
  (let
    (
      (totalUstx (get totalUstx (get-reward-cycle-staking-total cycle)))
      (totalUTEAR (get totalUTEAR (get-reward-cycle-staking-total cycle)))
      (amountUTEAR (get amountUTEAR (get-reward-cycle-staking-commit cycle staker)))
    )
    (match (get-staking-reward-cycle block)
      blockCycle
      (if (or (<= blockCycle cycle) (is-eq u0 amountUTEAR))
        u0
        (/ (* totalUstx amountUTEAR) totalUTEAR)
      )
      u0
    )
  )
)

(define-read-only (get-staking-cycle-reward-read (staker principal) (cycle uint) (block uint))
  (let
    (
      (totalUstx (get totalUstx (get-reward-cycle-staking-total cycle)))
      (totalUTEAR (get totalUTEAR (get-reward-cycle-staking-total cycle)))
      (amountUTEAR (get amountUTEAR (get-reward-cycle-staking-commit cycle staker)))
    )
    (match (get-staking-reward-cycle block)
      blockCycle
      (if (or (<= blockCycle cycle) (is-eq u0 amountUTEAR))
        u0
        (/ (* totalUstx amountUTEAR) totalUTEAR)
      )
      u0
    )
  )
)

(define-private (get-staking-reward-cycle (block uint))
  (if (> block STAKING_AND_TEAR_FUNDING_FIRST_BLOCK)
    (some (/ (- block STAKING_AND_TEAR_FUNDING_FIRST_BLOCK) BLOCKS_PER_CYCLE))
    none
  )
)


(define-private (get-reward-cycle-staking-commit (cycle uint) (staker principal))
  (default-to
    {
      amountUTEAR: u0,
      releaseUTEAR: u0
    }
    (map-get? RewardCycleStakingCommit {cycle: cycle, staker: staker})
  )
)

(define-read-only (get-reward-cycle-staking-commit-read (cycle uint) (staker principal))
  (default-to
    {
      amountUTEAR: u0,
      releaseUTEAR: u0
    }
    (map-get? RewardCycleStakingCommit {cycle: cycle, staker: staker})
  )
)


(define-read-only (get-reward-cycle-staking-total-read (cycle uint))
  (default-to
    {
      totalUTEAR: u0,
      totalUstx: u0
    }
    (map-get? RewardCycleStakingTotal cycle)
  )
)

(define-private (get-reward-cycle-staking-total (cycle uint))
  (default-to
    {
      totalUTEAR: u0,
      totalUstx: u0
    }
    (map-get? RewardCycleStakingTotal cycle)
  )
)

;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-private (get-token-max-supply)
  (match (var-get tokenMaxSupply)
    returnTokenMaxSupply returnTokenMaxSupply
    (let
      ((newTokenMaxSupply (unwrap! (contract-call? .tear-token get-max-supply) u0)))
      (var-set tokenMaxSupply (some newTokenMaxSupply))
      newTokenMaxSupply
    )
  )
)

;;;;;;;;;;;;;;;
;; Read Only ;;
;;;;;;;;;;;;;;;

;; will likely need at least the following get-read-onlys:

;; current staking cycle
;; current mining reward

;; VRF

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.