;; @contract Core
;; @version 1

;;-------------------------------------
;; Traits 
;;-------------------------------------

(use-trait pnl-calculator-trait .pnl-calculator-trait.pnl-calculator-trait)
(use-trait pyth-storage-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.storage-trait)
(use-trait pyth-decoder-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-traits-v1.decoder-trait)
(use-trait wormhole-core-trait 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.wormhole-traits-v1.core-trait)

;;-------------------------------------
;; Errors 
;;-------------------------------------

(define-constant ERR_NO_ENTRY_FOR_ID (err u2001))
(define-constant ERR_NO_ENTRY_FOR_COUNTERPARTY (err u2002))
(define-constant ERR_SETTLEMENT_RATE_NONE (err u2003))
(define-constant ERR_PNL_USD_SET_NONE (err u2004))
(define-constant ERR_NOT_OPTION_ASSET (err u2005))
(define-constant ERR_EPOCH_NOT_EXPIRED (err u2006))
(define-constant ERR_SETTLEMENT_WINDOW_CLOSED (err u2007))
(define-constant ERR_PAYMENT_OUTSTANDING (err u2008))
(define-constant ERR_EPOCH_ALREADY_SETTLED (err u2009))
(define-constant ERR_TRADING_NOT_ALLOWED (err u2010))
(define-constant ERR_EXPIRY_BEFORE_CURRENT_EXPIRY (err u2011))
(define-constant ERR_EPOCH_ALREADY_STARTED_FUNDS_REGISTERED (err u2012))
(define-constant ERR_EPOCH_ALREADY_STARTED_UNITS_TRANSACTED (err u2013))
(define-constant ERR_CURRENT_EPOCH_NOT_SETTLED (err u2014))
(define-constant ERR_VIOLATES_MIN_EPOCH_DURATION (err u2015))
(define-constant ERR_VIOLATES_MAX_EPOCH_DURATION (err u2016))
(define-constant ERR_EPOCH_ZERO_TRADING_ATTEMPT (err u2017))
(define-constant ERR_NOT_STANDARD (err u2018))
(define-constant ERR_NOT_ENOUGH_FUNDS_AVAILABLE (err u2019))
(define-constant ERR_CURRENT_EPOCH_SETTLED (err u2020))
(define-constant ERR_REGISTRATION_WINDOW_CLOSED (err u2021))
(define-constant ERR_NO_REGISTRATION_FOR_COUNTERPARTY (err u2022))
(define-constant ERR_AMOUNT_MISMATCH (err u2023))
(define-constant ERR_PRICE_MISMATCH (err u2024))
(define-constant ERR_CONFIRMATION_WINDOW_CLOSED (err u2025))
(define-constant ERR_PNL_UNDETERMINED (err u2026))
(define-constant ERR_PAYMENT_WINDOW_CLOSED (err u2027))
(define-constant ERR_PAYMENT_AMOUNTS_DONT_MATCH (err u2028))
(define-constant ERR_ALREADY_INITIALIZED (err u2029))
(define-constant ERR_PAYMENT_WINDOW_STILL_OPEN (err u2030))
(define-constant ERR_PNL_ALREADY_DETERMINED (err u2031))
(define-constant ERR_PNL_CALCULATION_WINDOW_STILL_OPEN (err u2032))

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant option-asset-symbol 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17) ;; "STX" price feed id
(define-constant underlying-base (pow u10 u6))
(define-constant bps-base u10000) ;; 1 bps = 0.01%
(define-constant minute-in-ms u60000)

;;-------------------------------------
;; Variables 
;;-------------------------------------

(define-data-var is-initialized bool false)

(define-data-var current-epoch-id uint u0)

(define-data-var trading-funds-available uint u0)
(define-data-var trading-funds-registered uint u0)
(define-data-var total-funds-requested uint u0)

(define-data-var counterparty-addresses (list 5000 principal) (list))
(define-data-var delinquent-counterparty-addresses (list 5000 principal) (list))
(define-data-var delinquent-epoch bool false)

(define-data-var helper-principal principal tx-sender)

;;-------------------------------------
;; Maps 
;;-------------------------------------

