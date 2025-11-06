;; @contract Staking
;; @version 1.1

(impl-trait .staking-trait-v1.staking-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u3001))

(define-constant usdh-base (pow u10 u8))

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-usdh-per-susdh) 
  (let (
    (total-usdh-staked (unwrap-panic (contract-call? .usdh-token-v1 get-balance .staking-reserve-v1)))
    (total-susdh-supply (unwrap-panic (contract-call? .susdh-token-v1 get-total-supply)))
  )
    (ok (if (and (> total-usdh-staked u0) (> total-susdh-supply u0))
      (/
        (*
          total-usdh-staked
          usdh-base
        )
        total-susdh-supply
      )
      usdh-base
    ))
  )
)

;;-------------------------------------
;; User
;;-------------------------------------

(define-public (stake (amount uint) (affiliate (optional (buff 64))))
  (let (
    (ratio (unwrap-panic (get-usdh-per-susdh)))
    (amount-susdh (/ (* amount usdh-base) ratio))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .staking-state-v1 check-is-staking-enabled))
    (try! (contract-call? .blacklist-susdh-v1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .hq-v1 check-is-enabled))

    (try! (contract-call? .usdh-token-v1 transfer amount contract-caller .staking-reserve-v1 none))
    (try! (contract-call? .susdh-token-v1 mint-for-protocol amount-susdh contract-caller))
    (print { action: "stake", user: contract-caller, data: { amount-susdh: amount-susdh, amount-usdh: amount, ratio: ratio, affiliate: affiliate } })
    (ok true)
  )
)

(define-public (unstake (amount uint))
  (let (
    (ratio (unwrap-panic (get-usdh-per-susdh)))
    (amount-usdh (/ (* amount ratio) usdh-base))
    (claim-id (try! (contract-call? .staking-silo-v1-1 create-claim amount-usdh contract-caller)))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .blacklist-susdh-v1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .hq-v1 check-is-enabled))

    (try! (contract-call? .susdh-token-v1 burn-for-protocol amount contract-caller))
    (try! (contract-call? .staking-reserve-v1 transfer amount-usdh .staking-silo-v1-1))
    (print { action: "unstake", user: contract-caller, data: { amount-susdh: amount, amount-usdh: amount-usdh, ratio: ratio } })
    (ok claim-id)
  )
)