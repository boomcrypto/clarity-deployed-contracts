;; @contract HQ
;; @version 1

;;-------------------------------------
;; Traits 
;;-------------------------------------

(use-trait pnl-calculator-trait .pnl-calculator-trait.pnl-calculator-trait)

;;-------------------------------------
;; Errors 
;;-------------------------------------

(define-constant ERR_NO_FEES_FOR_TYPE (err u1001))
(define-constant ERR_NOT_ADMIN (err u1002))
(define-constant ERR_NOT_TRADER (err u1003))
(define-constant ERR_NOT_UPDATER (err u1004))
(define-constant ERR_INACTIVE_PNL_CALCULATOR_CONTRACT (err u1005))
(define-constant ERR_STRATEGY_CANT_BE_CHANGED (err u1006))
(define-constant ERR_HIGHER_THAN_MAX (err u1007))
(define-constant ERR_VALUE_NOT_ALLOWED (err u1008))
(define-constant ERR_ONLY_CORE_CONTRACT_ALLOWED (err u1009)) 
(define-constant ERR_ALREADY_INITIALIZED (err u1010))

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant week-in-ms u604800000)
(define-constant minute-in-ms u60000)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var is-initialized bool false)

(define-data-var fee-address principal 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB)

(define-data-var flexible-strategy bool false)
(define-data-var option-type uint u0) ;; type of the option (u1 = vanilla, u2 = ERKO, u3 = ERKI, u4 = spread, u5 = binary)
(define-data-var strategy-type uint u0) ;; type of the strategy (u1 = call, u2 = put, u3 = callput, u4 = callstrip, u5 = putstrip)
(define-data-var min-epoch-duration uint week-in-ms)
(define-data-var max-epoch-duration uint (* u8 week-in-ms))

(define-data-var epoch-risk uint u100) ;; bps of total-underlying in vault that can be deployed into trades every epoch
(define-data-var max-epoch-risk uint u100) ;; max bps of total-underlying in vault that can be deployed into trades every epoch
(define-data-var next-epoch-risk uint u100)

(define-data-var unit-size uint u1000000) ;; unit size of one option; i.e, one unit represents 1,000,000 uSTX / 1 STX
(define-data-var next-unit-size uint u1000000)

(define-data-var no-profit-management-fee bool false)

(define-data-var pnl-data-window uint (* u1 minute-in-ms)) ;; 1 min (in ms)
(define-data-var registration-window uint u72) ;; 72 blocks = ~12 hours (in burn-blocks)
(define-data-var confirmation-window uint u12) ;; 12 blocks = ~2 hours (in burn-blocks)
(define-data-var payment-window uint u144) ;; 144 blocks = ~24 hours (in burn-blocks)

(define-data-var pnl-calculation-window uint (* (* u62 u60) minute-in-ms)) ;; 62 hours (in ms)
(define-data-var max-pnl-calculation-window uint (* (* u62 u60) minute-in-ms))

(define-data-var vault-capacity uint u1000000000) ;; underlying
(define-data-var min-deposit-amount uint u0) ;; underlying

(define-data-var deposits-allowed bool true) ;; on/off switch for deposits
(define-data-var trading-allowed bool true) ;; on/off switch for option trading

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map admins
  { 
    address: principal 
  }
  {
    active: bool,
  }
)

(define-map traders
  { 
    address: principal 
  }
  {
    active: bool,
  }
)

(define-map updaters
  {
    address: principal 
  }
  {
    active: bool,
  }
)

(define-map pnl-calculator-contracts
  { 
    address: principal 
  }
  {
    active: bool,
  }
)

(define-map fees
  { 
    type: (string-ascii 32)
  }
  {
    current: uint, 
    next: uint, 
    max: uint 
  }
)

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-admin (address principal))
  (get active 
    (default-to 
      { active: false }
      (map-get? admins { address: address }))))

(define-read-only (get-trader (address principal))
  (get active 
    (default-to 
      { active: false }
      (map-get? traders { address: address }))))

(define-read-only (get-updater (address principal))
  (get active 
    (default-to 
      { active: false }
      (map-get? updaters { address: address }))))

(define-read-only (get-pnl-calculator-contract-active (address principal))
  (get active 
    (default-to 
      { active: false }
      (map-get? pnl-calculator-contracts { address: address }))))