(define-map epoch-info
  { 
    epoch-id: uint
  }
  { 
    epoch-expiry: uint, ;; unix timestamp in ms
    strike-call: (optional uint), ;; usd-per-option-asset
    strike-put: (optional uint), ;; usd-per-option-asset
    barrier-up: (optional uint), ;; usd-per-option-asset
    barrier-down: (optional uint), ;; usd-per-option-asset
    unit-pnl: (optional uint), ;; in underlying
    settlement-rate: (optional uint), ;; usd-per-option-asset
    block-height-start: uint,
    block-height-pnl: (optional uint),
    block-height-settled: (optional uint),
    total-units-transacted: uint,
    total-premium: uint, ;; in underlying
    total-underlying-active: uint,
    underlying-per-token-settled: (optional uint),
    epoch-risk: uint, ;; in bps
    unit-size: uint
  }
)

(define-map counterparty-info
  {
    address: principal
  }
  { 
    units-registered: uint,
    price-registered: (optional uint),
    block-height-registered: (optional uint),
    units-transacted: uint,
    funds-requested: (optional uint),
  }
)

(define-map delinquent-counterparty-info 
  {
    address: principal
  }
  { 		
    funds-requested: uint,
    units-transacted: uint,
    epoch-id: uint,
  }
)

;;-------------------------------------
;; Getters 
;;-------------------------------------

(define-read-only (get-current-epoch-id) 
  (var-get current-epoch-id))

(define-read-only (get-trading-funds-available) 
  (var-get trading-funds-available))

(define-read-only (get-trading-funds-registered) 
  (var-get trading-funds-registered))

(define-read-only (get-total-funds-requested) 
  (var-get total-funds-requested))

(define-read-only (get-epoch-info (epoch-id uint)) 
  (ok (unwrap! (map-get? epoch-info { epoch-id: epoch-id }) ERR_NO_ENTRY_FOR_ID)))

(define-read-only (get-current-epoch-info) 
  (map-get? epoch-info { epoch-id: (get-current-epoch-id) }))

(define-read-only (get-counterparty-info (counterparty principal)) 
  (ok (unwrap! (map-get? counterparty-info { address: counterparty }) ERR_NO_ENTRY_FOR_COUNTERPARTY)))

(define-read-only (get-counterparty-addresses) 
  (var-get counterparty-addresses))

(define-read-only (get-delinquent-counterparty-info (counterparty principal)) 
  (ok (unwrap! (map-get? delinquent-counterparty-info { address: counterparty }) ERR_NO_ENTRY_FOR_COUNTERPARTY)))

(define-read-only (get-delinquent-counterparty-addresses) 
  (var-get delinquent-counterparty-addresses))

;;-------------------------------------
;; Settlement
;;-------------------------------------

(define-private (settle) 
  (begin 
    (try! (charge-fees))
    (try! (settle-epoch-info))
    (try! (activate-pending-claims))
    (try! (as-contract (contract-call? .ht-hq-ststx-earn-v4 update-fees-and-settings)))
    (unwrap-panic (reset-data))
    (ok true)))

(define-private (charge-fees)
  (let (
    (current-performance-fee (get current (try! (contract-call? .ht-hq-ststx-earn-v4 get-fees "performance"))))
    (current-management-fee (get current (try! (contract-call? .ht-hq-ststx-earn-v4 get-fees "management"))))
    (fee-address (contract-call? .ht-hq-ststx-earn-v4 get-fee-address))
    (no-profit-management-fee (contract-call? .ht-hq-ststx-earn-v4 get-no-profit-management-fee))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (unit-pnl (unwrap-panic (get unit-pnl current-epoch-info)))
    (total-premium (get total-premium current-epoch-info))
    (units-transacted (get total-units-transacted current-epoch-info))
    (total-underlying (get total-underlying-active current-epoch-info))
    (strike-call (get strike-call current-epoch-info))
    (strike-put (get strike-put current-epoch-info))
    (strike-set (or (is-some strike-call) (is-some strike-put))))
    (if (and strike-set (not (var-get delinquent-epoch)))
      (if (> (* unit-pnl units-transacted) total-premium)
        (begin
          (try! 
            (as-contract (contract-call? .ht-vault-ststx-earn-v4 payout-funds
            (/ (* (- (* unit-pnl units-transacted) total-premium) current-performance-fee) bps-base) fee-address))
          )
          (try!
            (as-contract (contract-call? .ht-vault-ststx-earn-v4 payout-funds 
            (/ (/ (* total-underlying current-management-fee) bps-base) u100) fee-address))
          )
        )
        (if no-profit-management-fee
          (try!
            (as-contract (contract-call? .ht-vault-ststx-earn-v4 payout-funds 
            (/ (/ (* total-underlying current-management-fee) bps-base) u100) fee-address))
          )
          true
        )
      )
      true
    )
    (ok true)))

