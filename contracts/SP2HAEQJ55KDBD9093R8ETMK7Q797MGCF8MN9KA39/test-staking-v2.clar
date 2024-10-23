;; @contract Staking
;; @version 1

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
    (total-usdh-staked (unwrap-panic (contract-call? .test-usdh-token-final get-balance .test-staking-v2)))
    (total-susdh-supply (unwrap-panic (contract-call? .test-susdh-token-final get-total-supply)))
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

    (try! (contract-call? .test-usdh-token-final transfer amount tx-sender .test-staking-v2 none))
    (try! (contract-call? .test-susdh-token-final mint-for-protocol amount-susdh tx-sender))
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
    (try! (contract-call? .test-hq check-is-enabled))

    (try! (contract-call? .test-susdh-token-final burn-for-protocol amount tx-sender))
    (try! (contract-call? .test-staking-silo-v2 create-claim amount-usdh tx-sender))
    (try! (contract-call? .test-usdh-token-final transfer amount-usdh (as-contract tx-sender) .test-staking-silo-v2 none))
    (print { amount-susdh: amount, amount-usdh: amount-usdh, ratio: ratio })
    (ok true)
  )
)
