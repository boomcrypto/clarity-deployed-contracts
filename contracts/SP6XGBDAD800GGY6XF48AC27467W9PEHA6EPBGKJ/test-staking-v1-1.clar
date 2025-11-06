;; @contract Staking
;; @version 1.1

(impl-trait .staking-trait-v1.staking-trait)

;;-------------------------------------
;; Constants & Variables
;;-------------------------------------

(define-constant ERR_INVALID_AMOUNT (err u3001))

(define-constant usdh-base (pow u10 u8))

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-usdh-per-susdh) 
  (let (
    (total-usdh-staked (unwrap-panic (contract-call? .test-usdh-token-v1 get-balance .test-staking-reserve-v1)))
    (total-susdh-supply (unwrap-panic (contract-call? .test-susdh-token-v1 get-total-supply)))
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

;; @desc - stake USDh to mint sUSDh
;; @param - amount: USDh to stake (10**8)
(define-public (stake (amount uint) (affiliate (optional (buff 64))))
  (let (
    (ratio (unwrap-panic (get-usdh-per-susdh)))
    (amount-susdh (/ (* amount usdh-base) ratio))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-susdh-v1 check-is-not-soft-blacklist tx-sender))
    (try! (contract-call? .test-hq-v1 check-is-enabled))

    (try! (contract-call? .test-usdh-token-v1 transfer amount tx-sender .test-staking-reserve-v1 none))
    (try! (contract-call? .test-susdh-token-v1 mint-for-protocol amount-susdh tx-sender))
    (print { action: "stake", user: contract-caller, data: { amount-susdh: amount-susdh, amount-usdh: amount, ratio: ratio, affiliate: affiliate }})
    (ok true)
  )
)

;; @desc - creates a claim to unstake sUSDh, there is a cooldown period before the USDh can be claimed
;; @param - amount: sUSDh to unstake (10**8)
(define-public (unstake (amount uint))
  (let (
    (ratio (unwrap-panic (get-usdh-per-susdh)))
    (amount-usdh (/ (* amount ratio) usdh-base))
    (claim-id (+ u1 (contract-call? .test-staking-silo-v1-1 get-current-claim-id)))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-susdh-v1 check-is-not-soft-blacklist tx-sender))
    (try! (contract-call? .test-hq-v1 check-is-enabled))

    (try! (contract-call? .test-susdh-token-v1 burn-for-protocol amount tx-sender))
    (try! (contract-call? .test-staking-silo-v1-1 create-claim amount-usdh tx-sender))
    (try! (contract-call? .test-staking-reserve-v1 transfer amount-usdh .test-staking-silo-v1-1))
    (print {action: "unstake", user: contract-caller, data: { amount-susdh: amount, amount-usdh: amount-usdh, ratio: ratio }})
    (ok claim-id)
  )
)
