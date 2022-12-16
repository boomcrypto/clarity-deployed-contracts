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
(define-constant COMMUNITIES_FUND 'SP3XD3G5ETW7KHR1F3EDF3MZ8S3B9PGREG3Q8RSFF)

;; representing the principle address in which to send percentages of mining concenesus submissions to be used for ... to-do ...
(define-constant TEAR_FUND 'SP1JYK4TM29FAF7FR390GRGD48QC4T427HRC0SERD)

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
      (vrfSeed (unwrap! (get-random-uint-at-block validationBlock) ERR_NO_VRF_SEED_FOUND))
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
(define-read-only (get-random-uint-at-block (stacksBlock uint))
  (let (
    (vrf-lower-uint-opt
      (match (get-block-info? vrf-seed stacksBlock)
        vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
        none))
  )
  vrf-lower-uint-opt)
)

;; UTILITIES

;; lookup table for converting 1-byte buffers to uints via index-of
(define-constant BUFF_TO_BYTE (list
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

;; Convert a 1-byte buffer into its uint representation.
(define-private (buff-to-u8 (byte (buff 1)))
  (unwrap-panic (index-of BUFF_TO_BYTE byte))
)

;; Convert a little-endian 16-byte buff into a uint.
(define-private (buff-to-uint-le (word (buff 16)))
  (get acc
    (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
  )
)

;; Inner fold function for converting a 16-byte buff into a uint.
(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
  )
  {
    ;; acc = byte * (2**(8 * (15 - idx))) + acc
    acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc),
    data: data
  })
)

;; Convert the lower 16 bytes of a buff into a little-endian uint.
(define-private (lower-16-le (input (buff 32)))
  (get acc
    (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
  )
)

;; Inner closure for obtaining the lower 16 bytes of a 32-byte buff
(define-private (lower-16-le-closure (idx uint) (input { acc: (buff 16), data: (buff 32) }))
  (let (
    (acc (get acc input))
    (data (get data input))
    (byte (unwrap-panic (element-at data idx)))
  )
  {
    acc: (unwrap-panic (as-max-len? (concat acc byte) u16)),
    data: data
  })
)
