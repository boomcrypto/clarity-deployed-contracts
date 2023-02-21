;; Title: CCD007 CityCoin Stacking
;; Version: 1.0.0
;; Summary: A central city stacking contract for the CityCoins protocol.
;; Description: An extension that provides a stacking interface per city, in which a user can lock their CityCoins for a specified number of cycles, in return for a proportion of the stacking rewards accrued by the related city wallet.

;; TRAITS

(impl-trait .extension-trait.extension-trait)
(impl-trait .ccd007-trait.ccd007-citycoin-stacking-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u7000))
(define-constant ERR_INVALID_CITY (err u7001))
(define-constant ERR_INVALID_PARAMS (err u7002))
(define-constant ERR_INACTIVE_CITY (err u7003))
(define-constant ERR_INVALID_USER (err u7004))
(define-constant ERR_INVALID_TREASURY (err u7005))
(define-constant ERR_INCOMPLETE_CYCLE (err u7006))
(define-constant ERR_NOTHING_TO_CLAIM (err u7007))
(define-constant ERR_PAYOUT_COMPLETE (err u7008))
(define-constant ERR_STACKING_DISABLED (err u7009))
(define-constant MAX_REWARD_CYCLES u32)
(define-constant REWARD_CYCLE_LENGTH u2100)
(define-constant FIRST_STACKING_BLOCK u666050)

;; DATA VARS

(define-data-var stackingEnabled bool true)

;; DATA MAPS

(define-map StackingStats
  { cityId: uint, cycle: uint }
  { total: uint, reward: (optional uint) }
)

(define-map Stacker
  { cityId: uint, cycle: uint, userId: uint }
  { stacked: uint, claimable: uint }
)

;; PUBLIC FUNCTIONS

(define-public (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .base-dao)
    (contract-call? .base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-public (is-extension)
  (ok (asserts! (contract-call? .base-dao is-extension contract-caller) ERR_UNAUTHORIZED))
)

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

(define-public (stack (cityName (string-ascii 10)) (amount uint) (lockPeriod uint))
  (let
    (
      (cityId (unwrap! (contract-call? .ccd004-city-registry get-city-id cityName) ERR_INVALID_CITY))
      (user tx-sender)
      (userId (try! (as-contract (contract-call? .ccd003-user-registry get-or-create-user-id user))))
      (cityTreasury (unwrap! (contract-call? .ccd005-city-data get-treasury-by-name cityId "stacking") ERR_INVALID_TREASURY))
      (cycleId (+ u1 (get-reward-cycle burn-block-height)))
    )
    (asserts! (var-get stackingEnabled) ERR_STACKING_DISABLED)
    (asserts! (contract-call? .ccd005-city-data is-city-activated cityId) ERR_INACTIVE_CITY)
    (asserts! (and (> amount u0) (> lockPeriod u0) (<= lockPeriod MAX_REWARD_CYCLES)) ERR_INVALID_PARAMS)
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) cycleId)
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u1))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u2))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u3))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u4))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u5))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u6))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u7))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u8))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u9))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u10))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u11))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u12))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u13))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u14))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u15))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u16))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u17))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u18))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u19))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u20))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u21))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u22))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u23))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u24))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u25))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u26))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u27))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u28))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u29))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u30))
    (stack-at-cycle cityId userId amount cycleId (+ cycleId lockPeriod) (+ cycleId u31))
    ;; contract addresses hardcoded for this version
    (and (is-eq cityName "mia") (try! (contract-call? .ccd002-treasury-mia-stacking deposit-ft 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 amount)))
    (and (is-eq cityName "nyc") (try! (contract-call? .ccd002-treasury-nyc-stacking deposit-ft 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 amount)))
    (print {
      event: "stacking",
      amountStacked: amount,
      cityId: cityId,
      cityName: cityName,
      cityTreasury: cityTreasury,
      firstCycle: cycleId,
      lastCycle: (- (+ cycleId lockPeriod) u1),
      lockPeriod: lockPeriod,
      userId: userId
    })
    (ok true)
  )
)

(define-public (set-stacking-reward (cityId uint) (cycleId uint) (amount uint))
  (let
    ((cycleStats (get-stacking-stats cityId cycleId)))
    (try! (is-extension))
    (asserts! (is-none (get reward cycleStats)) ERR_PAYOUT_COMPLETE)
    (asserts! (or (not (var-get stackingEnabled)) (< cycleId (get-reward-cycle burn-block-height))) ERR_INCOMPLETE_CYCLE)
    (ok (map-set StackingStats
      { cityId: cityId, cycle: cycleId }
      (merge cycleStats { reward: (some amount) })
    ))
  )
)

