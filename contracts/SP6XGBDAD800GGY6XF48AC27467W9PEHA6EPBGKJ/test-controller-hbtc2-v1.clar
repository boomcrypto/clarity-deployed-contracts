;; @contract Controller
;; @version 1

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_ZERO_ONLY_POSITIVE (err u105001))

(define-constant bps-base (pow u10 u4))
(define-constant hbtc-base (pow u10 u8))

;;-------------------------------------
;; Rewarder
;;-------------------------------------

;; @desc - log the reward and update the token price
;; @param amount - the amount of rewards for the interval (in deposit-asset, 10**8)
;; @param is-positive - whether the reward is positive or negative  
;; @note - if amount is zero, is-positive must be true
(define-public (log-reward (amount uint) (is-positive bool))
  (let (
    (token-price (contract-call? .test-state-hbtc-v1 get-token-price))
    (supply (unwrap-panic (contract-call? .test-token-hbtc get-total-supply)))
    (vault-balance (/ (* token-price supply) hbtc-base))
    (rf-balance (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance .test-reserve-fund-hbtc-v1)))
    (fees (contract-call? .test-state-hbtc-v1 get-fees))
    (fee-address (contract-call? .test-state-hbtc-v1 get-fee-address))
    (perf-fee (if is-positive (/ (* (get perf-fee fees) amount) bps-base) u0))
    (mgmt-fee (/ (* (get mgmt-fee fees) vault-balance) bps-base u100))
    (total-fees (+ perf-fee mgmt-fee))
    (is-profit (if (and is-positive (>= amount total-fees)) true false))
  )
    (try! (contract-call? .test-hq-vaults-v1 check-is-protocol-enabled))
    (try! (contract-call? .test-hq-vaults-v1 check-is-rewarder contract-caller))
    (try! (contract-call? .test-state-hbtc-v1 check-is-update-window-open))
    (try! (contract-call? .test-state-hbtc-v1 check-max-reward amount vault-balance))

    (asserts! (if (is-eq amount u0) (is-eq is-positive true) true) ERR_ZERO_ONLY_POSITIVE)

    (if is-profit
      ;; Handle profit and zero scenario -> token price increases
      (try! (handle-profit amount perf-fee mgmt-fee total-fees rf-balance token-price vault-balance fee-address))
      
      ;; Handle loss scenarios
      (let (
        (rf-required (if is-positive (- mgmt-fee amount) (+ amount mgmt-fee)))
      )
        (if (<= rf-required rf-balance)
          ;; Reserve-fund can cover the loss -> token price does not change
          (try! (handle-loss-covered amount mgmt-fee rf-balance token-price vault-balance fee-address))

          ;; Reserve-fund cannot cover the loss -> token price decreases
          (try! (handle-loss-exceeds amount mgmt-fee rf-required rf-balance token-price vault-balance fee-address))
        )
      )
    )
    (ok (try! (contract-call? .test-state-hbtc-v1 update-last-log-ts)))
  )
)

;;-------------------------------------
;; Helper Functions
;;-------------------------------------

;; @desc - Handle profit scenario
;; @param amount - original reward amount
;; @param perf-fee - performance fee
;; @param mgmt-fee - management fee
;; @param rf-balance - current reserve fund balance
;; @param total-fees - total fees
;; @param token-price - current token price
;; @param vault-balance - current vault balance
;; @param fee-address - fee recipient address
(define-private (handle-profit (amount uint) (perf-fee uint) (mgmt-fee uint) (total-fees uint) (rf-balance uint) (token-price uint) (vault-balance uint) (fee-address principal))
  (let (
    (net-amount (- amount total-fees))
    (rf-amount (/ (* net-amount (contract-call? .test-state-hbtc-v1 get-reserve-rate)) bps-base))
    (reward-amount (- net-amount rf-amount))
    (new-token-price (/ (* token-price (+ hbtc-base (/ (* reward-amount hbtc-base) vault-balance))) hbtc-base))
    (case (if (is-eq net-amount u0) "zero" "profit"))
    (new-rf-balance (+ rf-balance rf-amount))
    (return-percent-of-bps (/ (* reward-amount bps-base u100) vault-balance))
  )

    (print-event case contract-caller
      (build-print-data amount perf-fee mgmt-fee rf-amount reward-amount rf-balance new-rf-balance token-price new-token-price vault-balance return-percent-of-bps)
    )
    
    (try! (transfer-fees true perf-fee mgmt-fee fee-address))
    (if (> rf-amount u0)
      (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token rf-amount .test-reserve-fund-hbtc-v1))
      true)
    (ok (try! (contract-call? .test-state-hbtc-v1 set-token-price new-token-price)))
  )
)