(define-read-only (get-fees (type (string-ascii 32)))
  (ok (unwrap! (map-get? fees { type: type }) ERR_NO_FEES_FOR_TYPE))) 

(define-read-only (get-fee-address)
  (var-get fee-address))	

(define-read-only (get-flexible-strategy) 
  (var-get flexible-strategy))

(define-read-only (get-option-type) 
  (var-get option-type))

(define-read-only (get-strategy-type) 
  (var-get strategy-type))

(define-read-only (get-min-epoch-duration) 
  (var-get min-epoch-duration))

(define-read-only (get-max-epoch-duration) 
  (var-get max-epoch-duration))

(define-read-only (get-epoch-risk) 
  (var-get epoch-risk))

(define-read-only (get-next-epoch-risk) 
  (var-get next-epoch-risk))

(define-read-only (get-unit-size) 
  (var-get unit-size))

(define-read-only (get-next-unit-size) 
  (var-get next-unit-size))

(define-read-only (get-no-profit-management-fee) 
  (var-get no-profit-management-fee))

(define-read-only (get-pnl-data-window) 
  (var-get pnl-data-window))

(define-read-only (get-registration-window) 
  (var-get registration-window))

(define-read-only (get-confirmation-window) 
  (var-get confirmation-window))

(define-read-only (get-payment-window) 
  (var-get payment-window))

(define-read-only (get-pnl-calculation-window) 
  (var-get pnl-calculation-window))

(define-read-only (get-vault-capacity) 
  (var-get vault-capacity))

(define-read-only (get-min-deposit-amount) 
  (var-get min-deposit-amount))

(define-read-only (get-deposits-allowed)
  (var-get deposits-allowed))

(define-read-only (get-trading-allowed)
  (var-get trading-allowed))

(define-read-only (get-deposit-data) 
  {
    deposits-allowed: (get-deposits-allowed),
    vault-capacity: (get-vault-capacity),
    min-deposit-amount: (get-min-deposit-amount)
  })

;;-------------------------------------
;; Checks 
;;-------------------------------------

(define-read-only (check-is-admin (address principal))
  (begin
    (asserts! (get-admin address) ERR_NOT_ADMIN)
    (ok true)))

(define-read-only (check-is-trader (address principal))
  (begin
    (asserts! (get-trader address) ERR_NOT_TRADER)
    (ok true)))

(define-read-only (check-is-updater (address principal))
  (begin
    (asserts! (get-updater address) ERR_NOT_UPDATER)
    (ok true)))

(define-read-only (check-is-pnl-calculator-active (address principal))
  (begin
    (asserts! (get-pnl-calculator-contract-active address) ERR_INACTIVE_PNL_CALCULATOR_CONTRACT)
    (ok true)))

;;-------------------------------------
;; Set 
;;-------------------------------------

(define-public (set-admin (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set admins { address: address } { active: active }))))

(define-public (set-trader (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set traders { address: address } { active: active }))))

(define-public (set-updater (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set updaters { address: address } { active: active }))))

(define-public (set-pnl-calculator-contract-active (address principal) (active bool))
  (begin
    (try! (check-is-admin tx-sender))
    (ok (map-set pnl-calculator-contracts { address: address } { active: active }))))

(define-public (set-option-and-strategy-type (new-option-type uint) (new-strategy-type uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (asserts! (get-flexible-strategy) ERR_STRATEGY_CANT_BE_CHANGED)
    (var-set option-type new-option-type)
    (ok (var-set strategy-type new-strategy-type))))

(define-public (set-next-fee (type (string-ascii 32)) (value uint))
  (let (
    (current-fees (try! (get-fees type))))
    (try! (check-is-admin tx-sender))
    (asserts! (<= value (get max current-fees)) ERR_HIGHER_THAN_MAX)
    (ok (map-set fees { type: type } (merge current-fees { next: value })))))

(define-public (set-fee-address (address principal)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set fee-address address))))