(define-private (settle-epoch-info)
  (let (
    (underlying-per-token (contract-call? .ht-vault-ststx-earn-v4 get-underlying-per-token))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))) 
    (map-set epoch-info { epoch-id: (get-current-epoch-id) } 
      (merge
        current-epoch-info
        { 
          block-height-settled: (some burn-block-height),
          underlying-per-token-settled: (some underlying-per-token)
        }
      )
    )
    (as-contract (contract-call? .ht-vault-ststx-earn-v4 update-epoch-info-for-claims))))

(define-private (activate-pending-claims) 
  (begin
    (try! (as-contract (contract-call? .ht-vault-ststx-earn-v4 activate-pending-deposit-claims)))
    (try! (as-contract (contract-call? .ht-vault-ststx-earn-v4 activate-pending-withdrawal-claims)))
    (ok true)))

(define-private (init-trading-funds-available)
  (begin
    (var-set trading-funds-available 
    (/ 
      (* 
        (contract-call? .ht-vault-ststx-earn-v4 get-total-underlying-active)
        (contract-call? .ht-hq-ststx-earn-v4 get-epoch-risk)) 
      bps-base))
    (ok true)))

(define-private (reset-data) 
  (begin
    (map delete-counterparty (var-get counterparty-addresses))
    (var-set counterparty-addresses (list))
    (var-set total-funds-requested u0)
    (var-set trading-funds-registered u0)
    (ok (var-set delinquent-epoch false))))

(define-private (payment-requester 
  (counterparty-address principal))
  (let (
    (counterparty-info-entry (unwrap-panic (get-counterparty-info counterparty-address)))
    (current-epoch-info (unwrap-panic (get-current-epoch-info))) 
    (units-transacted (get units-transacted counterparty-info-entry))
    (unit-pnl (unwrap-panic (get unit-pnl current-epoch-info)))
    (funds-requested (* units-transacted unit-pnl)))
    (map-set counterparty-info { address: counterparty-address }
      (merge counterparty-info-entry              
        {
          funds-requested: (some funds-requested)
        }
      )
    )
    (ok (var-set total-funds-requested (+ (var-get total-funds-requested) funds-requested)))))

