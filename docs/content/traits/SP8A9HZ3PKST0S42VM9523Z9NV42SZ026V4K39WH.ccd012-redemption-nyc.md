---
title: "Trait ccd012-redemption-nyc"
draft: true
---
```
;; Title: CCD012 - CityCoin Redemption (NYC)
;; Version: 1.0.0
;; Summary: A redemption extension that allows users to redeem CityCoins for a portion of the city treasury.
;; Description: An extension that provides the ability to claim a portion of the city treasury in exchange for CityCoins.

;; TRAITS

(impl-trait .extension-trait.extension-trait)

;; CONSTANTS

;; error codes
(define-constant ERR_UNAUTHORIZED (err u12000))
(define-constant ERR_PANIC (err u12001))
(define-constant ERR_GETTING_TOTAL_SUPPLY (err u12002))
(define-constant ERR_GETTING_REDEMPTION_BALANCE (err u12003))
(define-constant ERR_ALREADY_ENABLED (err u12004))
(define-constant ERR_NOT_ENABLED (err u12005))
(define-constant ERR_BALANCE_NOT_FOUND (err u12006))
(define-constant ERR_NOTHING_TO_REDEEM (err u12007))
(define-constant ERR_ALREADY_CLAIMED (err u12008))
(define-constant ERR_SUPPLY_CALCULATION (err u12009))

;; helpers
(define-constant SELF (as-contract tx-sender))
(define-constant MICRO_CITYCOINS (pow u10 u6)) ;; 6 decimal places
(define-constant REDEMPTION_SCALE_FACTOR (pow u10 u8)) ;; 8 decimal places

;; DATA VARS

(define-data-var redemptionsEnabled bool false)
(define-data-var blockHeight uint u0)
(define-data-var totalSupply uint u0)
(define-data-var contractBalance uint u0)
(define-data-var redemptionRatio uint u0)
(define-data-var totalRedeemed uint u0)

;; DATA MAPS

;; track totals per principal
(define-map RedemptionClaims
  principal ;; address
  uint      ;; total redemption amount
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

;; initialize contract after deployment to start redemptions
(define-public (initialize-redemption)
  (let
    (
      (nycTotalSupplyV1 (unwrap! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-total-supply) ERR_PANIC))
      (nycTotalSupplyV2 (unwrap! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-total-supply) ERR_PANIC))
      (nycTotalSupply (+ (* nycTotalSupplyV1 MICRO_CITYCOINS) nycTotalSupplyV2))
      (nycRedemptionBalance (get-redemption-contract-current-balance))
      (nycRedemptionRatio (calculate-redemption-ratio nycRedemptionBalance nycTotalSupply))
    )
    ;; check if sender is DAO or extension
    (try! (is-dao-or-extension))
    ;; check that total supply is greater than 0
    (asserts! (> nycTotalSupply u0) ERR_GETTING_TOTAL_SUPPLY)
    ;; check that redemption balance is greater than 0
    (asserts! (> nycRedemptionBalance u0) ERR_GETTING_REDEMPTION_BALANCE)
    ;; check that redemption ratio has a value
    (asserts! (is-some nycRedemptionRatio) ERR_SUPPLY_CALCULATION)
    ;; check if redemptions are already enabled
    (asserts! (not (var-get redemptionsEnabled)) ERR_ALREADY_ENABLED)
    ;; record current block height
    (var-set blockHeight block-height)
    ;; record total supply at block height
    (var-set totalSupply nycTotalSupply)
    ;; record contract balance at block height
    (var-set contractBalance nycRedemptionBalance)
    ;; calculate redemption ratio
    (var-set redemptionRatio (unwrap-panic nycRedemptionRatio))
    ;; set redemptionsEnabled to true, can only run once
    (var-set redemptionsEnabled true)
    ;; print redemption info
    (ok (print {
      notification: "intialize-contract",
      payload: (get-redemption-info)
      }))
  )
)

(define-public (redeem-nyc)
  (let
    (
      (userAddress tx-sender)
      (balanceV1 (unwrap! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance userAddress) ERR_BALANCE_NOT_FOUND))
      (balanceV2 (unwrap! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-balance userAddress) ERR_BALANCE_NOT_FOUND))
      (totalBalance (+ (* balanceV1 MICRO_CITYCOINS) balanceV2))
      (redemptionAmount (get-redemption-for-balance totalBalance))
      (redemptionClaimed (default-to u0 (get-redemption-amount-claimed userAddress)))
    )
    ;; check if redemptions are enabled
    (asserts! (var-get redemptionsEnabled) ERR_NOT_ENABLED)
    ;; check that user has at least one positive balance
    (asserts! (> (+ balanceV1 balanceV2) u0) ERR_BALANCE_NOT_FOUND) ;; cheaper, credit: LNow
    ;; check that contract has a positive balance
    (asserts! (> (get-redemption-contract-current-balance) u0) ERR_NOTHING_TO_REDEEM)
    ;; check that redemption amount is > 0
    (asserts! (and (is-some redemptionAmount) (> (unwrap-panic redemptionAmount) u0)) ERR_NOTHING_TO_REDEEM)
    ;; burn NYC
    (and (> balanceV1 u0) (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token burn balanceV1 userAddress)))
    (and (> balanceV2 u0) (try! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 burn balanceV2 userAddress)))
    ;; transfer STX
    (try! (as-contract (stx-transfer? (unwrap-panic redemptionAmount) SELF userAddress)))
    ;; update redemption claims
    (var-set totalRedeemed (+ (var-get totalRedeemed) (unwrap-panic redemptionAmount)))
    (map-set RedemptionClaims userAddress (+ redemptionClaimed (unwrap-panic redemptionAmount)))
    ;; print redemption info
    (print {
      notification: "contract-redemption",
      payload: (get-redemption-info)
    })
    ;; print user redemption info
    (print {
      notification: "user-redemption",
      payload: (try! (get-user-redemption-info userAddress))
    })
    ;; return redemption amount
    (ok redemptionAmount)
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-redemption-enabled)
  (var-get redemptionsEnabled)
)

(define-read-only (get-redemption-block-height)
  (var-get blockHeight)
)

(define-read-only (get-redemption-total-supply)
  (var-get totalSupply)
)

(define-read-only (get-redemption-contract-balance)
  (var-get contractBalance)
)

(define-read-only (get-redemption-contract-current-balance)
  (stx-get-balance SELF)
)

(define-read-only (get-redemption-ratio)
  (var-get redemptionRatio)
)

(define-read-only (get-total-redeemed)
  (var-get totalRedeemed)
)

;; aggregate all exposed vars above
(define-read-only (get-redemption-info)
  {
    redemptionsEnabled: (is-redemption-enabled),
    blockHeight: (get-redemption-block-height),
    totalSupply: (get-redemption-total-supply),
    contractBalance: (get-redemption-contract-balance),
    currentContractBalance: (get-redemption-contract-current-balance),
    redemptionRatio: (get-redemption-ratio),
    totalRedeemed: (get-total-redeemed)
  }
)

(define-read-only (get-nyc-balances (address principal))
  (let
    (
      (balanceV1 (unwrap! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance address) ERR_BALANCE_NOT_FOUND))
      (balanceV2 (unwrap! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-balance address) ERR_BALANCE_NOT_FOUND))
      (totalBalance (+ (* balanceV1 MICRO_CITYCOINS) balanceV2))
    )
    (ok {
      address: address,
      balanceV1: balanceV1,
      balanceV2: balanceV2,
      totalBalance: totalBalance
    })
  )
)

(define-read-only (get-redemption-for-balance (balance uint))
  (let
    (
      (redemptionAmountScaled (* (var-get redemptionRatio) balance))
      (redemptionAmount (/ redemptionAmountScaled REDEMPTION_SCALE_FACTOR))
      (contractCurrentBalance (get-redemption-contract-current-balance))
    )
    (if (> redemptionAmount u0)
      (if (< redemptionAmount contractCurrentBalance)
        ;; if redemption amount is less than contract balance, return redemption amount
        (some redemptionAmount)
        ;; if redemption amount is greater than contract balance, return contract balance
        (some contractCurrentBalance)
      )
      ;; if redemption amount is 0, return none
      none
    )
  )
)

(define-read-only (get-redemption-amount-claimed (address principal))
    (map-get? RedemptionClaims address)
)

;; aggregate all exposed vars above
(define-read-only (get-user-redemption-info (address principal))
  (let
    (
      (nycBalances (try! (get-nyc-balances address)))
      (redemptionAmount (default-to u0 (get-redemption-for-balance (get totalBalance nycBalances))))
      (redemptionClaims (default-to u0 (get-redemption-amount-claimed address)))
    )
    (ok {
      address: address,
      nycBalances: nycBalances,
      redemptionAmount: redemptionAmount,
      redemptionClaims: redemptionClaims
    })
  )
)

;; PRIVATE FUNCTIONS

;; CREDIT: ALEX math-fixed-point-16.clar

(define-private (scale-up (a uint))
  (* a REDEMPTION_SCALE_FACTOR)
)

;; modified to favor the user when scaling down
(define-private (scale-down (a uint))
  (let
    (
      (quotient (/ a REDEMPTION_SCALE_FACTOR))
      (remainder (mod a REDEMPTION_SCALE_FACTOR))
    )
    (if (> remainder u0)
      (+ quotient u1)
      quotient
    )
  )
)


(define-private (calculate-redemption-ratio (balance uint) (supply uint))
  (if (or (is-eq supply u0) (is-eq balance u0))
    none
    (let
      (
        (scaledBalance (* balance REDEMPTION_SCALE_FACTOR))
      )
      (some (/ scaledBalance supply))
    )
  )
)

```
