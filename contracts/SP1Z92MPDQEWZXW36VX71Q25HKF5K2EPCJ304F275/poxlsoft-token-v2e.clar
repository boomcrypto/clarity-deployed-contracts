;; PoX-lite contract, MVP.
;; This is alpha-quality code.  Tests are included in the tests/ directory, but this code is unaudited.
;; DO NOT USE IN PRODUCTION.
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.sip-010-v1a.sip-010-trait)
(impl-trait 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.initializable-trait-v1a.initializable-poxl-token-trait)


;; POXL_TOKEN ERRORS 4230~4249
(define-constant ERR_NO_WINNER u4231)
(define-constant ERR_NO_SUCH_MINER u4232)
(define-constant ERR_IMMATURE_TOKEN_REWARD u4233)
(define-constant ERR_ALREADY_CLAIMED u4234)
(define-constant ERR_STACKING_NOT_AVAILABLE u4235)
(define-constant ERR_CANNOT_STACK u4236)
(define-constant ERR_INSUFFICIENT_BALANCE u4237)
(define-constant ERR_USER_ALREADY_MINED u4238)
(define-constant ERR_NOTHING_TO_REDEEM u4239)
(define-constant ERR_PERMISSION_DENIED u4240)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u4241)
(define-constant ERR_INSUFFICIENT_COMMITMENT u4242)
(define-constant ERR_NO_MINERS_AT_BLOCK u4243)
(define-constant ERR_INVALID_REWARD_CYCLE u4244)
(define-constant ERR_ALREADY_INITIALIZED u4245)


(define-constant STACKSWAP_ACCOUNT tx-sender)
(define-constant SPLIT_FOUNDER_PCT u3)

;; Tailor to your needs.
(define-constant TOKEN-REWARD-MATURITY u100)        ;; how long a miner must wait before claiming their minted tokens
(define-constant FIRST-STACKING-BLOCK u99999999999999999)           ;; Stacks block height when Stacking is available
(define-constant REWARD-CYCLE-LENGTH u500)          ;; how long a reward cycle is
(define-constant MAX-REWARD-CYCLES u32)             ;; how many reward cycles a Stacker can Stack their tokens for

;; NOTE: must be as long as MAX-REWARD-CYCLES


(define-constant REWARD-CYCLE-INDEXES (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31))

