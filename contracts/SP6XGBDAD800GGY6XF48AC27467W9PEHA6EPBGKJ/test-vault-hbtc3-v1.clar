;; @contract Vault
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait silo-trait .test-silo-trait2-v1.silo-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_DEPOSIT_CAP_EXCEEDED (err u103001))
(define-constant ERR_INVALID_AMOUNT (err u103002))
(define-constant ERR_BELOW_MIN_DEPOSIT_AMOUNT (err u103003))

(define-constant bps-base (pow u10 u4))                               ;; 100%
(define-constant hbtc-base (pow u10 u8))                              ;; 10**8

;;-------------------------------------
;; User
;;-------------------------------------

;; @desc - deposit deposit-asset to mint token
;; @param - amount: deposit-asset to deposit (10**8)
(define-public (deposit (amount uint) (affiliate (optional (buff 64))))
  (let (
    (price (contract-call? .test-state-hbtc2-v1 get-token-price))
    (amount-token (/ (* amount hbtc-base) price))
    (supply (unwrap-panic (contract-call? .test-token-hbtc get-total-supply)))
    (vault-balance (/ (* price supply) hbtc-base))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-deposit-enabled))
    (asserts! (<= (+ vault-balance amount) (contract-call? .test-state-hbtc2-v1 get-deposit-cap)) ERR_DEPOSIT_CAP_EXCEEDED)
    (asserts! (>= amount (contract-call? .test-state-hbtc2-v1 get-min-deposit-amount)) ERR_BELOW_MIN_DEPOSIT_AMOUNT)
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount contract-caller .test-reserve-hbtc2-v1 none))
    (print { action: "deposit", user: contract-caller, data: { amount-asset: amount, amount-token: amount-token, price: price, affiliate: affiliate } })
    (ok (try! (contract-call? .test-token-hbtc mint-for-protocol amount-token contract-caller)))
  )
)

;; @desc - creates a claim to withdraw deposit-asset, there is a cooldown period before the deposit-asset can be claimed
;; @param - amount: token to withdraw (10**8)
;; @param - silo: silo to which the withdraw is transferred to
(define-public (init-withdraw (amount uint) (silo <silo-trait>))
  (let (
    (price (contract-call? .test-state-hbtc2-v1 get-token-price))
    (amount-deposit-asset (/ (* amount price) hbtc-base))
    (exit-fee (contract-call? .test-state-hbtc2-v1 get-custom-exit-fee contract-caller))
    (fee-amount (/ (* amount-deposit-asset exit-fee) bps-base))
    (amount-after-fee (- amount-deposit-asset fee-amount))
    (silo-contract (contract-of silo))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-withdraw-enabled))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-silo silo-contract))

    (try! (contract-call? .test-token-hbtc burn-for-protocol amount contract-caller))
    (print { action: "init-withdraw", user: contract-caller, data: { amount-token: amount, price: price, fee-amount: fee-amount, amount-asset-after-fee: amount-after-fee, silo: silo } })
    (ok (try! (contract-call? silo create-claim amount-after-fee fee-amount contract-caller)))
  )
)