---
title: "Trait test-controller"
draft: true
---
```
;; @contract Controller
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_NOT_REWARDER (err u5001))
(define-constant ERR_UPDATE_WINDOW_CLOSED (err u5002))
(define-constant ERR_ABOVE_MAX (err u5003))
(define-constant ERR_BELOW_MIN (err u5005))

(define-constant max-reward u20)
(define-constant min-update-window (* u6 u6))

(define-constant bps-base (pow u10 u4))

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var max-reward-per-window uint u10)
(define-data-var update-window uint (* u6 u8))

(define-data-var last-log-block-height uint burn-block-height)

;;-------------------------------------
;; Maps
;;-------------------------------------

(define-map rewarders
  {
    address: principal
  }
  {
    active: bool,
  }
)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-max-reward-per-window)
  (var-get max-reward-per-window)
)

(define-read-only (get-update-window)
  (var-get update-window)
)

(define-read-only (get-last-log-block-height)
  (var-get last-log-block-height)
)

(define-read-only (get-rewarder (address principal))
  (get active
    (default-to
      { active: false }
      (map-get? rewarders { address: address })
    )
  )
)

;;-------------------------------------
;; Checks
;;-------------------------------------

(define-read-only (check-is-rewarder (contract principal))
  (ok (asserts! (get-rewarder contract) ERR_NOT_REWARDER))
)

;;-------------------------------------
;; Rewarder
;;-------------------------------------

(define-public (log-reward (reward-usdh uint))
  (let (
    (total-usdh-supply (unwrap-panic (contract-call? .test-usdh-token get-total-supply)))
    (total-usdh-supply-staked (unwrap-panic (contract-call? .test-usdh-token get-balance .test-staking)))
  )
    (try! (contract-call? .test-hq check-is-enabled))
    (try! (check-is-rewarder tx-sender))
    (asserts! (> burn-block-height (+ (var-get last-log-block-height) (var-get update-window))) ERR_UPDATE_WINDOW_CLOSED)
    (asserts! (<= reward-usdh (/ (* (var-get max-reward-per-window) total-usdh-supply) bps-base)) ERR_ABOVE_MAX)
    (if (> reward-usdh u0)
      (begin
        (print {
          return-percent-of-bps: (/ (* reward-usdh bps-base u100) total-usdh-supply-staked),
          total-usdh-supply: total-usdh-supply,
          total-usdh-supply-staked: total-usdh-supply-staked,
          reward-usdh: reward-usdh
        })
        (try! (contract-call? .test-usdh-token mint-for-protocol reward-usdh .test-staking))
      )
      true
    )
    (ok (var-set last-log-block-height burn-block-height))
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-max-reward-per-window (new-max-reward-per-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (<= new-max-reward-per-window max-reward) ERR_ABOVE_MAX)
    (ok (var-set max-reward-per-window new-max-reward-per-window))
  )
)

(define-public (set-update-window (new-update-window uint))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (asserts! (>= new-update-window min-update-window) ERR_BELOW_MIN)
    (ok (var-set update-window new-update-window))
  )
)

(define-public (set-rewarder (address principal) (active bool))
  (begin
    (try! (contract-call? .test-hq check-is-protocol tx-sender))
    (ok (map-set rewarders { address: address } { active: active }))
  )
)
```