(define-public (claim-stacking-reward (cityName (string-ascii 10)) (cycleId uint))
  (let
    (
      (cityId (unwrap! (contract-call? .ccd004-city-registry get-city-id cityName) ERR_INVALID_CITY))
      (user tx-sender)
      (userId (unwrap! (contract-call? .ccd003-user-registry get-user-id user) ERR_INVALID_USER))
      (stacker (get-stacker cityId cycleId userId))
      (reward (unwrap! (get-stacking-reward cityId userId cycleId) ERR_NOTHING_TO_CLAIM))
      (claimable (get claimable stacker))
    )
    (asserts! (or (not (var-get stackingEnabled)) (< cycleId (get-reward-cycle burn-block-height))) ERR_INCOMPLETE_CYCLE)
    (asserts! (or (> reward u0) (> claimable u0)) ERR_NOTHING_TO_CLAIM)
    ;; contract addresses hardcoded for this version
    (and (is-eq cityName "mia")
      (begin
        (and (> reward u0) (try! (as-contract (contract-call? .ccd002-treasury-mia-stacking withdraw-stx reward user))))
        (and (> claimable u0) (try! (as-contract (contract-call? .ccd002-treasury-mia-stacking withdraw-ft 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 claimable user))))
      )
    )
    (and (is-eq cityName "nyc")
      (begin
        (and (> reward u0) (try! (as-contract (contract-call? .ccd002-treasury-nyc-stacking withdraw-stx reward user))))
        (and (> claimable u0) (try! (as-contract (contract-call? .ccd002-treasury-nyc-stacking withdraw-ft 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 claimable user))))
      )
    )
    (print {
      event: "stacking-claim",
      cityId: cityId,
      cityName: cityName,
      claimable: claimable,
      reward: reward,
      cycleId: cycleId,
      userId: userId
    })
    (ok (map-set Stacker
      { cityId: cityId, cycle: cycleId, userId: userId }
      { stacked: u0, claimable: u0 }
    ))
  )
)

(define-public (set-stacking-enabled (status bool))
  (begin
    (try! (is-dao-or-extension))
    (print {
      event: "set-stacking-enabled",
      stackingEnabled: status
    })
    (ok (var-set stackingEnabled status))
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (get-reward-cycle-length)
  REWARD_CYCLE_LENGTH
)

(define-read-only (get-stacking-stats (cityId uint) (cycle uint))
  (default-to { total: u0, reward: none }
    (map-get? StackingStats { cityId: cityId, cycle: cycle })
  )
)

(define-read-only (get-stacker (cityId uint) (cycle uint) (userId uint))
  (default-to { stacked: u0, claimable: u0 }
    (map-get? Stacker { cityId: cityId, cycle: cycle, userId: userId })
  )
)

(define-read-only (get-current-reward-cycle)
  (get-reward-cycle burn-block-height)
)

(define-read-only (get-reward-cycle (burnHeight uint))
  (/ (- burnHeight FIRST_STACKING_BLOCK) REWARD_CYCLE_LENGTH)
)

(define-read-only (get-first-block-in-reward-cycle (cycle uint))
  (+ FIRST_STACKING_BLOCK (* cycle REWARD_CYCLE_LENGTH))
)

(define-read-only (is-stacking-active (cityId uint) (cycle uint))
  (is-some (map-get? StackingStats { cityId: cityId, cycle: cycle }))
)

(define-read-only (is-cycle-paid (cityId uint) (cycle uint))
  (is-some (get reward (get-stacking-stats cityId cycle)))
)

(define-read-only (get-stacking-reward (cityId uint) (userId uint) (cycle uint))
  (let
    (
      (cycleStats (get-stacking-stats cityId cycle))
      (stacker (get-stacker cityId cycle userId))
      (userStacked (get stacked stacker))
    )
    (if (and (or (not (var-get stackingEnabled)) (< cycle  (get-reward-cycle burn-block-height))) (> userStacked u0))
      (some (/ (* (unwrap! (get reward cycleStats) (some u0)) userStacked) (get total cycleStats)))
      none
    )
  )
)

(define-read-only (is-stacking-enabled)
  (var-get stackingEnabled)
)

;; PRIVATE FUNCTIONS

(define-private (stack-at-cycle (cityId uint) (userId uint) (amount uint) (first uint) (last uint) (target uint))
  (let
    (
      (cycleStats (get-stacking-stats cityId target))
      (stacker (get-stacker cityId target userId))
    )
    (and (>= target first) (< target last)
      (map-set StackingStats
        { cityId: cityId, cycle: target }
        (merge cycleStats { total: (+ amount (get total cycleStats)) })
      )
      (map-set Stacker
        { cityId: cityId, cycle: target, userId: userId }
        (merge stacker {
          stacked: (+ amount (get stacked stacker)),
          claimable: (if (is-eq target (- last u1))
            (+ amount (get claimable stacker))
            (get claimable stacker)
        )})
      )
    )
  )
)