;; @desc - Handle loss covered by reserve fund
;; @param amount - original reward amount (in deposit-asset, 10**8)
;; @param mgmt-fee - management fee
;; @param rf-balance - current reserve fund balance
;; @param token-price - current token price
;; @param vault-balance - current vault balance
;; @param fee-address - fee recipient address
(define-private (handle-loss-covered (amount uint) (mgmt-fee uint) (rf-balance uint) (token-price uint) (vault-balance uint) (fee-address principal))
  (let (
    (new-rf-balance (- rf-balance amount mgmt-fee))
    (return-percent-of-bps u0)
  )

    (print-event "loss-covered" contract-caller 
      (build-print-data amount u0 mgmt-fee u0 u0 rf-balance new-rf-balance token-price token-price vault-balance return-percent-of-bps)
    )
    
    (try! (transfer-fees false u0 mgmt-fee fee-address))
    (if (> amount u0)
      (try! (contract-call? .test-reserve-fund-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token amount .test-reserve-hbtc-v1 none))
      true)
    (ok true)
  )
)

;; @desc - Handle loss exceeding reserve fund
;; @param amount - original reward amount
;; @param mgmt-fee - management fee
;; @param rf-required - amount after fees
;; @param rf-balance - current reserve fund balance
;; @param token-price - current token price
;; @param vault-balance - current vault balance
;; @param fee-address - fee recipient address
(define-private (handle-loss-exceeds (amount uint) (mgmt-fee uint) (rf-required uint) (rf-balance uint) (token-price uint) (vault-balance uint) (fee-address principal))
  (let (
    (loss-amount (- rf-required rf-balance))
    (new-token-price (/ (* token-price (- hbtc-base (/ (* loss-amount hbtc-base) vault-balance))) hbtc-base))
    (return-percent-of-bps (/ (* loss-amount bps-base u100) vault-balance))
  )

    (print-event "loss-exceeds" contract-caller 
      (build-print-data amount u0 mgmt-fee u0 u0 rf-balance u0 token-price new-token-price vault-balance return-percent-of-bps)
    )

    (try! (transfer-fees true u0 mgmt-fee fee-address))
    (if (> rf-balance u0)
      (try! (contract-call? .test-reserve-fund-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token rf-balance .test-reserve-hbtc-v1 none))
      true)
    (ok (try! (contract-call? .test-state-hbtc-v1 set-token-price new-token-price)))
  )
)

;; @desc - Transfer fees to the fee address
;; @param perf-fee - performance fee amount
;; @param mgmt-fee - management fee amount
;; @param fee-address - address to receive fees
(define-private (transfer-fees (from-reserve bool) (perf-fee uint) (mgmt-fee uint) (fee-address principal))
  (begin
    (if from-reserve
      (begin
        (if (> perf-fee u0)
          (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token perf-fee fee-address))
          true)
        (if (> mgmt-fee u0)
          (try! (contract-call? .test-reserve-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token mgmt-fee fee-address))
          true)
      )
      (begin ;; from reserve-fund
        (if (> perf-fee u0)
          (try! (contract-call? .test-reserve-fund-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token perf-fee fee-address none))
          true)
        (if (> mgmt-fee u0)
          (try! (contract-call? .test-reserve-fund-hbtc-v1 transfer 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token mgmt-fee fee-address none))
          true)
      )
    )
    (ok true)
  )
)

;;-------------------------------------
;; Print Functions
;;-------------------------------------

;; @desc - Log reward event with unified data structure
;; @param case - the reward case (profit, zero-profit, negative-within-reserve, negative-exceeds-reserve)
;; @param data - unified log data structure
;; @param user - the caller principal
(define-private (print-event (case (string-ascii 24)) (user principal) (data { amount: uint, perf-fee: uint, mgmt-fee: uint, rf-amount: uint, reward-amount: uint, old-rf-balance: uint, new-rf-balance: uint, old-token-price: uint, new-token-price: uint, vault-balance: uint, return-percent-of-bps: uint }))
  (print { 
    action: "log-reward", 
    case: case, 
    user: user, 
    data: data,
  })
)

;; @desc - Build unified log data for all reward scenarios
(define-private (build-print-data (amount uint) (perf-fee uint) (mgmt-fee uint) (rf-amount uint) (reward-amount uint) (old-rf-balance uint) (new-rf-balance uint) (old-token-price uint) (new-token-price uint) (vault-balance uint) (return-percent-of-bps uint))
  {
    amount: amount,
    perf-fee: perf-fee,
    mgmt-fee: mgmt-fee,
    rf-amount: rf-amount,
    reward-amount: reward-amount,
    old-rf-balance: old-rf-balance,
    new-rf-balance: new-rf-balance,
    old-token-price: old-token-price,
    new-token-price: new-token-price,
    vault-balance: vault-balance,
    return-percent-of-bps: return-percent-of-bps
  }
)