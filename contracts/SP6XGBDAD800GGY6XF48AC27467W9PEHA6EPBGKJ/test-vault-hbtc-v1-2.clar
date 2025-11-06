;; @contract Vault
;; @version 1

(use-trait ft .sip-010-trait.sip-010-trait)
(use-trait silo-trait .test-silo-trait4-v1.silo-trait)

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_DEPOSIT_CAP_EXCEEDED (err u103001))
(define-constant ERR_INVALID_AMOUNT (err u103002))
(define-constant ERR_BELOW_MIN_DEPOSIT_AMOUNT (err u103003))

(define-constant hbtc-base (pow u10 u8))                              ;; 10**8

(define-constant reserve .test-reserve-hbtc-v1-1)

;;-------------------------------------
;; User
;;-------------------------------------

;; @desc - deposit asset to mint token
;; @param - amount: amount of asset to deposit (10**8)
;; @param - affiliate: affiliate of the deposit transaction (optional)
(define-public (deposit (amount uint) (affiliate (optional (buff 64))))
  (let (
    (price (contract-call? .test-state-hbtc-v1-1 get-token-price))
    (amount-token (/ (* amount hbtc-base) price))
    (supply (unwrap-panic (contract-call? .test-token-hbtc-v1-1 get-total-supply)))
    (vault-balance (/ (* price supply) hbtc-base))
  )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v1-1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-deposit-enabled))
    (asserts! (<= (+ vault-balance amount) (contract-call? .test-state-hbtc-v1-1 get-deposit-cap)) ERR_DEPOSIT_CAP_EXCEEDED)
    (asserts! (>= amount (contract-call? .test-state-hbtc-v1-1 get-min-deposit-amount)) ERR_BELOW_MIN_DEPOSIT_AMOUNT)
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer amount contract-caller reserve none))
    (print { action: "deposit", user: contract-caller, data: { amount-asset: amount, amount-token: amount-token, price: price, affiliate: affiliate } })
    (ok (try! (contract-call? .test-token-hbtc-v1-1 mint-for-protocol amount-token contract-caller)))
  )
)

;; @desc - creates a claim to withdraw asset after cooldown period has passed 
;; @param - amount: amount of token to withdraw (10**8)
;; @param - silo: silo to which the asset is transferred to
(define-public (init-withdraw (amount uint) (silo <silo-trait>))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (contract-call? .test-blacklist-vaults-v1-1 check-is-not-soft-blacklist contract-caller))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-withdraw-enabled))
    (try! (contract-call? .test-state-hbtc-v1-1 check-is-silo (contract-of silo)))

    (print { action: "init-withdraw", user: contract-caller, data: { amount: amount, silo: silo } })
    (ok (try! (contract-call? silo create-claim amount contract-caller)))
  )
)