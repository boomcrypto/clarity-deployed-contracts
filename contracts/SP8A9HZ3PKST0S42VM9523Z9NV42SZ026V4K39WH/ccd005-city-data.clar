;; Title: CCD005 City Data
;; Version: 1.0.0
;; Summary: A datastore for city information in the CityCoins protocol.
;; Description: An extension contract that uses the city ID as the key for storing city information. This contract is used by other CityCoins extensions to store and retrieve city information.

;; TRAITS

(impl-trait .extension-trait.extension-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u5000))
(define-constant ERR_INVALID_CITY (err u5001))
(define-constant ERR_INVALID_THRESHOLDS (err u5002))
(define-constant ERR_INVALID_AMOUNTS (err u5003))
(define-constant ERR_INVALID_DETAILS (err u5004))
(define-constant ERR_TREASURY_EXISTS (err u5005))

;; DATA MAPS

(define-map AcitvationStatus uint bool)

(define-map ActivationDetails
  uint
  { succeededAt: uint, delay: uint, activatedAt: uint, threshold: uint }
)

(define-map TreasuryNonce uint uint)

(define-map TreasuryNames
  { cityId: uint, treasuryId: uint }
  (string-ascii 10)
)

(define-map TreasuryIds
  { cityId: uint, treasuryName: (string-ascii 10) }
  uint
)

(define-map TreasuryAddress
  { cityId: uint, treasuryId: uint }
  principal
)

(define-map CoinbaseThresholds
  uint
  {
    cbt1: uint,
    cbt2: uint,
    cbt3: uint,
    cbt4: uint,
    cbt5: uint,
  }
)

(define-map CoinbaseAmounts
  uint
  {
    cbaBonus: uint,
    cba1: uint,
    cba2: uint,
    cba3: uint,
    cba4: uint,
    cba5: uint,
    cbaDefault: uint
  }
)

(define-map CoinbaseDetails
  uint
  { bonus: uint, epoch: uint }
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

(define-public (set-activation-status (cityId uint) (status bool))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
    (asserts! (not (is-eq (is-city-activated cityId) status)) ERR_UNAUTHORIZED)
    (ok (map-set AcitvationStatus cityId status))
  )
)

(define-public (set-activation-details (cityId uint) (succeededAt uint) (delay uint) (activatedAt uint) (threshold uint))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
    (ok (map-set ActivationDetails cityId {
      succeededAt: succeededAt,
      delay: delay,
      activatedAt: activatedAt,
      threshold: threshold
    }))
  )
)

(define-public (add-treasury (cityId uint) (address principal) (name (string-ascii 10)))
  (begin
    (let
      ((nonce (+ u1 (get-treasury-nonce cityId))))
      (try! (is-dao-or-extension))
      (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
      (asserts! (is-none (map-get? TreasuryIds { cityId: cityId, treasuryName: name })) ERR_TREASURY_EXISTS)
      (map-set TreasuryNonce cityId nonce)
      (map-insert TreasuryIds { cityId: cityId, treasuryName: name } nonce)
      (map-insert TreasuryNames { cityId: cityId, treasuryId: nonce } name)
      (map-insert TreasuryAddress { cityId: cityId, treasuryId: nonce } address)
      (ok nonce)
    )
  )
)

(define-public (set-coinbase-thresholds (cityId uint) (cbt1 uint) (cbt2 uint) (cbt3 uint) (cbt4 uint) (cbt5 uint))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
    (asserts! (and (> cbt1 u0) (> cbt2 cbt1) (> cbt3 cbt2) (> cbt4 cbt3) (> cbt5 cbt4)) ERR_INVALID_THRESHOLDS)
    (ok (map-set CoinbaseThresholds cityId {
      cbt1: cbt1,
      cbt2: cbt2,
      cbt3: cbt3,
      cbt4: cbt4,
      cbt5: cbt5
    }))
  )
)

(define-public (set-coinbase-amounts (cityId uint) (cbaBonus uint) (cba1 uint) (cba2 uint) (cba3 uint) (cba4 uint) (cba5 uint) (cbaDefault uint))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
    (asserts! (and (> cbaBonus u0) (> cba1 u0) (> cba2 u0) (> cba3 u0) (> cba4 u0) (> cba5 u0) (> cbaDefault u0)) ERR_INVALID_AMOUNTS)
    (ok (map-set CoinbaseAmounts cityId {
      cbaBonus: cbaBonus,
      cba1: cba1,
      cba2: cba2,
      cba3: cba3,
      cba4: cba4,
      cba5: cba5,
      cbaDefault: cbaDefault
    }))
  )
)

(define-public (set-coinbase-details (cityId uint) (bonusPeriod uint) (epochLength uint))
  (begin
    (try! (is-dao-or-extension))
    (unwrap! (contract-call? .ccd004-city-registry get-city-name cityId) ERR_INVALID_CITY)
    (asserts! (and (> bonusPeriod u0) (> epochLength u0)) ERR_INVALID_DETAILS)
    (ok (map-set CoinbaseDetails cityId {
      bonus: bonusPeriod,
      epoch: epochLength
    }))
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (get-city-info (cityId uint) (treasuryName (string-ascii 10)))
  {
    activatedAt: (is-city-activated cityId),
    details: (get-activation-details cityId),
    treasury: (get-treasury-by-name cityId treasuryName),
  }
)

(define-read-only (is-city-activated (cityId uint))
  (default-to false (map-get? AcitvationStatus cityId))
)

(define-read-only (get-activation-details (cityId uint))
  (map-get? ActivationDetails cityId)
)

(define-read-only (get-treasury-nonce (cityId uint))
  (default-to u0 (map-get? TreasuryNonce cityId))
)

(define-read-only (get-treasury-id (cityId uint) (treasuryName (string-ascii 10)))
  (map-get? TreasuryIds { cityId: cityId, treasuryName: treasuryName })
)

(define-read-only (get-treasury-name (cityId uint) (treasuryId uint))
  (map-get? TreasuryNames { cityId: cityId, treasuryId: treasuryId })
)

(define-read-only (get-treasury-address (cityId uint) (treasuryId uint))
  (map-get? TreasuryAddress { cityId: cityId, treasuryId: treasuryId })
)

(define-read-only (get-treasury-by-name (cityId uint) (treasuryName (string-ascii 10)))
  (let
    ((treasuryId (unwrap! (map-get? TreasuryIds { cityId: cityId, treasuryName: treasuryName }) none)))
    (map-get? TreasuryAddress { cityId: cityId, treasuryId: treasuryId })
  )
)

(define-read-only (get-coinbase-info (cityId uint))
  {
    thresholds: (map-get? CoinbaseThresholds cityId),
    amounts: (map-get? CoinbaseAmounts cityId),
    details: (map-get? CoinbaseDetails cityId)
  }
)
