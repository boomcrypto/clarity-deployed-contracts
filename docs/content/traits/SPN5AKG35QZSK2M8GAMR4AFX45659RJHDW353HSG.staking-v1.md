---
title: "Trait staking-v1"
draft: true
---
```
;; @contract Staking
;; @version 1

;;-------------------------------------
;; Constants & Variables
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u3001))
(define-constant ERR_ALREADY_INITALIZED (err u3002))

(define-constant usdh-base (pow u10 u8))

(define-data-var initialized bool false)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-usdh-per-susdh) 
  (let (
    (total-usdh-staked (unwrap-panic (contract-call? .usdh-token-v1 get-balance .staking-v1)))
    (total-susdh-supply (unwrap-panic (contract-call? .susdh-token-v1 get-total-supply)))
  )
    (if (and (> total-usdh-staked u0) (> total-susdh-supply u0))
      (/
        (*
          total-usdh-staked
          usdh-base
        )
        total-susdh-supply
      )
      usdh-base
    )
  )
)

;;-------------------------------------
;; User
;;-------------------------------------

(define-public (stake (amount uint))
  (let (
    (ratio (get-usdh-per-susdh))
    (amount-susdh (/ (* amount usdh-base) ratio))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .blacklist-susdh-v1 check-is-not-soft-blacklist tx-sender))
    (try! (contract-call? .hq-v1 check-is-enabled))

    (try! (contract-call? .usdh-token-v1 transfer amount tx-sender .staking-v1 none))
    (try! (contract-call? .susdh-token-v1 mint-for-protocol amount-susdh tx-sender))
    (print { amount-susdh: amount-susdh, amount-usdh: amount, ratio: ratio })
    (ok true)
  )
)

(define-public (unstake (amount uint))
  (let (
    (ratio (get-usdh-per-susdh))
    (amount-usdh (/ (* amount ratio) usdh-base))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .blacklist-susdh-v1 check-is-not-soft-blacklist tx-sender))
    (try! (contract-call? .hq-v1 check-is-enabled))

    (try! (contract-call? .susdh-token-v1 burn-for-protocol amount tx-sender))
    (try! (contract-call? .staking-silo-v1 create-claim amount-usdh tx-sender))
    (try! (contract-call? .usdh-token-v1 transfer amount-usdh (as-contract tx-sender) .staking-silo-v1 none))
    (print { amount-susdh: amount, amount-usdh: amount-usdh, ratio: ratio })
    (ok true)
  )
)

;;-------------------------------------
;; Init
;;-------------------------------------

(define-public (init-usdh-per-susdh (ratio uint)) 
  (let (
    (susdh-amount (/ (* usdh-base usdh-base) ratio))
  )
    (asserts! (not (var-get initialized)) ERR_ALREADY_INITALIZED)
    (asserts! (>= ratio usdh-base) ERR_INVALID_AMOUNT)
    (try! (contract-call? .usdh-token-v1 mint-for-protocol usdh-base .staking-v1))
    (try! (contract-call? .susdh-token-v1 mint-for-protocol susdh-amount .staking-v1))
    (ok (var-set initialized true))
  )
)
```
