;; Title: CCD006 CityCoin Mining
;; Version: 1.0.0
;; Summary: A central city mining contract for the CityCoins protocol.
;; Description: An extension that provides a mining interface per city, in which each mining participant spends STX per block for a weighted chance to mint new CityCoins per the issuance schedule.

;; TRAITS

(impl-trait .extension-trait.extension-trait)
(impl-trait .ccd006-trait.ccd006-citycoin-mining-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u6000))
(define-constant ERR_INVALID_CITY (err u6001))
(define-constant ERR_NO_ACTIVATION_DETAILS (err u6002))
(define-constant ERR_INACTIVE_CITY (err u6003))
(define-constant ERR_INVALID_USER (err u6004))
(define-constant ERR_INVALID_TREASURY (err u6005))
(define-constant ERR_INVALID_DELAY (err u6006))
(define-constant ERR_INVALID_COMMITS (err u6007))
(define-constant ERR_NOT_ENOUGH_FUNDS (err u6008))
(define-constant ERR_ALREADY_MINED (err u6009))
(define-constant ERR_REWARD_IMMATURE (err u6010))
(define-constant ERR_NO_VRF_SEED (err u6011))
(define-constant ERR_DID_NOT_MINE (err u6012))
(define-constant ERR_NO_MINER_DATA (err u6013))
(define-constant ERR_ALREADY_CLAIMED (err u6014))
(define-constant ERR_MINER_NOT_WINNER (err u6015))
(define-constant ERR_MINING_DISABLED (err u6016))

;; DATA VARS

(define-data-var miningEnabled bool true)
(define-data-var rewardDelay uint u100)

;; DATA MAPS

(define-map MiningStats
  { cityId: uint, height: uint }
  { miners: uint, amount: uint, claimed: bool }
)

(define-map Miners
  { cityId: uint, height: uint, userId: uint }
  { commit: uint, low: uint, high: uint, winner: bool }
)

(define-map HighValues
  { cityId: uint, height: uint }
  uint
)

(define-map Winners
  { cityId: uint, height: uint }
  uint
)

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (set-reward-delay (delay uint))
  (begin 
    (try! (is-dao-or-extension))
    (print {
      event: "set-reward-delay",
      rewardDelay: delay
    })
    (asserts! (> delay u0) ERR_INVALID_DELAY)
    (ok (var-set rewardDelay delay))
  )
)

(define-public (set-mining-enabled (status bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "set-mining-enabled",
      miningEnabled: status
    })
    (ok (var-set miningEnabled status))
  )
)

(define-public (mine (cityName (string-ascii 10)) (amounts (list 200 uint)))
  (let
    (
      (cityId (unwrap! (contract-call? .ccd004-city-registry get-city-id cityName) ERR_INVALID_CITY))
      (cityInfo (contract-call? .ccd005-city-data get-city-info cityId "mining"))
      (cityDetails (unwrap! (get details cityInfo) ERR_NO_ACTIVATION_DETAILS))
      (cityTreasury (unwrap! (get treasury cityInfo) ERR_INVALID_TREASURY))
      (user tx-sender)
      (userId (try! (as-contract (contract-call? .ccd003-user-registry get-or-create-user-id user))))
      (totalAmount (fold + amounts u0))
    )
    (asserts! (var-get miningEnabled) ERR_MINING_DISABLED)
    (asserts! (get activatedAt cityInfo) ERR_INACTIVE_CITY)
    (asserts! (>= (stx-get-balance tx-sender) totalAmount) ERR_NOT_ENOUGH_FUNDS)
    (asserts! (> (len amounts) u0) ERR_INVALID_COMMITS)
    (try! (fold mine-block amounts (ok {
      cityId: cityId,
      userId: userId,
      height: block-height,
      totalAmount: u0,
    })))
    (print {
      event: "mining",
      cityId: cityId,
      cityName: cityName,
      cityTreasury: cityTreasury,
      firstBlock: block-height,  
      lastBlock: (- (+ block-height (len amounts)) u1),
      totalAmount: totalAmount,
      totalBlocks: (len amounts),
      userId: userId
    })                
    (stx-transfer? totalAmount tx-sender cityTreasury)
  )
)

(define-public (claim-mining-reward (cityName (string-ascii 10)) (claimHeight uint))
  (let
    (
      (cityId (unwrap! (contract-call? .ccd004-city-registry get-city-id cityName) ERR_INVALID_CITY))
      (maturityHeight (+ (get-reward-delay) claimHeight))
      (isMature (asserts! (> block-height maturityHeight) ERR_REWARD_IMMATURE))
      (userId (unwrap! (contract-call? .ccd003-user-registry get-user-id tx-sender) ERR_INVALID_USER))
      (blockStats (get-mining-stats cityId claimHeight))
      (minerStats (get-miner cityId claimHeight userId))
      (vrfSample (unwrap! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-vrf-v2 get-save-rnd maturityHeight) ERR_NO_VRF_SEED))
      (commitTotal (get-high-value cityId claimHeight))
      (commitValid (asserts! (> commitTotal u0) ERR_NO_MINER_DATA))
      (winningValue (mod vrfSample commitTotal))
    )
    (asserts! (has-mined-at-block cityId claimHeight userId) ERR_DID_NOT_MINE)
    (asserts! (and (> (get miners blockStats) u0) (> (get commit minerStats) u0)) ERR_NO_MINER_DATA)
    (asserts! (not (get claimed blockStats)) ERR_ALREADY_CLAIMED)
    (asserts! (and (>= winningValue (get low minerStats)) (<= winningValue (get high minerStats))) ERR_MINER_NOT_WINNER)
    (map-set MiningStats
      { cityId: cityId, height: claimHeight }
      (merge blockStats { claimed: true })
    )
    (map-set Miners
      { cityId: cityId, height: claimHeight, userId: userId }
      (merge minerStats { winner: true })
    )
    (map-set Winners
      { cityId: cityId, height: claimHeight }
      userId
    )
    (print {
      event: "mining-claim",
      cityId: cityId,
      cityName: cityName,
      claimHeight: claimHeight,
      userId: userId
    })
    (contract-call? .ccd010-core-v2-adapter mint-coinbase cityName tx-sender (get-coinbase-amount cityId claimHeight))
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (get-reward-delay)
  (var-get rewardDelay)
)