(define-public (set-next-epoch-risk (risk uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (asserts! (<= risk (var-get max-epoch-risk)) ERR_HIGHER_THAN_MAX)
    (ok (var-set next-epoch-risk risk))))

(define-public (set-next-unit-size (new-unit-size uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (asserts! (> new-unit-size u0) ERR_VALUE_NOT_ALLOWED)
    (ok (var-set next-unit-size new-unit-size))))

(define-public (set-no-profit-management-fee (new-no-profit-management-fee bool)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set no-profit-management-fee new-no-profit-management-fee))))

(define-public (set-pnl-data-window (new-pnl-data-window uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set pnl-data-window new-pnl-data-window))))

(define-public (set-registration-window (new-registration-window uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set registration-window new-registration-window))))

(define-public (set-confirmation-window (new-confirmation-window uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set confirmation-window new-confirmation-window))))

(define-public (set-payment-window (new-payment-window uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set payment-window new-payment-window))))

(define-public (set-pnl-calculation-window (new-pnl-calculation-window uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (asserts! (<= new-pnl-calculation-window (var-get max-pnl-calculation-window)) ERR_HIGHER_THAN_MAX)
    (ok (var-set pnl-calculation-window new-pnl-calculation-window))))

(define-public (set-vault-capacity (new-vault-capacity uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set vault-capacity new-vault-capacity))))

(define-public (set-min-deposit-amount (new-min-deposit-amount uint)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set min-deposit-amount new-min-deposit-amount))))

(define-public (set-deposits-allowed (status bool)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set deposits-allowed status))))

(define-public (set-trading-allowed (status bool)) 
  (begin
    (try! (check-is-admin tx-sender))
    (ok (var-set trading-allowed status))))

;;-------------------------------------
;; Updates 
;;-------------------------------------

(define-public (update-fees-and-settings)
  (let (
    (management-fees (try! (get-fees "management")))
    (performance-fees (try! (get-fees "performance")))
    (withdrawal-fees (try! (get-fees "withdrawal"))))
    (asserts! (is-eq tx-sender .ht-core-ststx-earn-v3) ERR_ONLY_CORE_CONTRACT_ALLOWED)
    (map-set fees { type: "management" } (merge management-fees { current: (get next management-fees) }))
    (map-set fees { type: "performance" } (merge performance-fees { current: (get next performance-fees) }))
    (map-set fees { type: "withdrawal" } (merge withdrawal-fees { current: (get next withdrawal-fees) }))
    (var-set epoch-risk (var-get next-epoch-risk))
    (ok (var-set unit-size (var-get next-unit-size)))))

;;-------------------------------------
;; Initialize 
;;-------------------------------------

(map-set admins { address: tx-sender} { active: true })
(map-set traders { address: tx-sender} { active: true })
(map-set updaters { address: tx-sender} { active: true })

(define-public (initialize
  (flexible-strategy-set bool)
  (option-type-set uint)
  (strategy-type-set uint)
  (min-epoch-duration-set uint)
  (max-epoch-duration-set uint)
  (max-epoch-risk-set uint)
  (max-pnl-calculation-window-set uint)
  (max-management-fee uint)
  (first-management-fee uint)
  (max-performance-fee uint)
  (first-performance-fee uint)
  (max-withdrawal-fee uint)
  (first-withdrawal-fee uint)
  (pnl-calculator-contract <pnl-calculator-trait>))
  (begin
    (try! (check-is-admin tx-sender))
    (asserts! (not (var-get is-initialized)) ERR_ALREADY_INITIALIZED)
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (var-set flexible-strategy flexible-strategy-set)
    (var-set option-type option-type-set)
    (var-set strategy-type strategy-type-set)
    (var-set min-epoch-duration min-epoch-duration-set)
    (var-set max-epoch-duration max-epoch-duration-set)
    (var-set max-epoch-risk max-epoch-risk-set)
    (var-set max-pnl-calculation-window max-pnl-calculation-window-set)
    (map-set fees { type: "management" } { current: first-management-fee, next: first-management-fee, max: max-management-fee }) ;; in % of bps
    (map-set fees { type: "performance" } { current: first-performance-fee, next: first-performance-fee, max: max-performance-fee }) ;; in bps
    (map-set fees { type: "withdrawal" } { current: first-withdrawal-fee, next: first-withdrawal-fee, max: max-withdrawal-fee }) ;; in bps
    (map-set pnl-calculator-contracts { address: (contract-of pnl-calculator-contract) } { active: true })
    (ok true)))