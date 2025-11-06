;; @contract Controller
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_ZERO_ONLY_POSITIVE (err u105001))
(define-constant ERR_INSUFFICIENT_FUNDS (err u105002))
(define-constant ERR_NO_PENDING_TRANSFERS (err u105003))

(define-constant bps-base (pow u10 u4))
(define-constant pct-base (pow u10 u2))
(define-constant hbtc-base (pow u10 u8))
(define-constant fee-collector .test-fee-collector-hbtc-v1)
(define-constant rf .test-reserve-fund-hbtc2-v1)
(define-constant reserve .test-reserve-hbtc2-v1)
(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var pending-fees uint u0)
(define-data-var pending-rf uint u0)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-pending-fees)
  (var-get pending-fees))

(define-read-only (get-pending-rf)
  (var-get pending-rf))

(define-read-only (get-pending-fees-and-rf)
  { pending-fees: (var-get pending-fees), pending-rf: (var-get pending-rf) }
)

;;-------------------------------------
;; Rewarder
;;-------------------------------------

;; @desc - log the reward and update the token price
;; @param reward - the reward amount without fees and reserve fund allocations (in deposit-asset, 10**8)
;; @param is-positive - whether the reward is positive or negative  
;; @note - if reward is zero, is-positive must be true
(define-public (log-reward (reward uint) (is-positive bool))
  (let (
    (token-price (contract-call? .test-state-hbtc2-v1 get-token-price))
    (vault-balance (/ (* token-price (unwrap-panic (contract-call? .test-token-hbtc get-total-supply))) hbtc-base))
    (fees (contract-call? .test-state-hbtc2-v1 get-fees))
    (perf-fee (if is-positive (/ (* (get perf-fee fees) reward) bps-base) u0))
    (mgmt-fee (/ (* (get mgmt-fee fees) vault-balance) bps-base pct-base))
    (total-fees (+ perf-fee mgmt-fee))
    (is-profit (and is-positive (>= reward total-fees)))
    (rf-req (if is-profit
      u0
      (if is-positive 
        (if (> mgmt-fee reward) (- mgmt-fee reward) u0)
        (+ mgmt-fee reward))))
    (pending-rf-balance (var-get pending-rf))
    (rf-balance (+ (get-sbtc-balance rf) pending-rf-balance))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol-enabled))
    (try! (contract-call? .test-hq-vaults-v1 check-is-rewarder contract-caller))
    (try! (contract-call? .test-state-hbtc2-v1 check-is-update-window-open))
    (try! (contract-call? .test-state-hbtc2-v1 check-max-reward reward vault-balance))

    (asserts! (or (> reward u0) is-positive) ERR_ZERO_ONLY_POSITIVE)

    (if is-profit
      ;; Handle profit and zero scenario -> token price increases
      (try! (handle-profit reward is-positive token-price vault-balance rf-balance pending-rf-balance perf-fee mgmt-fee))
      
      ;; Handle loss scenarios
      (if (<= rf-req rf-balance)
          ;; Reserve-fund can cover the loss -> token price does not change
          (try! (handle-loss-covered reward is-positive token-price vault-balance rf-balance pending-rf-balance rf-req u0 mgmt-fee))

          ;; Reserve-fund cannot cover the loss -> token price decreases
          (try! (handle-loss-exceeds reward is-positive token-price vault-balance rf-balance pending-rf-balance rf-req u0 mgmt-fee))
        )
    )
    (ok (try! (contract-call? .test-state-hbtc2-v1 update-last-log-ts)))
  )
)

;; @desc - Process any accumulated unpaid fees and RF when funds are available
(define-public (transfer-pending)
  (let (
    (fees (var-get pending-fees))
    (pending-rf-balance (var-get pending-rf))
    (reserve-balance (get-sbtc-balance reserve))
    (total (+ fees pending-rf-balance))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-rewarder contract-caller))

    (asserts! (> total u0) ERR_NO_PENDING_TRANSFERS)
    (asserts! (>= reserve-balance total) ERR_INSUFFICIENT_FUNDS)

    ;; Process accumulated fees
    (if (> fees u0) (try! (contract-call? .test-reserve-hbtc2-v1 transfer sbtc-token fees fee-collector)) true)
    ;; Process accumulated rf transfer
    (if (> pending-rf-balance u0) (try! (contract-call? .test-reserve-hbtc2-v1 transfer sbtc-token pending-rf-balance rf)) true)

    (var-set pending-fees u0)
    (var-set pending-rf u0)
    (print { action: "transfer-pending", user: contract-caller, data: { fees: fees, rf: pending-rf-balance, reserve-balance: { old: reserve-balance, new: (- reserve-balance total) } } })
    (ok true)
  )
)

;;-------------------------------------
;; Helper Functions
;;-------------------------------------