(define-public (determine-pnl
  (pnl-calculator-contract <pnl-calculator-trait>)
  (use-pnl-calculator bool)
  (pnl-usd-set (optional uint))  (use-oracle-price bool)
  (settlement-rate (optional uint))
  (option-asset-per-underlying (optional uint))
  (price-feed-bytes (buff 8192))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (decoded-prices (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2 decode-price-feeds price-feed-bytes execution-plan)))
    (decoded-price (element-at decoded-prices u0))
    (timestamp (* (unwrap-panic (get publish-time decoded-price)) u1000))
    (usd-per-option-asset (if use-oracle-price (to-uint (unwrap-panic (get ema-price decoded-price))) (unwrap! settlement-rate ERR_SETTLEMENT_RATE_NONE)))
    (price-id (unwrap-panic (get price-identifier decoded-price)))
    (epoch-id (get-current-epoch-id))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (current-epoch-expiry (get epoch-expiry current-epoch-info))
    (strike-call (get strike-call current-epoch-info))
    (strike-put (get strike-put current-epoch-info))
    (barrier-up (get barrier-up current-epoch-info))
    (barrier-down (get barrier-down current-epoch-info))
    (option-type (contract-call? .ht-hq-ststx-earn-v4 get-option-type))
    (strategy-type (contract-call? .ht-hq-ststx-earn-v4 get-strategy-type))
    (unit-size (contract-call? .ht-hq-ststx-earn-v4 get-unit-size))
    (pnl-usd (if use-pnl-calculator 
      (try! (contract-call? pnl-calculator-contract calculate-pnl usd-per-option-asset option-type strategy-type strike-call strike-put barrier-up barrier-down))
      (unwrap! pnl-usd-set ERR_PNL_USD_SET_NONE)
    ))
    (pnl-option-asset (usd-to-option-asset pnl-usd usd-per-option-asset))
    (unit-pnl (/ (* (/ (* pnl-option-asset unit-size) underlying-base) underlying-base) 
      (match option-asset-per-underlying value value underlying-base)))
    (total-units-transacted (get total-units-transacted current-epoch-info))
    (total-premium (get total-premium current-epoch-info)))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-updater tx-sender))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-pnl-calculator-active (contract-of pnl-calculator-contract)))
    (asserts! (is-eq price-id option-asset-symbol) ERR_NOT_OPTION_ASSET)
    (asserts! (>= timestamp current-epoch-expiry) ERR_EPOCH_NOT_EXPIRED)
    (asserts! (<= timestamp (+ current-epoch-expiry (contract-call? .ht-hq-ststx-earn-v4 get-pnl-data-window))) ERR_SETTLEMENT_WINDOW_CLOSED)
    (asserts! (is-eq (var-get total-funds-requested) u0) ERR_PAYMENT_OUTSTANDING)
    (asserts! (is-none (get block-height-settled current-epoch-info)) ERR_EPOCH_ALREADY_SETTLED)
    (map-set epoch-info { epoch-id: epoch-id } 
      (merge
        current-epoch-info
        { 
          unit-pnl: (some unit-pnl),
          settlement-rate: (some usd-per-option-asset),
          block-height-pnl: (some burn-block-height)
        }
      )
    )
    (print {
      epoch-id: epoch-id, 
      expiry: current-epoch-expiry,
      settlement-rate: usd-per-option-asset,
      option-pnl: pnl-option-asset,
      unit-pnl: unit-pnl,
      return-pre-fees: (- (to-int (* unit-pnl total-units-transacted)) (to-int total-premium))
    })
    (if (or (is-eq pnl-usd u0) (is-eq total-units-transacted u0))
      (try! (settle))
      (begin
        (map payment-requester (var-get counterparty-addresses))
        true
      )
    )
    (ok true)))

;;-------------------------------------
;; Trading 
;;-------------------------------------

