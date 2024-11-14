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
    (total-usdh-staked (unwrap-panic (contract-call? .test-usdh-token get-balance .test-staking-reserve-v2)))
    (total-susdh-supply (unwrap-panic (contract-call? .test-susdh-token get-total-supply)))
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
    (try! (contract-call? .test-blacklist-susdh check-is-not-soft-blacklist tx-sender))
    (try! (contract-call? .test-hq check-is-enabled))

    (try! (contract-call? .test-usdh-token transfer amount tx-sender .test-staking-reserve-v2 none))
    (try! (contract-call? .test-susdh-token mint-for-protocol amount-susdh tx-sender))
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
    (try! (contract-call? .test-blacklist-susdh check-is-not-soft-blacklist tx-sender))

    (try! (contract-call? .test-susdh-token burn-for-protocol amount tx-sender))
    (try! (contract-call? .test-staking-silo-v2 create-claim amount-usdh tx-sender))
    (try! (contract-call? .test-staking-reserve-v2 transfer amount-usdh))
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
    (try! (contract-call? .test-usdh-token mint-for-protocol usdh-base .test-staking-reserve-v2))
    (try! (contract-call? .test-susdh-token mint-for-protocol susdh-amount .test-staking-v2))
    (ok (var-set initialized true))
  )
)