;; @desc - Handle profit scenario
;; @param reward - original input reward amount from the trader 
;; @param token-price - current hBTC token price
;; @param vault-balance - total vault value
;; @param rf-balance - current reserve fund balance
;; @param pending-rf-balance - current pending-rf balance
;; @param perf-fee - performance fee amount
;; @param mgmt-fee - management fee amount
(define-private (handle-profit 
  (reward uint) (is-positive bool)
  (token-price uint)
  (vault-balance uint)
  (rf-balance uint) (pending-rf-balance uint)
  (perf-fee uint) (mgmt-fee uint))
  (let (
    (hbtc-supply (unwrap-panic (contract-call? .test-token-hbtc get-total-supply)))
    (reward-after-fees (- reward (+ perf-fee mgmt-fee)))
    (rf-change (/ (* reward-after-fees (contract-call? .test-state-hbtc2-v1 get-reserve-rate)) bps-base))
    (reward-token (- reward-after-fees rf-change))
    (new-token-price (+ token-price (/ (* reward-token hbtc-base) hbtc-supply)))
  )
    (print {
      action: "log-reward",
      case: (if (is-eq reward-after-fees u0) "zero" "profit"),
      user: contract-caller,
      data: {
        reward: { gross: reward, token: reward-token, is-positive: true },
        fees: { perf: perf-fee, mgmt: mgmt-fee },
        rf-balance: { old: rf-balance, new: (+ rf-balance rf-change)  },
        token-price: { old: token-price, new: new-token-price },
        vault-balance: vault-balance,
        return-percent-of-bps: (/ (* reward-token bps-base pct-base) vault-balance)
      }
    })
    
    (var-set pending-fees (+ (var-get pending-fees) perf-fee mgmt-fee))
    (var-set pending-rf (+ pending-rf-balance rf-change))
    (ok (try! (contract-call? .test-state-hbtc2-v1 set-token-price new-token-price)))
  )
)

;; @desc - Handle loss covered by reserve fund
;; @param reward - original reward amount (in deposit-asset, 10**8)
;; @param is-positive - whether the reward is positive or negative
;; @param token-price - current hBTC token price
;; @param vault-balance - total vault value
;; @param rf-balance - current reserve fund balance
;; @param rf-req - amount required from reserve fund
;; @param mgmt-fee - management fee amount
(define-private (handle-loss-covered 
  (reward uint) (is-positive bool)
  (token-price uint)
  (vault-balance uint)
  (rf-balance uint) (pending-rf-balance uint)
  (rf-req uint)
  (perf-fee uint) (mgmt-fee uint))
  (let (
    (transfer-amount (if (> rf-req pending-rf-balance)
      (- rf-req pending-rf-balance)
      u0))
  )
    (print {
      action: "log-reward",
      case: "loss-covered",
      user: contract-caller,
      data: {
        reward: { gross: reward, token: u0, is-positive: is-positive },
        fees: { perf: u0, mgmt: mgmt-fee },
        rf-balance: { old: rf-balance, new: (- rf-balance rf-req) },
        token-price: { old: token-price, new: token-price },
        vault-balance: vault-balance,
        return-percent-of-bps: u0
      }
    })
    (var-set pending-fees (+ (var-get pending-fees) mgmt-fee))
    (if (> transfer-amount u0)
      (begin 
        (var-set pending-rf u0)
        (try! (contract-call? .test-reserve-fund-hbtc2-v1 transfer sbtc-token transfer-amount reserve none))) 
      (var-set pending-rf (- pending-rf-balance rf-req))
    )
    (ok true)
  )
)

;; @desc - Handle trading loss scenario where losses exceed reserve fund capacity
;; @param reward - original reward amount from the trader
;; @param is-positive - whether the reward is positive or negative
;; @returns (response bool uint) - success response after transferring reserve fund and updating token price
(define-private (handle-loss-exceeds 
  (reward uint) (is-positive bool)
  (token-price uint)
  (vault-balance uint) 
  (rf-balance uint) (pending-rf-balance uint)
  (rf-req uint)
  (perf-fee uint) (mgmt-fee uint))
  (let (
    (hbtc-supply (unwrap-panic (contract-call? .test-token-hbtc get-total-supply)))
    (loss (- rf-req rf-balance))
    (new-token-price (- token-price (/ (* loss hbtc-base) hbtc-supply)))
  )
    (print {
      action: "log-reward",
      case: "loss-exceeds",
      user: contract-caller,
      data: {
        reward: { gross: reward, token: loss, is-positive: is-positive },
        fees: { perf: u0, mgmt: mgmt-fee },
        rf-balance: { old: rf-balance, new: u0 },
        token-price: { old: token-price, new: new-token-price },
        vault-balance: vault-balance,
        return-percent-of-bps: (/ (* loss bps-base pct-base) vault-balance)
      }
    })
    (var-set pending-fees (+ (var-get pending-fees) mgmt-fee))
    (var-set pending-rf u0)
    (if (> rf-balance pending-rf-balance)
      (try! (contract-call? .test-reserve-fund-hbtc2-v1 transfer sbtc-token (- rf-balance pending-rf-balance) reserve none))
      true
    )
    (ok (try! (contract-call? .test-state-hbtc2-v1 set-token-price new-token-price)))
  )
)

(define-private (get-sbtc-balance (contract principal))
  (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance contract))
)