(define-public (start-new-epoch
  (pnl-calculator-contract <pnl-calculator-trait>)
  (expiry uint)
  (strike-call (optional uint))
  (strike-put (optional uint))
  (barrier-up (optional uint))
  (barrier-down (optional uint)))
  (let (
    (new-epoch-id (+ (get-current-epoch-id) u1))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (current-epoch-expiry (get epoch-expiry current-epoch-info))
    (option-type (contract-call? .ht-hq-ststx-earn-v4 get-option-type))
    (strategy-type (contract-call? .ht-hq-ststx-earn-v4 get-strategy-type))
    (current-epoch-settled (is-some (get block-height-settled current-epoch-info))))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-trader tx-sender))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-pnl-calculator-active (contract-of pnl-calculator-contract)))
    (asserts! (contract-call? .ht-hq-ststx-earn-v4 get-trading-allowed) ERR_TRADING_NOT_ALLOWED)
    (try! (contract-call? pnl-calculator-contract check-strike-order option-type strategy-type strike-call strike-put barrier-up barrier-down))
    (asserts! (>= expiry current-epoch-expiry) ERR_EXPIRY_BEFORE_CURRENT_EXPIRY)
    (asserts! (is-eq u0 (var-get trading-funds-registered)) ERR_EPOCH_ALREADY_STARTED_FUNDS_REGISTERED)
    (try! (activate-pending-claims))
    (unwrap-panic (init-trading-funds-available))
    (if (and (is-eq current-epoch-expiry expiry) (not current-epoch-settled))
      (begin
        (asserts! (is-eq u0 (get total-units-transacted current-epoch-info)) ERR_EPOCH_ALREADY_STARTED_UNITS_TRANSACTED)
        (map-set epoch-info { epoch-id: (get-current-epoch-id) } 
          (merge
            current-epoch-info
            { 
              epoch-expiry: expiry,
              strike-call: strike-call,
              strike-put: strike-put,
              barrier-up: barrier-up,
              barrier-down: barrier-down,
            }
          )
        )
      )
      (begin 
        (asserts! current-epoch-settled ERR_CURRENT_EPOCH_NOT_SETTLED) 
        (asserts! (>= expiry (+ current-epoch-expiry (contract-call? .ht-hq-ststx-earn-v4 get-min-epoch-duration))) ERR_VIOLATES_MIN_EPOCH_DURATION)
        (asserts! (<= expiry (+ current-epoch-expiry (contract-call? .ht-hq-ststx-earn-v4 get-max-epoch-duration))) ERR_VIOLATES_MAX_EPOCH_DURATION)
        (map-set epoch-info { epoch-id: new-epoch-id } 
          {
            epoch-expiry: expiry,
            strike-call: strike-call,
            strike-put: strike-put,
            barrier-up: barrier-up,
            barrier-down: barrier-down,
            unit-pnl: none,
            settlement-rate: none,
            block-height-start: burn-block-height,
            block-height-pnl: none,
            block-height-settled: none,
            total-units-transacted: u0,
            total-premium: u0,
            total-underlying-active: (contract-call? .ht-vault-ststx-earn-v4 get-total-underlying-active), 
            underlying-per-token-settled: none,
            epoch-risk: (contract-call? .ht-hq-ststx-earn-v4 get-epoch-risk),
            unit-size: (contract-call? .ht-hq-ststx-earn-v4 get-next-unit-size)
          }
        )
        (try! (as-contract (contract-call? .ht-vault-ststx-earn-v4 create-epoch-info-for-claims)))
        (var-set current-epoch-id new-epoch-id)
      )
    )
    (ok true)))

(define-public (register-trade
  (amount uint)
  (option-price-per-underlying uint)
  (counterparty-address principal))
  (let (
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (funds-outgoing (* amount (/ (* option-price-per-underlying (contract-call? .ht-hq-ststx-earn-v4 get-unit-size)) underlying-base))))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-trader tx-sender))
    (asserts! (> (var-get current-epoch-id) u0) ERR_EPOCH_ZERO_TRADING_ATTEMPT)
    (asserts! (is-standard counterparty-address) ERR_NOT_STANDARD)
    (asserts! (contract-call? .ht-hq-ststx-earn-v4 get-trading-allowed) ERR_TRADING_NOT_ALLOWED)
    (asserts! (>= (var-get trading-funds-available) funds-outgoing) ERR_NOT_ENOUGH_FUNDS_AVAILABLE)
    (asserts! (is-none (get block-height-settled current-epoch-info)) ERR_CURRENT_EPOCH_SETTLED)
    (asserts! (<= burn-block-height (+
      (get block-height-start current-epoch-info)
      (contract-call? .ht-hq-ststx-earn-v4 get-registration-window))) 
      ERR_REGISTRATION_WINDOW_CLOSED)
    (match (map-get? counterparty-info { address: counterparty-address })
      counterparty-data
        (map-set counterparty-info { address: counterparty-address }
          (merge
            counterparty-data
            {
              units-registered: amount,
              price-registered: (some option-price-per-underlying),
              block-height-registered: (some burn-block-height),
            }
          )
        )
        (map-set counterparty-info { address: counterparty-address }
          {                         
            units-registered: amount,
            price-registered: (some option-price-per-underlying),
            block-height-registered: (some burn-block-height),
            units-transacted: u0,
            funds-requested: none,
          }
        )
      )
    (var-set trading-funds-available (- (var-get trading-funds-available) funds-outgoing))
    (ok (var-set trading-funds-registered (+ (var-get trading-funds-registered) funds-outgoing)))))

