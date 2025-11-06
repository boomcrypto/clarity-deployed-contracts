;; @contract Controller
;; @version 0.1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_ZERO_ONLY_POSITIVE (err u104001))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104002))
(define-constant ERR_NO_PENDING_TRANSFERS (err u104003))

(define-constant bps-base (pow u10 u4))
(define-constant pct-base (pow u10 u2))
(define-constant share-base (pow u10 u8))
(define-constant fee-collector .test-fee-collector-hbtc-v3)
(define-constant rf .test-reserve-fund-hbtc-v3)
(define-constant reserve .test-reserve-hbtc-v3)
(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

;;-------------------------------------
;; Rewarder
;;-------------------------------------

;; @desc - log the reward and update the token price
;; @param - reward: the reward amount without fees and reserve fund allocations (in deposit-asset, 10**8)
;; @param - is-positive: whether the reward is positive or negative  
;; @note - if reward is zero, is-positive must be true
(define-public (log-reward (reward uint) (is-positive bool))
  (let (
    (state (contract-call? .test-state-hbtc-v3 get-reward-state))
    (total-assets (get total-assets state))
    (fees (get fees state))
    (pending-rf (get pending-rf state))
    (reserve-rate (get reserve-rate state))
    (perf-fee (if is-positive (/ (* (get perf-fee fees) reward) bps-base) u0))
    (mgmt-fee (/ (* (get mgmt-fee fees) total-assets) bps-base pct-base))
    (total-fees (+ perf-fee mgmt-fee))
    (is-profit (and is-positive (>= reward total-fees)))
    (req-rf (if is-profit
      u0
      (if is-positive 
        (if (> mgmt-fee reward) (- mgmt-fee reward) u0)
        (+ mgmt-fee reward))))
    (total-rf (+ (get-sbtc-balance rf) pending-rf))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-protocol-active))
    (try! (contract-call? .test-hq-vaults-v3 check-is-rewarder contract-caller))
    (try! (contract-call? .test-state-hbtc-v3 check-max-reward reward))

    (asserts! (or (> reward u0) is-positive) ERR_ZERO_ONLY_POSITIVE)

    (if is-profit
      ;; Handle profit and zero scenario -> token price increases
      (try! (handle-profit reward is-positive total-rf pending-rf perf-fee mgmt-fee reserve-rate))
      
      ;; Handle loss scenarios
      (if (<= req-rf total-rf)
          ;; Reserve-fund can cover the loss -> token price does not change
          (try! (handle-loss-covered reward is-positive total-rf pending-rf req-rf u0 mgmt-fee))

          ;; Reserve-fund cannot cover the loss -> token price decreases
          (try! (handle-loss-exceeds reward is-positive total-rf pending-rf req-rf u0 mgmt-fee))
        )
    )
    (ok true)
  )
)

;; @desc - Process any accumulated unpaid fees and RF when funds are available
(define-public (fund-transfers)
  (let (
    (pending (contract-call? .test-state-hbtc-v3 get-pending))
    (pending-fees (get fees pending))
    (pending-rf (get rf pending))
    (total-reserve (get-sbtc-balance reserve))
    (total-pending (+ pending-fees pending-rf))
  )
    (try! (contract-call? .test-hq-vaults-v3 check-is-rewarder contract-caller))

    (asserts! (> total-pending u0) ERR_NO_PENDING_TRANSFERS)
    (asserts! (>= total-reserve total-pending) ERR_INSUFFICIENT_FUNDS)

    (if (> pending-fees u0) (try! (contract-call? .test-reserve-hbtc-v3 transfer sbtc-token pending-fees fee-collector)) true)
    (if (> pending-rf u0) (try! (contract-call? .test-reserve-hbtc-v3 transfer sbtc-token pending-rf rf)) true)

    (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list
        { type: "pending-fees", amount: pending-fees, is-add: false }
        { type: "pending-rf", amount: pending-rf, is-add: false }
        { type: "total-assets", amount: total-pending, is-add: false })
      none
      none))
    (print { action: "fund-transfers", user: contract-caller, data: { fees: pending-fees, rf: pending-rf, reserve: { old: total-reserve, new: (- total-reserve total-pending) } } })
    (ok true)
  )
)

;;-------------------------------------
;; Helper Functions
;;-------------------------------------