;; lookup table for converting 1-byte buffers to uints via index-of
(define-constant BUFF-TO-BYTE (list 
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
    (unwrap-panic (index-of BUFF-TO-BYTE byte)))

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

;; Convert a little-endian 16-byte buff into a uint.
(define-private (buff-to-uint-le (word (buff 16)))
    (get acc
        (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
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

;; Convert the lower 16 bytes of a buff into a little-endian uint.
(define-private (lower-16-le (input (buff 32)))
    (get acc
        (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) { acc: 0x, data: input })
    )
)

;; Read the on-chain VRF and turn the lower 16 bytes into a uint, in order to sample the set of miners and determine
;; which one may claim the token batch for the given block height.
(define-read-only (get-random-uint-at-block (stacks-block uint))
    (let (
        (vrf-lower-uint-opt
            (match (get-block-info? vrf-seed stacks-block)
                vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
                none))
    )
    vrf-lower-uint-opt)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stacking configuration, as data vars (so it's easy to test).
(define-data-var first-stacking-block uint FIRST-STACKING-BLOCK)
(define-data-var reward-cycle-length uint REWARD-CYCLE-LENGTH)
(define-data-var token-reward-maturity uint TOKEN-REWARD-MATURITY)
(define-data-var max-reward-cycles uint MAX-REWARD-CYCLES)
(define-data-var coinbase-reward uint u50000000)
(define-data-var rem-item uint u0)



;; NOTE: keep this private -- it's used by the test harness to set smaller (easily-tested) values.
;; (define-private (configure (first-block uint) (rc-len uint) (reward-maturity uint) (max-lockup uint))
;;     (begin
;;         (var-set first-stacking-block first-block)
;;         (var-set reward-cycle-length rc-len)
;;         (var-set token-reward-maturity reward-maturity)
;;         (var-set max-reward-cycles max-lockup)
;;         (var-set coinbase-reward coinbase-reward-to-set)
;;         ;; (ok true)
;;    )
;; )

;; (begin
;;     (asserts! (is-eq (len REWARD-CYCLE-INDEXES) MAX-REWARD-CYCLES) (err "Invalid max reward cycles"))
;;     (configure FIRST-STACKING-BLOCK REWARD-CYCLE-LENGTH TOKEN-REWARD-MATURITY MAX-REWARD-CYCLES)
;; )

(define-map MiningStatsAtBlock
  uint
  {
    minersCount: uint,
    amount: uint,
    amountToFounder: uint,
    amountToStackers: uint,
    rewardClaimed: bool
  }
)

(define-read-only (get-mining-stats-at-block (stacksHeight uint))
  (map-get? MiningStatsAtBlock stacksHeight)
)

;; returns map MiningStatsAtBlock at a given Stacks block height
;; or, an empty structure
(define-read-only (get-mining-stats-at-block-or-default (stacksHeight uint))
  (default-to {
      minersCount: u0,
      amount: u0,
      amountToFounder: u0,
      amountToStackers: u0,
      rewardClaimed: false
    }
    (map-get? MiningStatsAtBlock stacksHeight)
  )
)

;; At a given Stacks block height and user ID:
;; - what is their ustx commitment
;; - what are the low/high values (used for VRF)
(define-map MinersAtBlock
  {
    stacksHeight: uint,
    user: principal
  }
  {
    ustx: uint,
    lowValue: uint,
    highValue: uint,
    winner: bool
  }
)

;; returns true if a given miner has already mined at a given block height
(define-read-only (has-mined-at-block (stacksHeight uint) (user principal))
  (is-some 
    (map-get? MinersAtBlock { stacksHeight: stacksHeight, user: user })
  )
)

;; returns map MinersAtBlock at a given Stacks block height for a user
(define-read-only (get-miner-at-block (stacksHeight uint) (user principal))
  (map-get? MinersAtBlock { stacksHeight: stacksHeight, user: user })
)

;; returns map MinersAtBlock at a given Stacks block height for a user
;; or, an empty structure
(define-read-only (get-miner-at-block-or-default (stacksHeight uint) (user principal))
  (default-to {
    highValue: u0,
    lowValue: u0,
    ustx: u0,
    winner: false
  }
    (map-get? MinersAtBlock { stacksHeight: stacksHeight, user: user }))
)

(define-map MinersAtBlockHighValue
  uint
  uint
)

(define-read-only (get-last-high-value-at-block (stacksHeight uint))
  (default-to u0
    (map-get? MinersAtBlockHighValue stacksHeight))
)

;; At a given Stacks block height:
;; - what is the user of miner who won this block
(define-map BlockWinners
  uint
  principal
)

(define-read-only (get-block-winner (stacksHeight uint))
  (map-get? BlockWinners stacksHeight)
)

;; MINING ACTIONS

(define-public (mine-tokens (amountUstx uint) (memo (optional (buff 34))))
  (begin
    (try! (mine-many (unwrap! (as-max-len? (list amountUstx) u200) (err u404))))
    (if (is-some memo)
      (print memo)
      none
    )
    (ok true)
  )
)

(define-public (mine-many (amounts (list 200 uint)))
  (begin
    (asserts! (> (len amounts) u0) (err ERR_INSUFFICIENT_COMMITMENT))
    (match (fold mine-single amounts (ok { user: tx-sender, toStackers: u0, toFounder: u0, stacksHeight: block-height }))
      okReturn 
      (begin
        (asserts! (>= (stx-get-balance tx-sender) (+ (get toStackers okReturn) (get toFounder okReturn))) (err ERR_INSUFFICIENT_BALANCE))
        (if (> (get toStackers okReturn ) u0)
          (try! (stx-transfer? (get toStackers okReturn ) tx-sender (as-contract tx-sender)))
          false
        )
        (try! (stx-transfer? (get toFounder okReturn ) tx-sender (var-get contract-owner)))
        (ok true)
      )
      errReturn (err errReturn)
    )
  )
)

(define-private (mine-single 
  (amountUstx uint) 
  (return (response 
    { 
      user: principal,
      toStackers: uint,
      toFounder: uint,
      stacksHeight: uint
    }
    uint
  )))

  (match return okReturn
    (let
      (
        (stacksHeight (get stacksHeight okReturn))
        (rewardCycle (default-to u0 (get-reward-cycle stacksHeight)))
        (stackingActive (stacking-active-at-cycle rewardCycle))
        (toFounder
          (if stackingActive
            (/ (* SPLIT_FOUNDER_PCT amountUstx) u100)
            amountUstx
          )
        )
        (toStackers (- amountUstx toFounder))
      )
      (asserts! (not (has-mined-at-block stacksHeight (get user okReturn))) (err ERR_USER_ALREADY_MINED))
      (asserts! (> amountUstx u0) (err ERR_INSUFFICIENT_COMMITMENT))
      (try! (set-tokens-mined (get user okReturn) stacksHeight amountUstx toStackers toFounder))
      (ok (merge okReturn 
        {
          toStackers: (+ (get toStackers okReturn) toStackers),
          toFounder: (+ (get toFounder okReturn) toFounder),
          stacksHeight: (+ stacksHeight u1)
        }
      ))
    )
    errReturn (err errReturn)
  ) 
)

(define-private (set-tokens-mined (user principal) (stacksHeight uint) (amountUstx uint) (toStackers uint) (toFounder uint))
  (let
    (
      (blockStats (get-mining-stats-at-block-or-default stacksHeight))
      (newMinersCount (+ (get minersCount blockStats) u1))
      (minerLowVal (get-last-high-value-at-block stacksHeight))
      (rewardCycle (unwrap! (get-reward-cycle stacksHeight)
        (err ERR_STACKING_NOT_AVAILABLE)))
      (rewardCycleStats (get-stacking-stats-at-cycle-or-default rewardCycle))
    )
    (map-set MiningStatsAtBlock
      stacksHeight
      {
        minersCount: newMinersCount,
        amount: (+ (get amount blockStats) amountUstx),
        amountToFounder: (+ (get amountToFounder blockStats) toFounder),
        amountToStackers: (+ (get amountToStackers blockStats) toStackers),
        rewardClaimed: false
      }
    )
    (map-set MinersAtBlock
      {
        stacksHeight: stacksHeight,
        user: user
      }
      {
        ustx: amountUstx,
        lowValue: (if (> minerLowVal u0) (+ minerLowVal u1) u0),
        highValue: (+ minerLowVal amountUstx),
        winner: false
      }
    )
    (map-set MinersAtBlockHighValue
      stacksHeight
      (+ minerLowVal amountUstx)
    )
    (if (> toStackers u0)
      (map-set StackingStatsAtCycle
        rewardCycle
        {
          amountUstx: (+ (get amountUstx rewardCycleStats) toStackers),
          amountToken: (get amountToken rewardCycleStats)
        }
      )
      false
    )
    (ok true)
  )
)

;; MINING REWARD CLAIM ACTIONS

;; calls function to claim mining reward in active logic contract
(define-public (claim-mining-reward (minerBlockHeight uint))
  (begin
    ;; (asserts! (or (is-eq (var-get shutdownHeight) u0) (< minerBlockHeight (var-get shutdownHeight))) (err ERR_CLAIM_IN_WRONG_CONTRACT))
    (try! (claim-mining-reward-at-block tx-sender block-height minerBlockHeight))
    (ok true)
  )
)
;; Determine whether or not the given principal can claim the mined tokens at a particular block height,
;; given the miners record for that block height, a random sample, and the current block height.
(define-private (claim-mining-reward-at-block (user principal) (stacksHeight uint) (minerBlockHeight uint))
  (let
    (
      (maturityHeight (+ (var-get token-reward-maturity) minerBlockHeight))
      (blockStats (unwrap! (get-mining-stats-at-block minerBlockHeight) (err ERR_NO_MINERS_AT_BLOCK)))
      (minerStats (unwrap! (get-miner-at-block minerBlockHeight user) (err ERR_NO_SUCH_MINER)))
      (isMature (asserts! (> stacksHeight maturityHeight) (err ERR_IMMATURE_TOKEN_REWARD)))
      (random-sample (unwrap! (get-random-uint-at-block (+ minerBlockHeight (var-get token-reward-maturity))) (err ERR_REWARD_CYCLE_NOT_COMPLETED)))
      (commitTotal (get-last-high-value-at-block minerBlockHeight))
      (winningValue (mod random-sample commitTotal))
    )
    (asserts! (not (get rewardClaimed blockStats)) (err ERR_ALREADY_CLAIMED))
    (asserts! (and (>= winningValue (get lowValue minerStats)) (<= winningValue (get highValue minerStats)))
      (err ERR_NO_WINNER))
    (unwrap-panic (set-mining-reward-claimed user minerBlockHeight))
    (ok true)
  )
)

(define-private (set-mining-reward-claimed (user principal) (minerBlockHeight uint))
  (let
    (
      (blockStats (get-mining-stats-at-block-or-default minerBlockHeight))
      (minerStats (get-miner-at-block-or-default minerBlockHeight user))
    )
    (map-set MiningStatsAtBlock
      minerBlockHeight
      {
        minersCount: (get minersCount blockStats),
        amount: (get amount blockStats),
        amountToFounder: (get amountToFounder blockStats),
        amountToStackers: (get amountToStackers blockStats),
        rewardClaimed: true
      }
    )
    (map-set MinersAtBlock
      {
        stacksHeight: minerBlockHeight,
        user: user
      }
      {
        ustx: (get ustx minerStats),
        lowValue: (get lowValue minerStats),
        highValue: (get highValue minerStats),
        winner: true
      }
    )
    (map-set BlockWinners
      minerBlockHeight
      user
    )
    (unwrap-panic (mint-coinbase user minerBlockHeight))
    (ok true)
  )
)

(define-read-only (is-block-winner (user principal) (minerBlockHeight uint))
  (is-block-winner-and-can-claim user minerBlockHeight false)
)

(define-read-only (can-claim-mining-reward (user principal) (minerBlockHeight uint))
  (is-block-winner-and-can-claim user minerBlockHeight true)
)

(define-private (is-block-winner-and-can-claim (user principal) (minerBlockHeight uint) (testCanClaim bool))
  (let
    (
      (blockStats (unwrap! (get-mining-stats-at-block minerBlockHeight) false))
      (minerStats (unwrap! (get-miner-at-block minerBlockHeight user) false))
      (maturityHeight (+ (var-get token-reward-maturity) minerBlockHeight))
      (random-sample (unwrap! (get-random-uint-at-block (+ minerBlockHeight (var-get token-reward-maturity))) false))
      (commitTotal (get-last-high-value-at-block minerBlockHeight))
      (winningValue (mod random-sample commitTotal))
    )
    (if (and (>= winningValue (get lowValue minerStats)) (<= winningValue (get highValue minerStats)))
      (if testCanClaim (not (get rewardClaimed blockStats)) true)
      false
    )
  )
)


;; STACKING CONFIGURATION


;; At a given reward cycle:
;; - how many Stackers were there
;; - what is the total uSTX submitted by miners
;; - what is the total amount of tokens stacked
(define-map StackingStatsAtCycle
  uint
  {
    amountUstx: uint,
    amountToken: uint
  }
)

;; returns the total stacked tokens and committed uSTX for a given reward cycle
(define-read-only (get-stacking-stats-at-cycle (rewardCycle uint))
  (map-get? StackingStatsAtCycle rewardCycle)
)

;; returns the total stacked tokens and committed uSTX for a given reward cycle
;; or, an empty structure
(define-read-only (get-stacking-stats-at-cycle-or-default (rewardCycle uint))
  (default-to { amountUstx: u0, amountToken: u0 }
    (map-get? StackingStatsAtCycle rewardCycle))
)

;; At a given reward cycle and user ID:
;; - what is the total tokens Stacked?
;; - how many tokens should be returned? (based on Stacking period)
(define-map StackerAtCycle
  {
    rewardCycle: uint,
    user: principal
  }
  {
    amountStacked: uint,
    toReturn: uint
  }
)

(define-read-only (get-stacker-at-cycle (rewardCycle uint) (user principal))
  (map-get? StackerAtCycle { rewardCycle: rewardCycle, user: user })
)

(define-read-only (get-stacker-at-cycle-or-default (rewardCycle uint) (user principal))
  (default-to { amountStacked: u0, toReturn: u0 }
    (map-get? StackerAtCycle { rewardCycle: rewardCycle, user: user }))
)

;; get the reward cycle for a given Stacks block height
(define-read-only (get-reward-cycle (stacksHeight uint))
  (let
    (
      (firstStackingBlock (var-get first-stacking-block))
      (rcLen (var-get reward-cycle-length))
    )
    (if (>= stacksHeight firstStackingBlock)
      (some (/ (- stacksHeight firstStackingBlock) rcLen))
      none)
  )
)

;; determine if stacking is active in a given cycle
(define-read-only (stacking-active-at-cycle (rewardCycle uint))
  (is-some
    (get amountToken (map-get? StackingStatsAtCycle rewardCycle))
  )
)

;; get the first Stacks block height for a given reward cycle.
(define-read-only (get-first-stacks-block-in-reward-cycle (rewardCycle uint))
  (+ (var-get first-stacking-block) (* (var-get reward-cycle-length) rewardCycle))
)

;; getter for get-entitled-stacking-reward that specifies block height
(define-read-only (get-stacking-reward (user principal) (targetCycle uint))
  (get-entitled-stacking-reward user targetCycle block-height)
)

(define-private (get-entitled-stacking-reward (user principal) (targetCycle uint) (stacksHeight uint))
  (let
    (
      (rewardCycleStats (get-stacking-stats-at-cycle-or-default targetCycle))
      (stackerAtCycle (get-stacker-at-cycle-or-default targetCycle user))
      (totalUstxThisCycle (get amountUstx rewardCycleStats))
      (totalStackedThisCycle (get amountToken rewardCycleStats))
      (userStackedThisCycle (get amountStacked stackerAtCycle))
    )
    (match (get-reward-cycle stacksHeight)
      currentCycle
      (if (or (<= currentCycle targetCycle) (is-eq u0 userStackedThisCycle))
        ;; this cycle hasn't finished, or Stacker contributed nothing
        u0
        ;; (totalUstxThisCycle * userStackedThisCycle) / totalStackedThisCycle
        (/ (* totalUstxThisCycle userStackedThisCycle) totalStackedThisCycle)
      )
      ;; before first reward cycle
      u0
    )
  )
)

;; STACKING ACTIONS

(define-public (stack-tokens (amountTokens uint) (lockPeriod uint))
  (let
    (
      (user tx-sender)
    )
    (try! (stack-tokens-at-cycle tx-sender amountTokens block-height lockPeriod))
    (ok true)
  )
)

(define-private (stack-tokens-at-cycle (user principal) (amountTokens uint) (startHeight uint) (lockPeriod uint))
  (let
    (
      (currentCycle (unwrap! (get-reward-cycle startHeight) (err ERR_STACKING_NOT_AVAILABLE)))
      (targetCycle (+ u1 currentCycle))
      (commitment {
        stackerId: user,
        amount: amountTokens,
        first: targetCycle,
        last: (+ targetCycle lockPeriod)
      })
    )
    (asserts! (and (> lockPeriod u0) (<= lockPeriod MAX-REWARD-CYCLES))
      (err ERR_CANNOT_STACK))
    (asserts! (> amountTokens u0) (err ERR_CANNOT_STACK))
    (unwrap! (ft-transfer? stackables amountTokens tx-sender (as-contract tx-sender))
        (err ERR_INSUFFICIENT_BALANCE))
    (match (fold stack-tokens-closure REWARD-CYCLE-INDEXES (ok commitment))
      okValue (ok true)
      errValue (err errValue)
    )
  )
)

(define-private (stack-tokens-closure (rewardCycleIdx uint)
  (commitmentResponse (response 
    {
      stackerId: principal,
      amount: uint,
      first: uint,
      last: uint
    }
    uint
  )))

  (match commitmentResponse
    commitment 
    (let
      (
        (stackerId (get stackerId commitment))
        (amountToken (get amount commitment))
        (firstCycle (get first commitment))
        (lastCycle (get last commitment))
        (targetCycle (+ firstCycle rewardCycleIdx))
        (stackerAtCycle (get-stacker-at-cycle-or-default targetCycle stackerId))
        (amountStacked (get amountStacked stackerAtCycle))
        (toReturn (get toReturn stackerAtCycle))
      )
      (begin
        (if (and (>= targetCycle firstCycle) (< targetCycle lastCycle))
          (begin
            (if (is-eq targetCycle (- lastCycle u1))
              (set-tokens-stacked stackerId targetCycle amountToken amountToken)
              (set-tokens-stacked stackerId targetCycle amountToken u0)
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

(define-private (set-tokens-stacked (user principal) (targetCycle uint) (amountStacked uint) (toReturn uint))
  (let
    (
      (rewardCycleStats (get-stacking-stats-at-cycle-or-default targetCycle))
      (stackerAtCycle (get-stacker-at-cycle-or-default targetCycle user))
    )
    (map-set StackingStatsAtCycle
      targetCycle
      {
        amountUstx: (get amountUstx rewardCycleStats),
        amountToken: (+ amountStacked (get amountToken rewardCycleStats))
      }
    )
    (map-set StackerAtCycle
      {
        rewardCycle: targetCycle,
        user: user
      }
      {
        amountStacked: (+ amountStacked (get amountStacked stackerAtCycle)),
        toReturn: (+ toReturn (get toReturn stackerAtCycle))
      }
    )
  )
)

;; STACKING REWARD CLAIMS

;; calls function to claim stacking reward in active logic contract
(define-public (claim-stacking-reward (targetCycle uint))
  (begin
    (try! (claim-stacking-reward-at-cycle tx-sender block-height targetCycle))
    (ok true)
  )
)

(define-private (claim-stacking-reward-at-cycle (user principal) (stacksHeight uint) (targetCycle uint))
  (let
    (
      (currentCycle (unwrap! (get-reward-cycle stacksHeight) (err ERR_STACKING_NOT_AVAILABLE)))
      (entitledUstx (get-entitled-stacking-reward user targetCycle stacksHeight))
      (stackerAtCycle (get-stacker-at-cycle-or-default targetCycle user))
      (toReturn (get toReturn stackerAtCycle))
    )
    (asserts! 
      (> currentCycle targetCycle)
      (err ERR_REWARD_CYCLE_NOT_COMPLETED))
    (asserts! (or (> toReturn u0) (> entitledUstx u0)) (err ERR_NOTHING_TO_REDEEM))
    ;; disable ability to claim again
    (map-set StackerAtCycle
      {
        rewardCycle: targetCycle,
        user: user
      }
      {
        amountStacked: u0,
        toReturn: u0
      }
    )
    ;; send back tokens if user was eligible
    (if (> toReturn u0)
      (try! (as-contract (transfer toReturn tx-sender user none)))
      true
    )
    ;; send back rewards if user was eligible
    (if (> entitledUstx u0)
      (try! (as-contract (stx-transfer? entitledUstx tx-sender user)))
      true
    )
    (ok true)
  )
)

;; ;; The fungible token that can be Stacked.
(define-fungible-token stackables)

;; Function for deciding how many tokens to mint, depending on when they were mined.
;; Tailor to your own needs.
(define-read-only (get-coinbase-amount (stacks-block-ht uint))
    (var-get coinbase-reward)
)

;; API endpoint for getting statistics about this PoX-lite contract.
;; Compare to /v2/pox on the Stacks node.
(define-read-only (get-pox-lite-info)
    (match (get-reward-cycle block-height)
        cur-reward-cycle
            (ok
                (let (
                    ;; (token-info (get-tokens-per-cycle cur-reward-cycle))
                    (total-ft-supply (ft-get-supply stackables))
                    (total-ustx-supply (stx-get-balance (as-contract tx-sender)))
                )
                {
                    reward-cycle-id: cur-reward-cycle,
                    first-block-height: (var-get first-stacking-block),
                    reward-cycle-length: (var-get reward-cycle-length),
                    total-supply: total-ft-supply,
                    total-ustx-locked: total-ustx-supply,
                    ;; cur-liquid-supply: (- total-ft-supply (get total-tokens token-info)),
                    ;; cur-locked-supply: (get total-tokens token-info),
                    ;; cur-ustx-committed: (get total-ustx token-info)
                })
            )
        (err ERR_STACKING_NOT_AVAILABLE)
    )
)

;; Produce the new tokens for the given claimant, who won the tokens at the given Stacks block height.
(define-private (mint-coinbase (recipient principal) (stacks-block-ht uint))
    (begin

        (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-owner-amount (get-coinbase-amount stacks-block-ht)) recipient))
        (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-stackswap-amount (get-coinbase-amount stacks-block-ht)) STACKSWAP_ACCOUNT))
        ;; (try! (ft-mint? stackables (get-coinbase-amount stacks-block-ht) recipient))
        (ok true)
        ;; (ft-mint? stackables (get-coinbase-amount stacks-block-ht) recipient)
    )
)


;; ;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;

;; Data variables specific to the deployed token contract
(define-data-var token-name (string-ascii 32) "")
(define-data-var token-symbol (string-ascii 32) "")
(define-data-var token-decimals uint u0)

;; Track who deployed the token and whether it has been initialized
(define-data-var contract-owner principal tx-sender)
(define-data-var is-initialized bool false)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_PERMISSION_DENIED))
    (try! (ft-transfer? stackables amount from to))
	(match memo to-print (print to-print) 0x)
	(ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance stackables owner)))

;; Returns the token name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Returns the number of decimals used
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Returns the total number of tokens that currently exist
(define-read-only (get-total-supply)
  (ok (ft-get-supply stackables)))

;; Variable for URI storage
(define-data-var uri (string-utf8 256) u"")

;; Public getter for the URI
(define-read-only (get-token-uri)
  (ok (some (var-get uri))))

;; Setter for the URI - only the owner can set it
(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-uri", updated-uri: updated-uri })
    (ok (var-set uri updated-uri))))

;; Variable for UwebsiteRI storage
(define-data-var website (string-utf8 256) u"")

;; Public getter for the website
(define-read-only (get-token-website)
  (ok (some (var-get website))))

;; Setter for the website - only the owner can set it
(define-public (set-token-website (updated-website (string-utf8 256)))
  (begin
    (asserts! (is-eq (var-get contract-owner) tx-sender) (err ERR_PERMISSION_DENIED))
    ;; Print the action for any off chain watchers
    (print { action: "set-token-website", updated-website: updated-website })
    (ok (var-set website updated-website))))

(define-public (initialize (name-to-set (string-ascii 32)) (symbol-to-set (string-ascii 32)) (decimals-to-set uint) (uri-to-set (string-utf8 256))
    (website-to-set (string-utf8 256)) (initial-mint-amount uint) (first-stacking-block-to-set uint) (reward-cycle-lengh-to-set uint) (token-reward-maturity-to-set uint) (coinbase-reward-to-set uint))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (asserts! (not (var-get is-initialized)) (err ERR_ALREADY_INITIALIZED))
    (asserts! (> reward-cycle-lengh-to-set u0) (err ERR_INVALID_REWARD_CYCLE))
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set token-name name-to-set)
    (var-set token-symbol symbol-to-set)
    (var-set token-decimals decimals-to-set)
    (var-set uri uri-to-set)
    (var-set website website-to-set)
    (var-set contract-owner tx-sender)
    ;; (try! (ft-mint? stackables initial-mint-amount tx-sender))
    (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-owner-amount initial-mint-amount) tx-sender))
    (unwrap-panic (ft-mint? stackables (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-fee-v1a get-stackswap-amount initial-mint-amount) STACKSWAP_ACCOUNT))
    ;; (asserts! (is-eq (len REWARD-CYCLE-INDEXES) MAX-REWARD-CYCLES) (err "Invalid max reward cycles"))
    (var-set first-stacking-block first-stacking-block-to-set)
    (var-set reward-cycle-length reward-cycle-lengh-to-set)
    (var-set token-reward-maturity token-reward-maturity-to-set)
    (var-set coinbase-reward coinbase-reward-to-set)
    (ok u0)
))

;; ;; Variable for approve
(define-data-var approved bool false)

;; ;; Public getter for the approve
(define-read-only (get-is-approved)
  (ok (some (var-get approved))))


(define-public (approve (is-approved bool))
  (begin
    (asserts! (is-eq contract-caller (unwrap-panic (contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-dao-v5d get-qualified-name-by-name "one-step-mint"))) (err ERR_PERMISSION_DENIED))
    (ok (var-set approved is-approved))
  )
)

(contract-call? 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-one-step-mint-v5d add-poxl-token (as-contract tx-sender))