(define-public (update-registration
  (new-amount uint)
  (new-option-price-per-underlying uint)
  (counterparty-address principal))
  (let (
    (counterparty-info-entry (try! (get-counterparty-info counterparty-address)))
    (current-units-registered (get units-registered counterparty-info-entry))
    (current-price-registered (unwrap! (get price-registered counterparty-info-entry) ERR_NO_REGISTRATION_FOR_COUNTERPARTY))
    (unit-size (contract-call? .ht-hq-ststx-earn-v4 get-unit-size))
    (current-funds-outgoing (* current-units-registered (/ (* current-price-registered unit-size) underlying-base)))
    (units-transacted (get units-transacted counterparty-info-entry))
    (new-funds-outgoing (* new-amount (/ (* new-option-price-per-underlying unit-size) underlying-base))))
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-trader tx-sender))
    (if (> new-funds-outgoing current-funds-outgoing)
      (asserts! (>= (var-get trading-funds-available) (- new-funds-outgoing current-funds-outgoing)) ERR_NOT_ENOUGH_FUNDS_AVAILABLE)
      true
    )
    (if (is-eq new-amount u0)
      (if (is-eq units-transacted u0) 
        (map-delete counterparty-info { address: counterparty-address })
        (map-set counterparty-info	{ address: counterparty-address }
          (merge
            counterparty-info-entry
            { 
              units-registered: new-amount,
              price-registered: none,
              block-height-registered: none,
            }
          )
        )
      )
      (map-set counterparty-info { address: counterparty-address }
        (merge
          counterparty-info-entry
          {               
            units-registered: new-amount,
            price-registered: (some new-option-price-per-underlying),
            block-height-registered: (some burn-block-height),
          }
        )
      )
    )
    (var-set trading-funds-registered (+ (- (var-get trading-funds-registered) current-funds-outgoing) new-funds-outgoing))
    (ok (var-set trading-funds-available (- (+ (var-get trading-funds-available) current-funds-outgoing) new-funds-outgoing)))))

(define-public (confirm-trade
  (amount uint)
  (option-price-per-underlying uint))
  (let (
    (counterparty tx-sender)
    (counterparty-info-entry (try! (get-counterparty-info tx-sender)))
    (price-registered (unwrap! (get price-registered counterparty-info-entry) ERR_NO_REGISTRATION_FOR_COUNTERPARTY))
    (block-height-registered (unwrap-panic (get block-height-registered counterparty-info-entry)))
    (funds-outgoing (/ (* (* option-price-per-underlying amount) (contract-call? .ht-hq-ststx-earn-v4 get-unit-size)) underlying-base))
    (current-epoch-info (unwrap-panic (get-current-epoch-info))))
    (asserts! (is-eq amount (get units-registered counterparty-info-entry)) ERR_AMOUNT_MISMATCH)
    (asserts! (is-eq option-price-per-underlying price-registered) ERR_PRICE_MISMATCH)
    (asserts! (<= burn-block-height (+ block-height-registered (contract-call? .ht-hq-ststx-earn-v4 get-confirmation-window))) ERR_CONFIRMATION_WINDOW_CLOSED)
    (try! (as-contract (contract-call? .ht-vault-ststx-earn-v4 payout-funds funds-outgoing counterparty)))
    (map-set counterparty-info { address: tx-sender }
      { 
        units-registered: u0,
        price-registered: none,
        block-height-registered: none,
        units-transacted: (+ amount (get units-transacted counterparty-info-entry)),
        funds-requested: none,
      }
    )
    (var-set trading-funds-registered (- (var-get trading-funds-registered) funds-outgoing))
    (if (is-none (index-of? (var-get counterparty-addresses) tx-sender))
      (var-set counterparty-addresses (unwrap-panic (as-max-len? (append (var-get counterparty-addresses) tx-sender) u5000)))
      true
    )
    (map-set epoch-info { epoch-id: (get-current-epoch-id) } 
      (merge
        current-epoch-info
        { 
          total-units-transacted: (+ (get total-units-transacted current-epoch-info) amount),
          total-premium: (+ (get total-premium current-epoch-info) funds-outgoing)
        }
      )
    )
    (ok true)))