;; @desc - Handle profit scenario
;; @param - reward: original input reward amount from the trader
;; @param - is-positive: whether the reward is positive or negative
;; @param - total-rf: current reserve fund balance
;; @param - pending-rf: current pending-rf balance
;; @param - perf-fee: performance fee amount
;; @param - mgmt-fee: management fee amount
;; @param - reserve-rate: reserve fund allocation rate
;; @return - (response bool uint) success response after updating token price
(define-private (handle-profit 
  (reward uint) (is-positive bool)
  (total-rf uint) (pending-rf uint)
  (perf-fee uint) (mgmt-fee uint)
  (reserve-rate uint))
  (let (
    (reward-after-fees (- reward (+ perf-fee mgmt-fee)))
    (reward-rf (/ (* reward-after-fees reserve-rate) bps-base))
    (reward-net (- reward-after-fees reward-rf))
  )
    (print {
      action: "log-reward",
      case: (if (is-eq reward-after-fees u0) "zero" "profit"),
      user: contract-caller,
      data: { reward: { gross: reward, rf: reward-rf, net: reward-net, is-positive: true }, fees: { perf: perf-fee, mgmt: mgmt-fee }, rf: { old: total-rf, new: (+ total-rf reward-rf)  } }
    })
    ;; Single batch call with commit-reward logic
    (ok (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list
        { type: "pending-fees", amount: (+ perf-fee mgmt-fee), is-add: true }
        { type: "pending-rf", amount: reward-rf, is-add: true })
      (some { reward: reward-net, is-add: true })
      none)))
  )
)

;; @desc - Handle loss covered by reserve fund
;; @param - reward: original reward amount (in deposit-asset, 10**8)
;; @param - is-positive: whether the reward is positive or negative
;; @param - total-rf: current reserve fund balance
;; @param - pending-rf: current pending-rf balance
;; @param - req-rf: amount required from reserve fund
;; @param - perf-fee: performance fee amount
;; @param - mgmt-fee: management fee amount
;; @return - (response bool uint) success response after transferring reserve fund and updating token price
(define-private (handle-loss-covered 
  (reward uint) (is-positive bool)
  (total-rf uint) (pending-rf uint)
  (req-rf uint)
  (perf-fee uint) (mgmt-fee uint))
  (let (
    (transfer-amount (if (> req-rf pending-rf) (- req-rf pending-rf) u0))
    (rf-decrease (if (> transfer-amount u0) pending-rf req-rf))
  )
    (print {
      action: "log-reward",
      case: "loss-covered",
      user: contract-caller,
      data: { reward: { gross: reward, net: u0, rf: u0, is-positive: is-positive }, fees: { perf: u0, mgmt: mgmt-fee }, rf: { old: total-rf, new: (- total-rf req-rf) } }
    })
    
    ;; Physical transfer if needed
    (if (> transfer-amount u0)
      (try! (contract-call? .test-reserve-fund-hbtc-v3 transfer sbtc-token transfer-amount reserve none))
      true
    )
    
    ;; Single batch call with commit-reward logic (net reward = 0)
    (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list
        { type: "pending-rf", amount: rf-decrease, is-add: false }
        { type: "pending-fees", amount: mgmt-fee, is-add: true })
      (some { reward: u0, is-add: false })
      none))
    (ok true) 
  )
)

;; @desc - Handle trading loss scenario where losses exceed reserve fund capacity
;; @param - reward: original reward amount from the trader
;; @param - is-positive: whether the reward is positive or negative
;; @param - total-rf: current reserve fund balance
;; @param - pending-rf: current pending-rf balance
;; @param - req-rf: amount required from reserve fund
;; @param - perf-fee: performance fee amount
;; @param - mgmt-fee: management fee amount
;; @return - (response bool uint) success response after transferring reserve fund and updating token price
(define-private (handle-loss-exceeds 
  (reward uint) (is-positive bool)
  (total-rf uint) (pending-rf uint) (req-rf uint)
  (perf-fee uint) (mgmt-fee uint))
  (let (
    (loss (- req-rf total-rf))
  )
    (print {
      action: "log-reward",
      case: "loss-exceeds",
      user: contract-caller,
      data: { reward: { gross: reward, net: loss, rf: u0, is-positive: is-positive }, fees: { perf: u0, mgmt: mgmt-fee }, rf: { old: total-rf, new: u0 } }
    })
    (if (> total-rf pending-rf)
      (try! (contract-call? .test-reserve-fund-hbtc-v3 transfer sbtc-token (- total-rf pending-rf) reserve none))
      true
    )
    ;; Single batch call with commit-reward logic (loss decreases total-assets)
    (ok (try! (contract-call? .test-state-hbtc-v3 update-state 
      (list
        { type: "pending-fees", amount: mgmt-fee, is-add: true }
        { type: "pending-rf", amount: pending-rf, is-add: false })
      (some { reward: loss, is-add: false })
      none)))
  )
)

(define-private (get-sbtc-balance (contract principal))
  (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance contract))
)