(define-read-only (get-mining-stats (cityId uint) (height uint))
  (default-to { miners: u0, amount: u0, claimed: false }
    (map-get? MiningStats { cityId: cityId, height: height })
  )
)

(define-read-only (has-mined-at-block (cityId uint) (height uint) (userId uint))
  (is-some (map-get? Miners { cityId: cityId, height: height, userId: userId }))
)

(define-read-only (get-miner (cityId uint) (height uint) (userId uint))
  (default-to { commit: u0, low: u0, high: u0, winner: false }
    (map-get? Miners { cityId: cityId, height: height, userId: userId })
  )
)

(define-read-only (get-high-value (cityId uint) (height uint))
  (default-to u0
    (map-get? HighValues { cityId: cityId, height: height })
  )
)

(define-read-only (get-block-winner (cityId uint) (height uint))
  (map-get? Winners { cityId: cityId, height: height })
)

(define-read-only (is-block-winner (cityId uint) (user principal) (claimHeight uint))
  (let
    (
      (userId (default-to u0 (contract-call? .ccd003-user-registry get-user-id user)))
      (blockStats (get-mining-stats cityId claimHeight))
      (minerStats (get-miner cityId claimHeight userId))
      (vrfSample (unwrap! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.citycoin-vrf-v2 get-rnd (+ (get-reward-delay) claimHeight)) none))
      (commitTotal (get-high-value cityId claimHeight))
      (winningValue (mod vrfSample commitTotal))
    )
    (if (and (> userId u0) (>= winningValue (get low minerStats)) (<= winningValue (get high minerStats)))
      (some { winner: true, claimed: (get claimed blockStats) })
      (some { winner: false, claimed: (get claimed blockStats) })
    )
  )
)

(define-read-only (get-coinbase-amount (cityId uint) (height uint))
  (let
    (
      (coinbaseInfo (contract-call? .ccd005-city-data get-coinbase-info cityId))
      (thresholds (unwrap! (get thresholds coinbaseInfo) u0))
      (amounts (unwrap! (get amounts coinbaseInfo) u0))
      (details (unwrap! (get details coinbaseInfo) u0))
      (bonusPeriod (get bonus details))
      (cityDetails (unwrap! (contract-call? .ccd005-city-data get-activation-details cityId) u0))
    )
    (asserts! (>= height (get activatedAt cityDetails)) u0)
    (asserts! (> height (get cbt1 thresholds))
      (if (<= (- height (get activatedAt cityDetails)) bonusPeriod)
        (get cbaBonus amounts)
        (get cba1 amounts)
      )
    )
    (asserts! (> height (get cbt2 thresholds)) (get cba2 amounts))
    (asserts! (> height (get cbt3 thresholds)) (get cba3 amounts))
    (asserts! (> height (get cbt4 thresholds)) (get cba4 amounts))
    (asserts! (> height (get cbt5 thresholds)) (get cba5 amounts))
    (get cbaDefault amounts)
  )
)

(define-read-only (is-mining-enabled)
  (var-get miningEnabled)
)

;; PRIVATE FUNCTIONS

(define-private (mine-block (amount uint)
  (return (response
    { cityId: uint, userId: uint, height: uint, totalAmount: uint }
    uint
  )))
  (let
    (
      (okReturn (try! return))
      (cityId (get cityId okReturn))
      (userId (get userId okReturn))
      (height (get height okReturn))
    )
    (asserts! (> amount u0) ERR_INVALID_COMMITS)
    (let
      (
        (blockStats (get-mining-stats cityId height))
        (vrfLowVal (get-high-value cityId height))
      )
      (map-set MiningStats
        { cityId: cityId, height: height }
        { miners: (+ (get miners blockStats) u1), amount: (+ (get amount blockStats) amount), claimed: false }
      )
      (asserts! (map-insert Miners
        { cityId: cityId, height: height, userId: userId }
        {
          commit: amount,
          low: (if (> vrfLowVal u0) (+ vrfLowVal u1) u0),
          high: (+ vrfLowVal amount),
          winner: false
        }
      ) ERR_ALREADY_MINED)
      (map-set HighValues
        { cityId: cityId, height: height }
        (+ vrfLowVal amount)
      )
    )
    (ok (merge okReturn
      { height: (+ height u1), totalAmount: (+ (get totalAmount okReturn) amount) }
    ))
  )
)