(define-public (make-payment
  (amount uint))
  (let (
    (funds-requested (unwrap! (get funds-requested (try! (get-counterparty-info tx-sender))) ERR_PNL_UNDETERMINED))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (block-height-pnl (unwrap-panic (get block-height-pnl current-epoch-info)))
    (payment-window (contract-call? .ht-hq-ststx-earn-v4 get-payment-window)))
    (asserts! (<= burn-block-height (+ block-height-pnl payment-window)) ERR_PAYMENT_WINDOW_CLOSED)
    (asserts! (is-eq amount funds-requested) ERR_PAYMENT_AMOUNTS_DONT_MATCH)
    (try! (contract-call? .ht-vault-ststx-earn-v4 deposit-funds amount tx-sender))
    (map-delete counterparty-info { address: tx-sender })
    (var-set helper-principal tx-sender)
    (var-set counterparty-addresses (filter remove-principal (var-get counterparty-addresses)))
    (var-set total-funds-requested (- (var-get total-funds-requested) amount))
    (if (is-eq (var-get total-funds-requested) u0)
      (try! (settle))
      true
    )
    (ok true)))

(define-public (make-delayed-payment
  (amount uint))
  (let (
    (funds-requested (get funds-requested (try! (get-delinquent-counterparty-info tx-sender)))))
    (asserts! (is-eq amount funds-requested) ERR_PAYMENT_AMOUNTS_DONT_MATCH)
    (try! (contract-call? .ht-vault-ststx-earn-v4 deposit-funds amount tx-sender))
    (map-delete delinquent-counterparty-info { address: tx-sender })
    (var-set helper-principal tx-sender)
    (ok (var-set delinquent-counterparty-addresses (filter remove-principal (var-get delinquent-counterparty-addresses))))))

;;-------------------------------------
;; Helper 
;;-------------------------------------

(define-private (delete-counterparty
  (counterparty-address principal))
  (ok (map-delete counterparty-info { address: counterparty-address })))

(define-private (add-delinquent-counterparty
  (counterparty-address principal))
  (let (
    (counterparty-info-entry (unwrap-panic (get-counterparty-info counterparty-address))) 
    (funds-requested (unwrap-panic (get funds-requested counterparty-info-entry)))
    (units-transacted (get units-transacted counterparty-info-entry)))
    (map-set delinquent-counterparty-info { address: counterparty-address }
      { 
        funds-requested: funds-requested,
        units-transacted: units-transacted,
        epoch-id: (get-current-epoch-id)
      }
    )
    (ok (var-set delinquent-counterparty-addresses (unwrap-panic (as-max-len? (append (var-get delinquent-counterparty-addresses) counterparty-address) u5000))))))

(define-private (remove-principal
  (list-item principal))
  (not (is-eq (var-get helper-principal) list-item)))

(define-read-only (usd-to-option-asset (usd uint) (usd-per-option-asset uint))
  (/ (* usd underlying-base) usd-per-option-asset))

;;-------------------------------------
;; Initialize 
;;-------------------------------------

(define-public (initialize
  (first-expiry uint))
  (begin
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-admin tx-sender))
    (asserts! (not (var-get is-initialized)) ERR_ALREADY_INITIALIZED)
    (var-set is-initialized true) ;; Set to true so that this can't be called again
    (map-set epoch-info { epoch-id: u0 } 
      {
        epoch-expiry: first-expiry,
        strike-call: none,
        strike-put: none,
        barrier-up: none,
        barrier-down: none,
        unit-pnl: none,
        settlement-rate: none,
        block-height-start: burn-block-height,
        block-height-pnl: none,
        block-height-settled: none,
        total-units-transacted: u0,
        total-premium: u0,
        total-underlying-active: u0,
        underlying-per-token-settled: none,
        epoch-risk: (contract-call? .ht-hq-ststx-earn-v4 get-epoch-risk),
        unit-size: (contract-call? .ht-hq-ststx-earn-v4 get-unit-size)
      }
    )
    (ok true)))

;;-------------------------------------
;; Emergency API 
;;-------------------------------------

;; In case of a deliquent counterparty this function ensures that the current epoch can be settled and deposits and withdrawals are procssed

(define-public (force-settle)
  (let (
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (block-height-pnl (unwrap! (get block-height-pnl current-epoch-info) ERR_PNL_UNDETERMINED)))
    (asserts! (> burn-block-height (+ block-height-pnl (contract-call? .ht-hq-ststx-earn-v4 get-payment-window))) ERR_PAYMENT_WINDOW_STILL_OPEN)
    (if (is-none (get block-height-settled current-epoch-info))
      (begin ;; block-height-settled == none
        (var-set delinquent-epoch true)
        (map add-delinquent-counterparty (var-get counterparty-addresses))
        (try! (settle))
      )
      (try! (activate-pending-claims))
    )
    (ok true)))

;; In case of malfuntion or compromise of determine-pnl this function ensures that a pnl is set so that settle can be called

(define-public (force-determine-pnl
  (use-block-height bool)
  (price-feed-bytes (buff 8192))
  (execution-plan {
    pyth-storage-contract: <pyth-storage-trait>,
    pyth-decoder-contract: <pyth-decoder-trait>,
    wormhole-core-contract: <wormhole-core-trait>
  }))
  (let (
    (epoch-id (get-current-epoch-id))
    (current-epoch-info (unwrap-panic (get-current-epoch-info)))
    (current-epoch-expiry (get epoch-expiry current-epoch-info))
    (pnl-calculation-window (contract-call? .ht-hq-ststx-earn-v4 get-pnl-calculation-window)))
    (asserts! (is-none (get block-height-pnl current-epoch-info)) ERR_PNL_ALREADY_DETERMINED)
    (if use-block-height
      (let (
        (previous-epoch-expiry (get epoch-expiry (try! (get-epoch-info (- epoch-id u1)))))
        (expected-epoch-duration-in-blocks (/ (/ (- current-epoch-expiry previous-epoch-expiry) minute-in-ms) u10))
        (current-block-height-start (get block-height-start current-epoch-info))
        (pnl-calculation-window-in-blocks (/ (/ pnl-calculation-window minute-in-ms) u10))
        (safety-margin (* u5 u144))) ;; 5 days worth of blocks
        (asserts! (>= burn-block-height (+ (+ (+ current-block-height-start expected-epoch-duration-in-blocks) pnl-calculation-window-in-blocks) safety-margin)) ERR_PNL_CALCULATION_WINDOW_STILL_OPEN))
      (let (
        (decoded-prices (try! (contract-call? 'SP2T5JKWWP3FYYX4YRK8GK5BG2YCNGEAEY2P2PKN0.pyth-oracle-v2 decode-price-feeds price-feed-bytes execution-plan)))
        (decoded-price (element-at decoded-prices u0))
        (timestamp (* (unwrap-panic (get publish-time decoded-price)) u1000)))
        (asserts! (>= timestamp (+ current-epoch-expiry pnl-calculation-window)) ERR_PNL_CALCULATION_WINDOW_STILL_OPEN)
      )
    )
    (map-set epoch-info { epoch-id: epoch-id } 
      (merge
        current-epoch-info
        { 
          unit-pnl: (some u0),
          settlement-rate: (some u0),
          block-height-pnl: (some burn-block-height)
        }
      )
    )
    (var-set delinquent-epoch true) ;; set true so no fees are charged
    (try! (settle))
    (ok true)))

;; In case of contract malfunction these function ensure all funds in the contract can be recovered

(define-public (force-activate-pending-deposit-claims)
  (begin
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-admin tx-sender))
    (as-contract (contract-call? .ht-vault-ststx-earn-v4 activate-pending-deposit-claims))))

(define-public (force-activate-pending-withdrawal-claims)
  (begin
    (try! (contract-call? .ht-hq-ststx-earn-v4 check-is-admin tx-sender))
    (as-contract (contract-call? .ht-vault-ststx-earn-v4 activate-pending-withdrawal-claims))))