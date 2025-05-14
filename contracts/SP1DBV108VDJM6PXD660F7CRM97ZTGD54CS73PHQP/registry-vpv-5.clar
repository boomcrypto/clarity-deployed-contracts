;; title: registry-vpv-5

(impl-trait .registry-trait-vpv-5.registry-trait)

(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-5.sorted-vaults-trait)

(define-constant ERR_MODE_PAUSED (err u200))
(define-constant ERR_MODE_RECOVERY (err u201))
(define-constant ERR_VAULT_RATIO_THRESHOLD (err u202))
(define-constant ERR_GLOBAL_RATIO_THRESHOLD (err u203))
(define-constant ERR_LIST_OVERFLOW (err u204))
(define-constant ERR_VAULT_NOT_FOUND (err u205))
(define-constant ERR_LIST_LENGTH (err u206))
(define-constant ERR_INVALID_LIST (err u207))
(define-constant ERR_INVALID_SORT (err u208))
(define-constant ERR_SLICE (err u209))
(define-constant ERR_VAULT_HEALTHY (err u210))
(define-constant ERR_PROVIDER_NOT_FOUND (err u211))
(define-constant ERR_ORACLE_PRICE_NOT_FOUND (err u212))
(define-constant ERR_PROTOCOL_DATA (err u213))
(define-constant ERR_INVALID_EPOCH (err u214))
(define-constant ERR_NO_KEEPER (err u215))
(define-constant ERR_AUTH (err u216))
(define-constant ERR_NO_ADMIN (err u217))
(define-constant ERR_MODE_MAINTENANCE (err u218))
(define-constant ERR_BASE_RATE (err u219))
(define-constant ERR_ACCRUED_INTEREST (err u220))
(define-constant ERR_INVALID_VALUE (err u221))

(define-constant contract-deployer tx-sender)

(define-constant PROTOCOL_STATE_NORMAL u0)
(define-constant PROTOCOL_STATE_PAUSED u1)
(define-constant PROTOCOL_STATE_MAINTENANCE u2)

;; Blocks per 12-hour period
(define-constant half-day u72)
;; Blocks per 24-hour period
(define-constant full-day (* half-day u2))
;; Blocks per 1-year period (for interest rate calculations)
(define-constant year (* full-day u365))

;; precision
(define-constant PRECISION u8)

;; one full unit of precision u8 - ie. 100%, one bsd, one sbtc
(define-constant ONE_FULL_UNIT u100000000)

;; Economic Variables - BEGIN

;; The minimum collateral ratio required for a vault to be considered safe, if it's below this, must be liquidated
(define-data-var vault-collateral-ratio-threshold uint u110000000) ;; 110%

;; The recovery collateral ratio used for vaults when the system is in recovery mode (aka global collateral ratio is below threshold)
(define-data-var vault-recovery-ratio-threshold uint u150000000) ;; 150%

;; Once the global collateral ratio is below this threshold, the system will kick into recovery mode
(define-data-var global-collateral-ratio-threshold uint u125000000) ;; 125%

;; Base rate alpha - in debt formula it is just .5
(define-data-var alpha uint (/ ONE_FULL_UNIT u2))

;; Base rate delta (decay rate) - .94 coefficient
(define-data-var delta uint u94000000)

;; Pre-calculated decay rates based on hours
;; The blocks per hour can be tweaked via the blocks-per-hour variable
(define-data-var hourly-decay-rates (list 500 uint) (list u100000000 u94000000 u88360000 u83058399 u78074895 u73390402 u68986978 u64847759 u60956893 u57299480 u53861511 u50629820 u47592031 u44736509 u42052319 u39529179 u37157429 u34927983 u32832304 u30862366 u29010624 u27269986 u25633787 u24095760 u22650014 u21291013 u20013552 u18812739 u17683975 u16622936 u15625560 u14688026 u13806745 u12978340 u12199640 u11467661 u10779602 u10132825 u9524856 u8953365 u8416163 u7911193 u7436521 u6990330 u6570910 u6176655 u5806056 u5457693 u5130231 u4822417 u4533072 u4261088 u4005422 u3765097 u3539191 u3326840 u3127229 u2939596 u2763220 u2597427 u2441581 u2295086 u2157381 u2027938 u1906262 u1791886 u1684373 u1583310 u1488312 u1399013 u1315072 u1236168 u1161998))

;; Max decay hour count - after this hour count the max-decay is 1161998
(define-data-var max-hours-decay uint u72)

;; This is the value returned after the max-hours-decay is exceeded
(define-data-var max-decay uint u0)

;; This is the number of blocks per decay-rate
;; ie. 6 blocks means that 6 block must elapse before the next value in the decay rates is used
(define-data-var blocks-per-hour uint u6)

;; This is the number of hours per epoch
;; The number of blocks per epoch is blocks-per-hour * hours-per-epoch
;; default is 24 hrs/day * 7 day = 168 hours per epoch
(define-data-var hours-per-epoch uint u168)

;; minimum borrow fee 
(define-data-var min-borrow-fee uint (/ ONE_FULL_UNIT u200)) ;; .5%

;; maximum borrow fee 
(define-data-var max-borrow-fee uint (/ ONE_FULL_UNIT u20)) ;; 5%

;; minimum redeem fee 
(define-data-var min-redeem-fee uint (/ ONE_FULL_UNIT u200)) ;; .5%

;; maximum redeem fee 
(define-data-var max-redeem-fee uint ONE_FULL_UNIT) ;; 100%

;; Redeem minimum (10 bsd)
(define-data-var min-redeem-amount uint (* u10 ONE_FULL_UNIT))

;; Vault & loan minimum (1k bsd)
(define-data-var vault-loan-minimum uint (* u1000 ONE_FULL_UNIT))

;; Initial interest rate minimum (1%)
(define-data-var vault-interest-minimum uint (/ ONE_FULL_UNIT u100))

;; Initial interest rate maximum (100%)
(define-data-var vault-interest-maximum uint ONE_FULL_UNIT)

;; global collateral cap - must always go up - starts at 2M USD equivalent sBTC
(define-data-var global-collateral-cap uint (* u2000000 ONE_FULL_UNIT))

;; protocol fee destination - default to deployer
(define-data-var protocol-fee-destination principal contract-deployer)

;; Minimum stability balance for a provider (1k bsd)
(define-data-var min-stability-provider-balance uint (* u1000 ONE_FULL_UNIT))

;; Epoch genesis 
;; This allows us to specify the block at which our first epoch will begin
(define-data-var epoch-genesis uint burn-block-height)

;; Oracle stale threshold
;; This is the number of blocks after which an oracle price is considered stale
(define-data-var oracle-stale-threshold uint u9)

;; Max number of vaults that can be redeemed
;; The aggregate bsd in these vaults will give us the max amount that a user can redeem in a single transaction
(define-data-var max-vaults-to-redeem uint u10)

;; Economic Variables - END

;; Protocol Debt/Collateral for Redistribution
;; We use this to calculate in real-time the amount of protocol debt and collateral to attribute to a given vault
(define-data-var protocol-redistribution-params 
    { 
        aggregate-protocol-debt-bsd: uint,
        aggregate-protocol-collateral-sbtc: uint,
        current-sum-collateral-sbtc: uint,
    } 
    { 
        aggregate-protocol-debt-bsd: u0,
        aggregate-protocol-collateral-sbtc: u0,
        current-sum-collateral-sbtc: u0,
    }
)

;; global debt & collateral
(define-data-var aggregate-debt-and-collateral {debt-bsd: uint, collateral-sbtc: uint} {debt-bsd: u0, collateral-sbtc: u0})

;; protocol state
(define-data-var protocol-state uint PROTOCOL_STATE_NORMAL)

;; created vaults - vault indexer
(define-data-var created-vaults uint u0)

;; base rate
;; starts at 0 and is updated through redemptions
;; decays back towards 0 during periods of inactivity
(define-data-var base-rate uint u0)

;; Last redeem update height
(define-data-var last-redeem-height uint u0)

;; stability pool
(define-data-var stability-pool 
    {
        aggregate-bsd: uint, 
        aggregate-sbtc: uint, 
        active: (list 1000 principal), 
        product: uint, 
        current-checkpoint: uint
    } 
    { 
        aggregate-bsd: u0, 
        aggregate-sbtc: u0, 
        active: (list ), 
        product: ONE_FULL_UNIT, 
        current-checkpoint: u0
    })

;; vault
(define-map vault uint {
    borrower: principal,
    created-height: uint,
    ;; debt
    borrowed-bsd: uint,
    ;; collateral
    collateral-sbtc: uint,
    ;; protocol debt
    protocol-debt-bsd: uint,
    ;; protocol collateral
    protocol-collateral-sbtc: uint,
    ;; protocol sum collateral
    protocol-sum-collateral-sbtc: uint,
    ;; interest rate (annual)
    interest-rate: uint,
    ;; block when last interest accrual happened
    last-interest-accrued: uint,
    ;; future interest rate
    future-interest-rate: uint,
    ;; future interest rate epoch
    future-interest-epoch: uint,
    ;; interest-rate-delegate 
    interest-rate-delegate: principal,
})

;; vaults per principal - limit 50 vaults per principal
(define-map vaults-per-principal principal (list 50 uint))

;; stability pool providers
(define-map stability-pool-providers principal {
    liquidity-staked: uint,
    sum_t: uint,
    product_t: uint,
    checkpoint: uint,
}) 

;; historical checkpoint rewards
(define-map checkpoint-rewards uint {
    checkpoint: uint,
    sum: uint,
})

;; prepopulate checkpoint 0
(map-set checkpoint-rewards u0 {checkpoint: u0, sum: u0})

;;;;;;;;;;;;;;;;;;;;;;;
;; registry-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;

;; get-checkpoint-sum
(define-read-only (get-checkpoint-sum (checkpoint uint))
    (ok (map-get? checkpoint-rewards checkpoint))
)

;; get is-paused
(define-read-only (get-is-paused)
    (ok (is-eq PROTOCOL_STATE_PAUSED (var-get protocol-state)))
)

;; get is-maintenance
(define-read-only (get-is-maintenance)
    (ok (is-eq PROTOCOL_STATE_MAINTENANCE (var-get protocol-state)))
)

;; get-protocol-fee-destination
(define-read-only (get-protocol-fee-destination)
    (ok (var-get protocol-fee-destination))
)

;; get-stability-pool-data
(define-read-only (get-stability-pool-data)
    (ok (var-get stability-pool))
)

;; get-decay-rates
(define-read-only (get-decay-rates)
    (ok (var-get hourly-decay-rates))
)

;; get-stability-pool-provider
(define-read-only (get-stability-pool-provider (principal principal))
    (ok (map-get? stability-pool-providers principal))
)

;; get provider calculated balance
(define-read-only (get-provider-calculated-balance (principal principal))
    (ok (unwrap-panic (calculate-compounded-deposit principal)))
)

;; Get all active vaults
(define-public (get-active-vaults (sorted-vaults <sorted-vaults-trait>))
    (ok (get total-vaults (unwrap-panic (contract-call? sorted-vaults get-vaults-summary))))
)

(define-read-only (get-aggregate-debt-and-collateral)
    (ok (var-get aggregate-debt-and-collateral))
)

;; get vaults by principal
(define-read-only (get-vaults-by-principal (principal principal))
    (ok (map-get? vaults-per-principal principal))
)

;; Get specific vault
(define-read-only (get-vault (vault-id uint))
    (ok (map-get? vault vault-id))
)

;; calculate-collateral-ratio
(define-read-only (calculate-collateral-ratio (debt uint) (collateral uint) (sbtc-price uint)) 
    (let 
        (
            (vault-collateral-in-bsd (mul-to-fixed-precision sbtc-price PRECISION collateral))
            (vault-collateral-ratio (if (is-eq debt u0) u0 ( div-to-fixed-precision vault-collateral-in-bsd PRECISION debt)))
        ) 
        (ok vault-collateral-ratio)
    )
)

;; Get specific vault
(define-read-only (get-vault-compounded-info (vault-id uint) (sbtc-price uint))
    (let 
        (
            ;; base
            (vault-info (unwrap-panic (get-vault vault-id)))
            (vault-debt (unwrap-panic (get borrowed-bsd vault-info)))
            (vault-collateral (unwrap-panic (get collateral-sbtc vault-info)))
            (vault-protocol-shares (unwrap-panic (get-vault-protocol-shares vault-id)))
            (vault-calc-protocol-debt (get calculated-protocol-debt vault-protocol-shares))
            (vault-calc-protocol-collateral (get calculated-protocol-collateral vault-protocol-shares))
            (vault-attr-protocol-debt (get attributed-protocol-debt vault-protocol-shares))
            (vault-attr-protocol-collateral (get attributed-protocol-collateral vault-protocol-shares))
            ;; calculated
            (accrued-interest (unwrap-panic (get-vault-accrued-interest vault-id)))
            (vault-total-debt (+ vault-debt vault-calc-protocol-debt vault-attr-protocol-debt))
            (vault-total-collateral (+ vault-collateral vault-calc-protocol-collateral vault-attr-protocol-collateral))
            (vault-collateral-in-bsd (mul-to-fixed-precision sbtc-price PRECISION vault-total-collateral))

            ;; if vault-total-debt is 0 then the collateral ratio is infinite - just return 0
            (vault-collateral-ratio (if (is-eq vault-total-debt u0) u0 ( div-to-fixed-precision vault-collateral-in-bsd PRECISION vault-total-debt)))
        ) 
        (ok 
            {
                vault-total-debt: (+ vault-total-debt accrued-interest),
                vault-total-collateral: vault-total-collateral,
                vault-debt: (+ vault-debt accrued-interest),
                vault-collateral: vault-collateral,
                vault-protocol-debt: vault-attr-protocol-debt,
                vault-protocol-collateral: vault-attr-protocol-collateral,
                vault-protocol-debt-calculated: vault-calc-protocol-debt,
                vault-protocol-collateral-calculated: vault-calc-protocol-collateral,
                vault-collateral-ratio: vault-collateral-ratio,
                calculated-block: burn-block-height,
                vault-accrued-interest: accrued-interest,
                vault-info: {
                    borrower: (unwrap-panic (get borrower vault-info)),
                    created-height: (unwrap-panic (get created-height vault-info)),
                    borrowed-bsd: (unwrap-panic (get borrowed-bsd vault-info)),
                    collateral-sbtc: (unwrap-panic (get collateral-sbtc vault-info)),
                    protocol-debt-bsd: (unwrap-panic (get protocol-debt-bsd vault-info)),
                    protocol-collateral-sbtc: (unwrap-panic (get protocol-collateral-sbtc vault-info)),
                    protocol-sum-collateral-sbtc: (unwrap-panic (get protocol-sum-collateral-sbtc vault-info)),
                    interest-rate: (unwrap-panic (get interest-rate vault-info)),
                    last-interest-accrued: (unwrap-panic (get last-interest-accrued vault-info)),
                    future-interest-rate: (unwrap-panic (get future-interest-rate vault-info)),
                    future-interest-epoch: (unwrap-panic (get future-interest-epoch vault-info)),
                    interest-rate-delegate: (unwrap-panic (get interest-rate-delegate vault-info)),
                },
            }
        )
    )
)

;; Get vault accrued interest
(define-read-only (get-vault-accrued-interest (vault-id uint))
    (match (map-get? vault vault-id)
        current-vault
            (let 
                (
                    (vault-current-loan (get borrowed-bsd current-vault))
                    (vault-interest-rate (get interest-rate current-vault))
                    (vault-last-interest-accrued (get last-interest-accrued current-vault))
                    (blocks-to-accrue ( - burn-block-height vault-last-interest-accrued))
                )
                (ok (/ (* (mul-to-fixed-precision vault-current-loan PRECISION vault-interest-rate) blocks-to-accrue) year))
            )
        (ok u0)
    )
)

;; Get vault protocol debt and collateral shares
(define-read-only (get-vault-protocol-shares (vault-id uint))
    (match (map-get? vault vault-id)
        current-vault
            (let 
                (   (vault-debt (get borrowed-bsd current-vault))
                    (vault-collateral (get collateral-sbtc current-vault))
                    (redistribution-params (unwrap-panic (get-redistribution-params)))
                    (protocol-sum-collateral (get current-sum-collateral-sbtc redistribution-params))
                    (aggregate-protocol-debt-bsd (get aggregate-protocol-debt-bsd redistribution-params))
                    (aggregate-protocol-collateral-sbtc (get aggregate-protocol-collateral-sbtc redistribution-params))
                    (vault-protocol-debt (get protocol-debt-bsd current-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc current-vault))
                    (vault-sum-collateral (get protocol-sum-collateral-sbtc current-vault))
                    (calculated-protocol-collateral (mul (+ vault-collateral vault-protocol-collateral) (- protocol-sum-collateral vault-sum-collateral)))
                    (calculated-ratio (if (is-eq calculated-protocol-collateral u0) u0 (div-round-down calculated-protocol-collateral aggregate-protocol-collateral-sbtc)))
                    (calculated-protocol-debt (mul calculated-ratio aggregate-protocol-debt-bsd))
                )
                (ok { calculated-protocol-debt: calculated-protocol-debt, calculated-protocol-collateral: calculated-protocol-collateral, attributed-protocol-debt: vault-protocol-debt, attributed-protocol-collateral: vault-protocol-collateral })
            )
        (ok {calculated-protocol-debt: u0, calculated-protocol-collateral: u0, attributed-protocol-debt: u0, attributed-protocol-collateral: u0})
    )
)

;; Get height since last update, once half a day / 72 blocks has passed base rate is at lowest
(define-read-only (get-height-since-last-redeem)
    (if (> (- burn-block-height (var-get last-redeem-height)) half-day)
        (ok half-day)
        (ok (- burn-block-height (var-get last-redeem-height)))
    )
)

;; get-base-rate
(define-read-only (get-base-rate)
    (ok (var-get base-rate))
)

(define-read-only (calculate-redeem-fee-rate (bsd-amount uint))
   (let 
        (
            (current-aggregate-bsd-loans (get debt-bsd (var-get aggregate-debt-and-collateral)))
            (base-rate-constants (get-base-rate-constants))
            (valid-ratio (asserts! (and (> current-aggregate-bsd-loans u0) (> bsd-amount u0) (>= current-aggregate-bsd-loans bsd-amount)) ERR_INVALID_VALUE))
            (ratio ( div-to-fixed-precision bsd-amount PRECISION current-aggregate-bsd-loans))
            (alpha-times-ratio (mul-to-fixed-precision (get alpha (unwrap! (get-base-rate-constants) ERR_BASE_RATE)) PRECISION ratio))
            (decayed-base-rate (get-decayed-base-rate))
            (calc-fee-rate (+ decayed-base-rate alpha-times-ratio))
            (final-fee-rate (if (< calc-fee-rate (var-get min-redeem-fee)) (var-get min-redeem-fee) (if (> calc-fee-rate (var-get max-redeem-fee)) (var-get max-redeem-fee) calc-fee-rate)))
        )
        (ok final-fee-rate)
    )  
)

(define-read-only (get-borrow-fee-rate (recovery-mode bool))
   (let (
            (decayed-base-rate (get-decayed-base-rate))
            (final-fee-rate (if (< decayed-base-rate (var-get min-borrow-fee)) (var-get min-borrow-fee) (if (> decayed-base-rate (var-get max-borrow-fee)) (var-get max-borrow-fee) decayed-base-rate)))
        )
        (if recovery-mode
            (ok u0)
            (ok final-fee-rate)
        )
    )  
)

;; get-base-rate-constants
(define-read-only (get-base-rate-constants)
   (ok 
        {
            alpha: (var-get alpha),
            delta: (var-get delta),
        }
   )
)

;; get redistribution params
(define-read-only (get-redistribution-params)
    (ok (var-get protocol-redistribution-params))
)

;; pause-protocol
(define-public (set-protocol-state (new-state uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (asserts! (or (is-eq new-state PROTOCOL_STATE_NORMAL) (is-eq new-state PROTOCOL_STATE_PAUSED) (is-eq new-state PROTOCOL_STATE_MAINTENANCE)) ERR_INVALID_VALUE)
        (var-set protocol-state new-state)
        (ok true)
    )
)

;; pause-protocol
(define-public (hot-pause)
    (begin
        (try! (contract-call? .controller-vpv-5 is-hot-pause-caller tx-sender))
        (var-set protocol-state PROTOCOL_STATE_PAUSED)
        (ok true)
    )
)

(define-public (set-decay-parameters (new-delta uint) (new-max-decay uint) (new-max-hours-decay uint) (new-hourly-decay-rates (list 500 uint)) (new-blocks-per-hour uint) (new-hours-per-epoch uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (var-set delta new-delta)
        (var-set max-decay new-max-decay)
        (var-set max-hours-decay new-max-hours-decay)
        (var-set hourly-decay-rates new-hourly-decay-rates)
        (var-set blocks-per-hour new-blocks-per-hour)
        (var-set hours-per-epoch new-hours-per-epoch)
        (ok true)
    )
)

(define-public (set-borrow-parameters (new-min-borrow-fee uint) (new-max-borrow-fee uint) (new-loan-minimum uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (asserts! (> new-max-borrow-fee new-min-borrow-fee) ERR_INVALID_VALUE)
        (var-set min-borrow-fee new-min-borrow-fee)
        (var-set max-borrow-fee new-max-borrow-fee)
        (var-set vault-loan-minimum new-loan-minimum)
        (ok true)
    )
)

(define-public (set-redeem-parameters (new-min-redeem-fee uint) (new-max-redeem-fee uint) (new-alpha uint) (new-min-redeem-amount uint) (new-max-vaults-to-redeem uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))

        (asserts! (> new-max-redeem-fee new-min-redeem-fee) ERR_INVALID_VALUE)
        (asserts! (> new-max-vaults-to-redeem u0) ERR_INVALID_VALUE)

        (var-set min-redeem-fee new-min-redeem-fee)
        (var-set max-redeem-fee new-max-redeem-fee)
        (var-set alpha new-alpha)
        (var-set min-redeem-amount new-min-redeem-amount)
        (var-set max-vaults-to-redeem new-max-vaults-to-redeem)
        (ok true)
    )
)

(define-public (set-vault-parameters (new-interest-minimum uint) (new-interest-maximum uint) (new-vault-collateral-ratio-threshold uint) (new-vault-recovery-ratio-threshold uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (asserts! ( > new-vault-recovery-ratio-threshold new-vault-collateral-ratio-threshold) ERR_INVALID_VALUE)
        (var-set vault-collateral-ratio-threshold new-vault-collateral-ratio-threshold)
        (var-set vault-recovery-ratio-threshold new-vault-recovery-ratio-threshold)
        (var-set vault-interest-minimum new-interest-minimum)
        (var-set vault-interest-maximum new-interest-maximum)
        (ok true)
    )
)

(define-public (set-global-parameters (new-global-collateral-ratio-threshold uint) (new-global-collateral-cap uint) (new-protocol-fee-destination principal) (new-min-stability-provider-balance uint) (new-epoch-genesis uint) (new-oracle-stale-threshold uint))
    (begin
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (asserts! (> new-global-collateral-ratio-threshold ONE_FULL_UNIT) ERR_INVALID_VALUE)
        (var-set global-collateral-ratio-threshold new-global-collateral-ratio-threshold)
        (var-set global-collateral-cap new-global-collateral-cap)
        (var-set protocol-fee-destination new-protocol-fee-destination)
        (var-set min-stability-provider-balance new-min-stability-provider-balance)
        (var-set epoch-genesis new-epoch-genesis)
        (var-set oracle-stale-threshold new-oracle-stale-threshold)
        (ok true)
    )
)

(define-read-only (get-oracle-stale-threshold) 
    (ok (var-get oracle-stale-threshold))
)

;; get protocol info for vault actions
(define-read-only (get-vault-protocol-info (sbtc-price uint))
    (let
        (
            (aggregate-amounts (var-get aggregate-debt-and-collateral))
            (total-debt-bsd (get debt-bsd aggregate-amounts))
            (total-collateral-in-sbtc (get collateral-sbtc aggregate-amounts))
            (total-collateral-in-bsd (mul-to-fixed-precision total-collateral-in-sbtc PRECISION sbtc-price))
            (global-threshold (var-get global-collateral-ratio-threshold))
            (denominator (if (is-eq u0 total-debt-bsd) u1 total-debt-bsd))
            (global-ratio ( div-to-fixed-precision total-collateral-in-bsd PRECISION denominator))
            (recovery-mode (< global-ratio global-threshold))
        )
        (ok 
            {
                current-oracle-price-sbtc: sbtc-price,
                total-bsd-loans: (get debt-bsd (var-get aggregate-debt-and-collateral)),
                total-sbtc-collateral: (get collateral-sbtc (var-get aggregate-debt-and-collateral)),
                total-collateral-in-bsd: total-collateral-in-bsd,
                recovery-mode: recovery-mode,
                latest-vault-id: (var-get created-vaults),
                is-paused: (is-eq PROTOCOL_STATE_PAUSED (var-get protocol-state)),
                is-maintenance: (is-eq PROTOCOL_STATE_MAINTENANCE (var-get protocol-state)),
                vault-threshold: (var-get vault-collateral-ratio-threshold),
                recovery-threshold: (var-get vault-recovery-ratio-threshold),
                global-collateral-cap: (var-get global-collateral-cap),
                protocol-fee-destination: (var-get protocol-fee-destination),
                vault-loan-minimum: (var-get vault-loan-minimum),
                vault-interest-minimum: (var-get vault-interest-minimum),
                vault-interest-maximum: (var-get vault-interest-maximum),
                oracle-stale-threshold: (var-get oracle-stale-threshold),
                borrow-fee-rate: (unwrap-panic (get-borrow-fee-rate recovery-mode))
            }
        )
    )
)

;; get-protocol-data
(define-public (get-protocol-data (sbtc-price uint) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (aggregate-amounts (var-get aggregate-debt-and-collateral))
            (total-debt-bsd (get debt-bsd aggregate-amounts))
            (total-collateral-in-sbtc (get collateral-sbtc aggregate-amounts))
            (total-collateral-in-bsd (mul-to-fixed-precision total-collateral-in-sbtc PRECISION sbtc-price))
            (global-threshold (var-get global-collateral-ratio-threshold))
            (denominator (if (is-eq u0 total-debt-bsd) u1 total-debt-bsd))
            (global-ratio ( div-to-fixed-precision total-collateral-in-bsd PRECISION denominator))
            (recovery-mode (< global-ratio global-threshold))
        )
        (ok 
            (merge 
                {
                    current-oracle-price-sbtc: sbtc-price,
                    global-ratio: global-ratio,
                    recovery-mode: recovery-mode,
                    total-collateral-in-bsd: total-collateral-in-bsd,  
                }
                (unwrap-panic (get-protocol-attributes sorted-vaults))
            ) 
        )
    )
)

;; get-protocol-attributes
(define-public (get-protocol-attributes (sorted-vaults <sorted-vaults-trait>))
        (ok {
            ;; active protocol data
            total-bsd-loans: (get debt-bsd (var-get aggregate-debt-and-collateral)),
            total-sbtc-collateral: (get collateral-sbtc (var-get aggregate-debt-and-collateral)),
            active-vaults: (get total-vaults (unwrap-panic (contract-call? sorted-vaults get-vaults-summary))),
            created-vaults: (var-get created-vaults),
            is-paused: (is-eq PROTOCOL_STATE_PAUSED (var-get protocol-state)),
            is-maintenance: (is-eq PROTOCOL_STATE_MAINTENANCE (var-get protocol-state)),
            base-rate: (var-get base-rate),
            last-redeem-height: (var-get last-redeem-height),

            ;; configurable economic variables
            vault-threshold: (var-get vault-collateral-ratio-threshold),
            recovery-threshold: (var-get vault-recovery-ratio-threshold),
            global-threshold: (var-get global-collateral-ratio-threshold),
            global-collateral-cap: (var-get global-collateral-cap),
            protocol-fee-destination: (var-get protocol-fee-destination),
            epoch-genesis: (var-get epoch-genesis),
            alpha: (var-get alpha),
            delta: (var-get delta),
            min-borrow-fee: (var-get min-borrow-fee),
            max-borrow-fee: (var-get max-borrow-fee),
            min-redeem-fee: (var-get min-redeem-fee),
            max-redeem-fee: (var-get max-redeem-fee),
            min-redeem-amount: (var-get min-redeem-amount),
            max-vaults-to-redeem: (var-get max-vaults-to-redeem),
            min-stability-provider-balance: (var-get min-stability-provider-balance),
            max-decay: (var-get max-decay),
            max-hours-decay: (var-get max-hours-decay),
            blocks-per-hour: (var-get blocks-per-hour),
            vault-loan-minimum: (var-get vault-loan-minimum),
            vault-interest-minimum: (var-get vault-interest-minimum),
            vault-interest-maximum: (var-get vault-interest-maximum),
            hours-per-epoch: (var-get hours-per-epoch),
            oracle-stale-threshold: (var-get oracle-stale-threshold),
        })
)

;; new vault
(define-public (new-vault (borrower principal) (collateral-sbtc uint) (loan-bsd uint) (interest-rate uint) (hint (optional uint)) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (current-vault-id (var-get created-vaults))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-epoch (get-current-epoch))
            (next-epoch (+ current-epoch u1))
            (current-sum-protocol-collateral-sbtc (get current-sum-collateral-sbtc (var-get protocol-redistribution-params)))
        )
        
        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; Update entry in vaults per principal map
        (map-set vaults-per-principal tx-sender 
            (unwrap! (as-max-len? 
                (append 
                    (default-to (list ) (map-get? vaults-per-principal tx-sender))
                    current-vault-id
                ) 
            u50) ERR_LIST_OVERFLOW)
        )

        ;; Create new vault by updating vault map
        (map-set vault current-vault-id {
            borrower: tx-sender,
            created-height: burn-block-height,
            borrowed-bsd: loan-bsd,
            collateral-sbtc: collateral-sbtc,
            protocol-debt-bsd: u0,
            protocol-collateral-sbtc: u0,
            protocol-sum-collateral-sbtc: current-sum-protocol-collateral-sbtc,
            interest-rate: interest-rate,
            last-interest-accrued: burn-block-height,
            future-interest-rate: interest-rate,
            future-interest-epoch: next-epoch,
            interest-rate-delegate: tx-sender,
        })
        ;; Update aggregate debt and collateral
        (var-set aggregate-debt-and-collateral {
            debt-bsd: (+ (get debt-bsd current-aggregate) loan-bsd),
            collateral-sbtc: (+ (get collateral-sbtc current-aggregate) collateral-sbtc),
        })

        (if (> current-vault-id u0)
            (begin 
                (try! (contract-call? sorted-vaults insert current-vault-id interest-rate hint))
                true
            )
            false
        )

        (ok (var-set created-vaults (+ current-vault-id u1)))
    )
)

;; new loan
(define-public (mint-loan (vault-id uint) (borrow-bsd uint) (sbtc-price uint))
    (let 
        (
            ;; action
            (attributed (attribute-protocol-balances vault-id)) ;; attribute protocol debt & collateral

            ;; get total vault & protocol debt
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-debt (get vault-debt vault-balances))

            ;; get aggregate bsd
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-bsd (get debt-bsd current-aggregate))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update aggregate
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: (+ current-aggregate-bsd borrow-bsd),
            })
        )

        ;; update vault
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                borrowed-bsd: (+ vault-debt borrow-bsd),
            })
        )

        (ok true)
    )
)

;; repay-loan
(define-public (repay-loan (vault-id uint) (repay-amount uint) (sbtc-price uint))
    (let 
        (
            ;; action
            (attributed (attribute-protocol-balances vault-id))

            ;; get aggregate bsd
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-bsd (get debt-bsd current-aggregate))

            ;; get total vault & protocol debt
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-debt (get vault-debt vault-balances))
            (vault-protocol-debt (get vault-protocol-debt vault-balances))

            ;; calculate amounts from vault and protocol debt tranches
            (new-vault-debt (if (> repay-amount vault-debt) u0 (- vault-debt repay-amount)))
            (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- repay-amount vault-debt)) vault-protocol-debt))
        )

        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update aggregate debt and collateral
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                debt-bsd: (- current-aggregate-bsd repay-amount)
            })
        )

        ;; update vault
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                borrowed-bsd: new-vault-debt,
                protocol-debt-bsd: new-protocol-debt,
            })
        )

        (ok true)
    )
)

;; add-collateral
(define-public (add-collateral (vault-id uint) (add-amount uint) (sbtc-price uint))
    (let
        (
            ;; action
            (attributed (attribute-protocol-balances vault-id))

            ;; get total vault & protocol debt
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-collateral (get vault-collateral vault-balances))

            ;; get aggregate bsd
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-sbtc (get collateral-sbtc current-aggregate))
        ) 

        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update aggregate debt and collateral
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                collateral-sbtc: (+ current-aggregate-sbtc add-amount)
            })
        )

        ;; update vault
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                collateral-sbtc: (+ vault-collateral add-amount),
            })
        )

        (ok true)
    )
)

;; remove-collateral
(define-public (remove-collateral (vault-id uint) (remove-amount uint) (sbtc-price uint))
    (let
        (
            ;; action
            (attributed (attribute-protocol-balances vault-id))

            ;; get aggregate bsd
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-sbtc (get collateral-sbtc current-aggregate))

             ;; get total vault & protocol collateral
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-collateral (get vault-collateral vault-balances))
            (vault-protocol-collateral (get vault-protocol-collateral vault-balances))

            ;; calculate amounts from vault and protocol debt tranches
            (new-vault-collateral (if (> remove-amount vault-collateral) u0 (- vault-collateral remove-amount)))
            (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- remove-amount vault-collateral)) vault-protocol-collateral))
        ) 

        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update aggregate debt and collateral
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                collateral-sbtc: (- current-aggregate-sbtc remove-amount)
            })
        )

        ;; update vault
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                collateral-sbtc: new-vault-collateral,
                protocol-collateral-sbtc: new-protocol-collateral,
            })
        )

        (ok true)

    )
)

;; close-vault
(define-public (close-vault (vault-id uint) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
            (borrower (get borrower current-vault))
            (current-aggregate (var-get aggregate-debt-and-collateral))
        )
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))
        ;; delete vault
        (map-delete vault vault-id)

        ;; remove vault from active list
        (try! (contract-call? sorted-vaults remove vault-id))

        ;; remove vault from vaults per principal list
        (map-set vaults-per-principal borrower (get new-list (try! 
            (fold remove-vault-id-from-principal-list 
                (unwrap! (as-max-len? 
                    (default-to (list ) (map-get? vaults-per-principal borrower))

                u50) ERR_LIST_OVERFLOW) (ok {found: false, compare-uint: vault-id, new-list: (list )})))))
    
        (ok true)
    )
)

;; accrue-interest
(define-public (accrue-interest (vault-id uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (current-interest-rate (get interest-rate current-vault))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-borrowed-bsd (get borrowed-bsd current-vault))
            (accrued-interest (unwrap-panic (get-vault-accrued-interest vault-id)))
        )
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update vault with new interest rate
        (map-set vault vault-id (merge 
            current-vault 
            {   borrowed-bsd: (+ current-borrowed-bsd accrued-interest),
                last-interest-accrued: burn-block-height })
        )

        ;; update aggregate debt and collateral
        (ok (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { debt-bsd: (+ (get debt-bsd current-aggregate) accrued-interest) })
        ))
    )
)

;; update-interest-rate
(define-public (update-interest-rate (vault-id uint) (new-interest-rate uint))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (ok (map-set vault vault-id (merge current-vault { future-interest-rate: new-interest-rate })))
    )
)

;; update-rate-delegate
(define-public (update-delegate (vault-id uint) (new-rate-delegate principal))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (ok (map-set vault vault-id (merge current-vault { interest-rate-delegate: new-rate-delegate })))
    )
)

;; update-epoch-rate
(define-public (update-epoch-rate (vault-id uint) (hint (optional uint)) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
            (future-interest-rate (get future-interest-rate current-vault))
            (future-interest-epoch (get future-interest-epoch current-vault))
            (current-epoch (get-current-epoch))
            (next-epoch (+ current-epoch u1))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (if (<= future-interest-epoch current-epoch)
            (begin 
                (map-set vault vault-id (merge current-vault { interest-rate: future-interest-rate, future-interest-epoch: next-epoch }))
                (try! (contract-call? sorted-vaults reinsert vault-id future-interest-rate hint))
                (ok true)
            )

            (ok false)
        )
    )
)

;; add-liquidity
(define-public (add-liquidity (amount uint) (provider principal))
    (let 
        (
            (current-provider (map-get? stability-pool-providers provider))
            (current-stability-pool (var-get stability-pool))
            (current-checkpoint (get current-checkpoint current-stability-pool))
            (current-product (get product current-stability-pool))
            (increased-aggregate-bsd (+ (get aggregate-bsd current-stability-pool) amount))
            (current-aggregate-sbtc (get aggregate-sbtc current-stability-pool))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; Different paths for new provider & existing provider
        (ok (match current-provider
            existing-provider
            (let 
                (
                    (claimable-rewards-checkpoint (unwrap-panic (get checkpoint current-provider)))
                    (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards claimable-rewards-checkpoint))))
                    (calculated-rewards (unwrap-panic (calculate-provider-rewards tx-sender)))
                    (compounded-deposit (unwrap-panic (calculate-compounded-deposit tx-sender)))
                    (decreased-aggregate-sbtc (- current-aggregate-sbtc calculated-rewards))
                )

                ;; Update existing provider map entry
                (map-set stability-pool-providers tx-sender {
                    liquidity-staked: (+ compounded-deposit amount),
                    product_t: current-product,
                    sum_t: current-sum,
                    checkpoint: current-checkpoint,
                })

                ;; Update stability pool aggregate
                (var-set stability-pool 
                {
                    aggregate-bsd: increased-aggregate-bsd,
                    aggregate-sbtc: decreased-aggregate-sbtc,
                    active:  (get active current-stability-pool),
                    product: (get product current-stability-pool),
                    current-checkpoint: current-checkpoint,
                })
            )
            (let 
                (
                    (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards current-checkpoint))))
                )
                ;; Create new provider map entry
                (map-set stability-pool-providers tx-sender {
                    liquidity-staked: amount,
                    product_t: current-product,
                    sum_t: current-sum,
                    checkpoint: current-checkpoint,
                })

                ;; Update stability pool aggregate & add provider to active list
                (var-set stability-pool {
                    aggregate-bsd: increased-aggregate-bsd,
                    aggregate-sbtc: current-aggregate-sbtc,
                    active: (unwrap! (as-max-len? (append (get active current-stability-pool) tx-sender) u1000) ERR_LIST_OVERFLOW),
                    product: (get product current-stability-pool),
                    current-checkpoint: current-checkpoint,
                })
            )
        ))
    )
)

;; remove-liquidity
(define-public (remove-liquidity (amount uint) (provider principal))
    (let 
        (
            (current-provider (unwrap-panic (map-get? stability-pool-providers provider)))
            (current-stability-pool (var-get stability-pool))
            (current-checkpoint (get current-checkpoint current-stability-pool))
            (decreased-aggregate-bsd (- (get aggregate-bsd current-stability-pool) amount))
            (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards current-checkpoint))))
            (current-product (get product current-stability-pool))
            (new-product_t (mul (get product_t current-provider) (get product current-stability-pool)))
            (new-sum_t (+ (get sum_t current-provider) current-sum))
            (calculated-rewards (unwrap-panic (calculate-provider-rewards tx-sender)))
            (compounded-deposit (unwrap-panic (calculate-compounded-deposit tx-sender)))
            (decreased-aggregate-sbtc (- (get aggregate-sbtc current-stability-pool) calculated-rewards))
        )
        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; Update stability pool aggregate
        (var-set stability-pool 
        {
            aggregate-bsd: decreased-aggregate-bsd,
            aggregate-sbtc: decreased-aggregate-sbtc,
            active: (unwrap! (as-max-len? (append (get active current-stability-pool) tx-sender) u1000) ERR_LIST_OVERFLOW),
            product: (get product current-stability-pool),
            current-checkpoint: current-checkpoint,
        })

        (print {
            withdraw-liquidity-event: {
                aggregate-bsd: decreased-aggregate-bsd,
                aggregate-sbtc: decreased-aggregate-sbtc,
                product: current-product,
                sum: current-sum,
                current-checkpoint: current-checkpoint,
                calculated-rewards: calculated-rewards,
                compounded-deposit: compounded-deposit,
                removal-amount: amount,
            }
        })

        ;; check if all liquidity is removed
        (ok (if (is-eq amount (get liquidity-staked current-provider))

            ;; all liquidity & rewards are removed, must delete map & update list
            (begin
                ;; Remove provider map entry
                (map-delete stability-pool-providers provider)

                ;; Remove provider from active list
                (var-set stability-pool (merge {
                    active: (get new-list (try! (fold remove-principal-from-list (get active current-stability-pool) (ok {found: false, compare-principal: provider, new-list: (list )})))),
                } current-stability-pool))
            )

            ;; liquidity remains, update map
            (map-set stability-pool-providers tx-sender {
                liquidity-staked: (- compounded-deposit amount),
                product_t: current-product,
                sum_t: current-sum,
                checkpoint: current-checkpoint,
            })
        ))
    )
)

(define-public (claim-rewards (provider principal))
    (let 
        (
            (current-provider (map-get? stability-pool-providers provider))
            (current-stability-pool (var-get stability-pool))
            (current-checkpoint (get current-checkpoint current-stability-pool))
            (current-product (get product current-stability-pool))
            (current-aggregate-bsd (get aggregate-bsd current-stability-pool))
            (current-aggregate-sbtc (get aggregate-sbtc current-stability-pool))
            (claimable-rewards-checkpoint (unwrap-panic (get checkpoint current-provider)))
            (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards claimable-rewards-checkpoint))))
            (calculated-rewards (unwrap-panic (calculate-provider-rewards tx-sender)))
            (compounded-deposit (unwrap-panic (calculate-compounded-deposit tx-sender)))
            (decreased-aggregate-sbtc (- current-aggregate-sbtc calculated-rewards))
        )

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (if (is-eq compounded-deposit u0)
            (begin 
                ;; Remove provider map entry
                (map-delete stability-pool-providers provider)

                ;; Remove provider from active list
                (ok (var-set stability-pool (merge {
                    active: (get new-list (try! (fold remove-principal-from-list (get active current-stability-pool) (ok {found: false, compare-principal: provider, new-list: (list )})))),
                    aggregate-sbtc: decreased-aggregate-sbtc,
                } current-stability-pool)))
            )
            (begin 
                (map-set stability-pool-providers tx-sender {
                liquidity-staked: compounded-deposit,
                product_t: current-product,
                sum_t: current-sum,
                checkpoint: current-checkpoint,
                })

                ;; Update stability pool aggregate
                (ok (var-set stability-pool 
                {
                    aggregate-bsd: current-aggregate-bsd,
                    aggregate-sbtc: decreased-aggregate-sbtc,
                    active:  (get active current-stability-pool),
                    product: (get product current-stability-pool),
                    current-checkpoint: current-checkpoint,
                }))
            )
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;; registry-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (delete-vault (vault-id uint) (sorted-vaults <sorted-vaults-trait>)) 

    (let 
        (
            (vault-info (unwrap-panic (map-get? vault vault-id)))
            (borrower (get borrower vault-info))
        )

        ;; remove vault from vaults per principal list
        (map-set vaults-per-principal borrower (get new-list (try! 
            (fold remove-vault-id-from-principal-list 
                (unwrap! (as-max-len? 
                    (default-to (list ) (map-get? vaults-per-principal borrower))

                u50) ERR_LIST_OVERFLOW) (ok {found: false, compare-uint: vault-id, new-list: (list )})))))

        ;; remove from sorted vaults
        (try! (contract-call? sorted-vaults remove vault-id))

        ;; delete vault
        (ok (map-delete vault vault-id))
    )
)

;; fully-redeem-vault
(define-private (fully-redeem-vault (vault-id uint) (helper-tuple (response {price: uint, total-redeem-fee: uint, total-bsd-redeemed: uint} uint)))
    (match helper-tuple
        ok-tuple
        (let
            (                 
                ;; move the calculated protocol debt/collateral into storage variables
                (updated-balances (attribute-protocol-balances vault-id))

                ;; aggregate
                (aggregate-balances (var-get aggregate-debt-and-collateral))
                (aggregate-bsd (get debt-bsd aggregate-balances))
                (aggregate-sbtc (get collateral-sbtc aggregate-balances))

                ;; get vault breakdown
                (updated-vault (unwrap-panic (map-get? vault vault-id)))
                (vault-debt (get borrowed-bsd updated-vault))
                (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                (vault-total-debt (+ vault-debt vault-protocol-debt))
                (vault-collateral (get collateral-sbtc updated-vault))
                (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))
                (vault-total-collateral (+ vault-collateral vault-protocol-collateral))

                (redeemed-bsd-in-sbtc ( div-to-fixed-precision vault-total-debt PRECISION (get price ok-tuple)))
                (vault-share ( div-to-fixed-precision vault-total-debt PRECISION (get total-bsd-redeemed ok-tuple)))
                (redeem-fee-credit (mul-to-fixed-precision vault-share PRECISION (get total-redeem-fee ok-tuple)))
                (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
            )

            (print {
                    redeem-vault-event: 
                        {
                            vault-id: vault-id, 
                            redeemed-collateral: redeemed-bsd-in-sbtc,
                            bsd-redeemed: vault-total-debt,
                            redeem-fee-credit: redeem-fee-credit,
                            partial: false,
                            vault-share: vault-share,
                            vault-total-debt: vault-total-debt,
                            vault-total-collateral: vault-total-collateral,
                            aggregate-debt: (get debt-bsd aggregate-balances),
                            aggregate-collateral: (get collateral-sbtc aggregate-balances),
                            total-bsd-redeemed: (get total-bsd-redeemed ok-tuple),
                            sbtc-price: (get price ok-tuple),
                        }
                    }
            )

            ;; Fully redeem the vault
            (map-set vault vault-id
                (merge 
                    updated-vault
                    { 
                        borrowed-bsd: u0,
                        protocol-debt-bsd: u0, 
                        collateral-sbtc: (+ new-vault-collateral redeem-fee-credit),
                        protocol-collateral-sbtc: new-protocol-collateral,
                    }
                )
            )

            (ok {price: (get price ok-tuple), total-redeem-fee: (get total-redeem-fee ok-tuple), total-bsd-redeemed: (get total-bsd-redeemed ok-tuple)})
        )
        err-resp
            (err err-resp)
    )
)

;; get-decay-rate
;; description: Helper function to calculate the decay rate
;; inputs: elapsed-blocks/uint - the number of blocks since the last update
(define-private (get-decay-rate (elapsed-blocks uint))
    (if (> elapsed-blocks (var-get max-hours-decay)) (var-get max-decay) (unwrap-panic (element-at (var-get hourly-decay-rates) elapsed-blocks)))
)

;; Get hours since last redeem
;; 1 block every 10 minutes
;; 6 blocks per hour
(define-private (get-hours-since-last-redeem) 
    (/ (- burn-block-height (var-get last-redeem-height)) (var-get blocks-per-hour))
)

;; Get current epoch
(define-read-only (get-current-epoch) 
    (let 
        (
            (blocks-per-epoch (* (var-get blocks-per-hour) (var-get hours-per-epoch)))  
            (genesis (var-get epoch-genesis))
            (blocks-elapsed (- burn-block-height genesis))
            (current-epoch (/ blocks-elapsed blocks-per-epoch))
        ) 
        current-epoch
    )
)

(define-read-only (get-decayed-base-rate)
   (let (
            (elapsed-hours (get-hours-since-last-redeem))
            (decay-rate (get-decay-rate elapsed-hours))
            (decayed-base-rate (mul-to-fixed-precision decay-rate u8 (var-get base-rate)))
        )
        decayed-base-rate
    )  
)

(define-private (get-full-and-partial-redemption-vaults (redeem-vaults (list 65000 uint)) (redeem-amount uint))     
    (let 
        (
            (first-vault (unwrap! (map-get? vault (unwrap! (element-at? redeem-vaults u0) (err u0))) (err u0)))
            (first-vault-bsd (get borrowed-bsd first-vault))
            (is-single-partial 
                (if 
                    (is-eq (len redeem-vaults) u1) 
                        ;; true condition
                        (if 
                            (< 
                                redeem-amount 
                                first-vault-bsd
                            )
                            true
                            false
                        ) 
                        false
                )
            )
            (is-single-full (if 
                                (and (is-eq is-single-partial false) (is-eq (len redeem-vaults) u1))
                                true
                                false
                            )
            )
            (fully-redeem-vaults (if 
                                    is-single-full 
                                    redeem-vaults
                                    (if 
                                        is-single-partial
                                        (unwrap! (slice? redeem-vaults u0 u0) (err u0)) ;; empty list
                                        (unwrap! (slice? redeem-vaults u0 (- (len redeem-vaults) u1)) (err u0))
                                    )
                                )
            )
            (partially-redeem-vault (if 
                                        is-single-partial 
                                        first-vault 
                                        (unwrap! (map-get? vault (unwrap! (element-at? redeem-vaults (unwrap! (element-at? redeem-vaults (- (len redeem-vaults) u1)) (err u0))) (err u0))) (err u0))
                                    )
            )
        ) 
        (ok true) 
    )
)  

(define-read-only (calculate-provider-rewards (provider principal))
    (let 
        (
            (current-stability-pool (var-get stability-pool))
            (stability-pool-bsd (get aggregate-bsd current-stability-pool)) 
            (current-provider (unwrap! (map-get? stability-pool-providers provider) ERR_PROVIDER_NOT_FOUND))
            (claimable-rewards-checkpoint (get checkpoint current-provider))
            (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards claimable-rewards-checkpoint))))
            (current-provider-bsd (get liquidity-staked current-provider))
            (current-provider-sum (get sum_t current-provider))
            (current-provider-product (get product_t current-provider))
            (new-sum (- current-sum current-provider-sum))
            ;; remove u1 from sum to ensure solvency
            (calculated-rewards (div (mul current-provider-bsd (if (is-eq new-sum u0) u0 (- new-sum u1))) current-provider-product))
        ) 
        (ok calculated-rewards)
    )
)

(define-public (calculate-compounded-deposit (provider principal))
    (let 
        (
            (current-stability-pool (var-get stability-pool))
            (stability-pool-checkpoint (get current-checkpoint current-stability-pool))
            (current-product (get product current-stability-pool))
            (current-provider (unwrap! (map-get? stability-pool-providers provider) ERR_PROVIDER_NOT_FOUND))
            (provider-rewards-checkpoint (get checkpoint current-provider))
            (current-provider-bsd (get liquidity-staked current-provider))
            (current-provider-product (get product_t current-provider))
            (calculated-deposit (div (mul current-provider-bsd current-product) current-provider-product))
            (current-deposit (if (< provider-rewards-checkpoint stability-pool-checkpoint) u0 calculated-deposit))
        ) 
        (ok current-deposit)
    )
)

;; remove-uint-from-list
;; description: helper function for removing any uint (such as a vault id) from a list
(define-private (remove-uint-from-list (list-uint uint) (helper-tuple-response (response {found: bool, compare-uint: uint, new-list: (list 10000 uint)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-uint (get compare-uint helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )

                ;; check if uint was found
                (if (is-eq current-found true)
                    ;; uint was found & skipped, continue appending existing list-uint to new-list
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-uint) u10000) ERR_LIST_OVERFLOW)}
                    ))
                    ;; uint was not found, continue searching for compare-uint
                    (if (is-eq current-compare-uint list-uint)
                        ;; uint was found, skip appending to new-list
                        (ok (merge 
                            helper-tuple
                            {found: true}
                        ))
                        ;; uint was not found, append to new-list
                        (ok (merge 
                            helper-tuple
                            {new-list: (unwrap! (as-max-len? (append current-new-list list-uint) u10000) ERR_LIST_OVERFLOW)}
                        ))
                    )
                )
            )
        err-resp
            (err err-resp)
    )
)

;; remove-uint-from-list
;; description: helper function for removing any uint (such as a vault id) from a list
(define-private (remove-vault-id-from-principal-list (list-uint uint) (helper-tuple-response (response {found: bool, compare-uint: uint, new-list: (list 50 uint)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-uint (get compare-uint helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )

                ;; check if uint was found
                (if (is-eq current-found true)
                    ;; uint was found & skipped, continue appending existing list-uint to new-list
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-uint) u50) ERR_LIST_OVERFLOW)}
                    ))
                    ;; uint was not found, continue searching for compare-uint
                    (if (is-eq current-compare-uint list-uint)
                        ;; uint was found, skip appending to new-list
                        (ok (merge 
                            helper-tuple
                            {found: true}
                        ))
                        ;; uint was not found, append to new-list
                        (ok (merge 
                            helper-tuple
                            {new-list: (unwrap! (as-max-len? (append current-new-list list-uint) u50) ERR_LIST_OVERFLOW)}
                        ))
                    )
                )
            )
        err-resp
            (err err-resp)
    )
)


;; remove-principal-from-list
;; description: helper function for removing any principal from a list
(define-private (remove-principal-from-list (list-principal principal) (helper-tuple-response (response {found: bool, compare-principal: principal, new-list: (list 1000 principal)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-principal (get compare-principal helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )
                ;; check if principal was found
                (if current-found
                    ;; principal was found & skipped, continue appending existing list-principal to new-list
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u1000) ERR_LIST_OVERFLOW)}
                    ))
                    ;; principal was not found, continue searching for compare-principal
                    (if (is-eq list-principal current-compare-principal)
                        ;; principal was found, skip appending to new-list & set found to true
                        (ok (merge 
                            helper-tuple
                            {found: true, new-list: current-new-list}
                        ))
                        ;; principal was not found, continue appending existing list-principal to new-list
                        (ok (merge 
                            helper-tuple
                            {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u1000) ERR_LIST_OVERFLOW)}
                        ))
                    )
                )
            )
        err-response
            ERR_LIST_OVERFLOW
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sort/insert helper functions related list operations END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (attribute-protocol-balances (vault-id uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (vault-debt (get borrowed-bsd current-vault))
            (vault-collateral (get collateral-sbtc current-vault))
            (protocol-debt (get protocol-debt-bsd current-vault))
            (protocol-collateral (get protocol-collateral-sbtc current-vault))

            (aggregate-balances (var-get aggregate-debt-and-collateral))
            (aggregate-debt (get debt-bsd aggregate-balances))
            (aggregate-collateral (get collateral-sbtc aggregate-balances))

            (calc-protocol-share (unwrap-panic (get-vault-protocol-shares vault-id)))
            (calc-protocol-debt-add (get calculated-protocol-debt calc-protocol-share))
            (calc-protocol-collateral-add (get calculated-protocol-collateral calc-protocol-share))

            (global-redistribution-params (var-get protocol-redistribution-params))
            (new-protocol-sum-collateral (get current-sum-collateral-sbtc global-redistribution-params))
           
            ;; derived values
            (new-protocol-debt (+ protocol-debt calc-protocol-debt-add))
            (new-protocol-collateral (+ protocol-collateral calc-protocol-collateral-add))
        )

        (map-set vault vault-id 
                (merge 
                    current-vault
                    { 
                        protocol-debt-bsd: new-protocol-debt,
                        protocol-collateral-sbtc: new-protocol-collateral,
                        protocol-sum-collateral-sbtc: new-protocol-sum-collateral,
                    }
                )
        )
    )
)

(define-public (unwind-vault (vault-id uint) (sbtc-price uint) (sorted-vaults <sorted-vaults-trait>)) 
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (borrower (get borrower current-vault))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-total-collateral (get vault-total-collateral vault-balances))
        )
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; update aggregate sbtc collateral
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { collateral-sbtc: (- (get collateral-sbtc current-aggregate) vault-total-collateral) })
        )

        (ok (try! (delete-vault vault-id sorted-vaults)))
    )
)

(define-public (unwind-provider (provider principal)) 
    (let 
        (
            (current-stability-pool (var-get stability-pool))
            (aggregate-sbtc (get aggregate-sbtc current-stability-pool))
            (rewards (unwrap-panic (calculate-provider-rewards provider)))
            (decreased-aggregate-sbtc (- aggregate-sbtc rewards))
        )
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; Remove provider map entry
        (map-delete stability-pool-providers provider)

        ;; Remove provider from active list
        (ok (var-set stability-pool 
                {
                    active: (get new-list (try! (fold remove-principal-from-list (get active current-stability-pool) (ok {found: false, compare-principal: provider, new-list: (list )})))),
                    aggregate-sbtc: decreased-aggregate-sbtc,
                    aggregate-bsd: (get aggregate-bsd current-stability-pool), 
                    product: (get product current-stability-pool), 
                    current-checkpoint: (get current-checkpoint current-stability-pool)
                }
            )
        )
    )
)

;; liquidate-vault
(define-public (liquidation-update-provider-distribution (vault-id uint) (liquidated-stability-bsd uint) (liquidated-stability-sbtc uint) (delete bool) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (total-bsd (get debt-bsd (var-get aggregate-debt-and-collateral)))
            (total-sbtc (get collateral-sbtc (var-get aggregate-debt-and-collateral)))
                        
            ;; provider
            (current-stability-pool (var-get stability-pool))
            (current-stability-pool-bsd (get aggregate-bsd current-stability-pool))
            (current-stability-pool-sbtc (get aggregate-sbtc current-stability-pool))
            
            (stored-checkpoint (get current-checkpoint current-stability-pool))
            (stored-sum (get sum (unwrap-panic (map-get? checkpoint-rewards stored-checkpoint))))
            
            (calc-stability-product (mul (get product current-stability-pool) (- ONE_FULL_UNIT (div liquidated-stability-bsd current-stability-pool-bsd))))
            (calc-stability-sum (+ stored-sum (mul (div liquidated-stability-sbtc current-stability-pool-bsd) (get product current-stability-pool))))       

            (current-sum calc-stability-sum)
            (current-product (if (is-eq calc-stability-product u0) ONE_FULL_UNIT calc-stability-product))
            (current-checkpoint (if (is-eq calc-stability-product u0) (+ stored-checkpoint u1) stored-checkpoint))
        )
        
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (if (is-eq calc-stability-product u0)
            ;; set historical rewards data and insert a new reset checkpoint
            (begin 
                (map-set checkpoint-rewards stored-checkpoint {checkpoint: stored-checkpoint, sum: current-sum})
                (map-set checkpoint-rewards current-checkpoint {checkpoint: current-checkpoint, sum: current-sum})
            )
            ;; update the current sum for current checkpoint
            (map-set checkpoint-rewards current-checkpoint {checkpoint: current-checkpoint, sum: current-sum})
        )

        ;; update aggregate debt and collateral
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: (- total-bsd liquidated-stability-bsd),
                collateral-sbtc: (- total-sbtc liquidated-stability-sbtc) 
            })
        )
       
        ;; update stability pool
        (var-set stability-pool (merge 
            current-stability-pool 
            { 
                aggregate-bsd: (- current-stability-pool-bsd liquidated-stability-bsd),
                aggregate-sbtc: (+ current-stability-pool-sbtc liquidated-stability-sbtc),
                product: current-product,
                current-checkpoint: current-checkpoint, 
            }
        ))

        (if (is-eq delete true)
            (close-vault vault-id sorted-vaults)
            (ok true)
        )
    )
)

;; liquidate-vault
(define-public (liquidation-update-vault-redistribution (vault-id uint) (liquidated-redistribution-bsd uint) (liquidated-redistribution-sbtc uint) (delete bool) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (vault-debt (get borrowed-bsd current-vault))
            (vault-collateral (get collateral-sbtc current-vault))
            (total-bsd (get debt-bsd (var-get aggregate-debt-and-collateral)))
            (total-sbtc (get collateral-sbtc (var-get aggregate-debt-and-collateral)))         
            
            ;; redistribution
            (redistribution-params (var-get protocol-redistribution-params))
            (current-sum-collateral-sbtc (get current-sum-collateral-sbtc redistribution-params))
            (current-protocol-debt-bsd (get aggregate-protocol-debt-bsd redistribution-params))
            (current-protocol-collateral-sbtc (get aggregate-protocol-collateral-sbtc redistribution-params))
            (calculated-sum-collateral-sbtc (+ current-sum-collateral-sbtc (div-round-down liquidated-redistribution-sbtc (- total-sbtc liquidated-redistribution-sbtc))))
            (calculated-protocol-debt-bsd (+ current-protocol-debt-bsd liquidated-redistribution-bsd))
            (calculated-protocol-collateral-sbtc (+ current-protocol-collateral-sbtc liquidated-redistribution-sbtc))
        )
        ;; check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        (print {
            redistribution-event: 
                {
                    vault-id: vault-id, 
                    redistribution-amount-bsd: liquidated-redistribution-bsd, 
                    redistribution-amount-sbtc: liquidated-redistribution-sbtc,
                    aggregate-bsd: total-bsd,
                }
            }
        )

        ;; update protocol debt and collateral params
        (var-set protocol-redistribution-params 
            (merge 
                (var-get protocol-redistribution-params) 
                {
                    aggregate-protocol-debt-bsd: calculated-protocol-debt-bsd,
                    aggregate-protocol-collateral-sbtc: calculated-protocol-collateral-sbtc,
                    current-sum-collateral-sbtc: calculated-sum-collateral-sbtc,
                }
            )
        )

        (if (is-eq delete true)
            (close-vault vault-id sorted-vaults)
            (ok true)
        )
    )
)

;; update-redemptions
(define-public (update-redemptions (vaults (list 65000 uint)) (total-bsd-redeemed uint) (total-sbtc-transferred uint) (partial-bsd-redeemed uint) (new-base-rate uint) (total-redeem-fee uint) (bsd-to-sbtc-price uint))
    (let 
        (
            (vaults-len (len vaults))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-bsd-debt (get debt-bsd current-aggregate))
            (decreased-aggregate-bsd-debt (- current-aggregate-bsd-debt total-bsd-redeemed))
            (current-aggregate-sbtc-collateral (get collateral-sbtc current-aggregate))
            (decreased-aggregate-sbtc-collateral (- current-aggregate-sbtc-collateral total-sbtc-transferred))
        )

        (print {
            redemption-event: 
                {
                    vaults: vaults,
                    total-bsd-redeemed: total-bsd-redeemed,
                    total-sbtc-transferred: total-sbtc-transferred,
                    partial-bsd-redeemed: partial-bsd-redeemed,
                    new-base-rate: new-base-rate,
                    total-redeem-fee: total-redeem-fee,
                    sbtc-price: bsd-to-sbtc-price,
                }
            
        })

        ;; Check that caller is protocol-caller
        (try! (contract-call? .controller-vpv-5 is-protocol-caller contract-caller))

        ;; remove redeemed bsd and sbtc from aggregate
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: decreased-aggregate-bsd-debt,
                collateral-sbtc: decreased-aggregate-sbtc-collateral 
            })
        )

        ;; Check if redemption only requires one vault
        (if (is-eq vaults-len u1)
            ;; One vault
            (let
                (
                    (vault-id (unwrap-panic (element-at? vaults u0)))
                    (current-vault (unwrap-panic (map-get? vault vault-id)))
                    (current-vault-debt (get borrowed-bsd current-vault))
                    (current-vault-collateral (get collateral-sbtc current-vault))
                    ;; move the calculated protocol debt/collateral into storage variables
                    (updated-balances (attribute-protocol-balances vault-id))

                    ;; get vault breakdown
                    (updated-vault (unwrap-panic (map-get? vault vault-id)))
                    (vault-debt (get borrowed-bsd updated-vault))
                    (vault-collateral (get collateral-sbtc updated-vault))
                    (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))

                    ;; calculate new vault balances by tranche
                    ;; if redeemed bsd amount > than vault debt, then zero out vault debt and continue on to protocol-debt
                    (redeemed-bsd-in-sbtc ( div-to-fixed-precision partial-bsd-redeemed PRECISION bsd-to-sbtc-price))
                    (new-vault-debt (if (> partial-bsd-redeemed vault-debt) u0 (- vault-debt partial-bsd-redeemed)))
                    (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- partial-bsd-redeemed vault-debt)) vault-protocol-debt))
                    (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                    (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
                )

                (print {
                        redeem-vault-event: 
                            {
                                vault-id: vault-id, 
                                redeemed-collateral: redeemed-bsd-in-sbtc,
                                bsd-redeemed: partial-bsd-redeemed,
                                redeem-fee-credit: total-redeem-fee, ;; All of the redeem fee since it is a single vault
                                sbtc-price: bsd-to-sbtc-price,
                            }
                        }
                )

                ;; Whether it's partial or fully redeemed, update vault map
                (map-set vault vault-id
                    (merge 
                        current-vault
                        { 
                            borrowed-bsd: new-vault-debt,
                            protocol-debt-bsd: new-protocol-debt,
                            collateral-sbtc: (+ new-vault-collateral total-redeem-fee),
                            protocol-collateral-sbtc: new-protocol-collateral
                        }
                    )
                )
            )   
            ;; Multiple vaults
            (let 
                (
                    ;; all of the vaults below are fully redeemed
                    (fully-redeemed-vaults (unwrap! (slice? vaults u0 (- (len vaults) u1)) ERR_SLICE))

                    ;; partial redemption info
                    (vault-id (unwrap-panic (element-at? vaults (- (len vaults) u1))))
                    (current-vault (unwrap-panic (map-get? vault vault-id)))
                    (current-vault-debt (get borrowed-bsd current-vault))
                    (current-vault-collateral (get collateral-sbtc current-vault))
                    (redeemed-bsd-in-sbtc ( div-to-fixed-precision partial-bsd-redeemed PRECISION bsd-to-sbtc-price))
                    (vault-share ( div-to-fixed-precision partial-bsd-redeemed PRECISION total-bsd-redeemed))
                    (redeem-fee-credit (mul-to-fixed-precision vault-share PRECISION total-redeem-fee))
                    
                    ;; move the calculated protocol debt/collateral into storage variables
                    (updated-balances (attribute-protocol-balances vault-id))

                    ;; get vault breakdown
                    (updated-vault (unwrap-panic (map-get? vault vault-id)))
                    (vault-debt (get borrowed-bsd updated-vault))
                    (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                    (vault-collateral (get collateral-sbtc updated-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))

                    ;; calculate new vault balances by tranche
                    ;; if redeemed bsd amount > than vault debt, then zero out vault debt and continue on to protocol-debt
                    (new-vault-debt (if (> partial-bsd-redeemed vault-debt) u0 (- vault-debt partial-bsd-redeemed)))
                    (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- partial-bsd-redeemed vault-debt)) vault-protocol-debt))
                    (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                    (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
                )

                ;; Update partially redeemed vault
                (map-set vault vault-id
                    (merge 
                        updated-vault
                        { 
                            borrowed-bsd: new-vault-debt,
                            protocol-debt-bsd: new-protocol-debt,
                            collateral-sbtc: (+ new-vault-collateral redeem-fee-credit),
                            protocol-collateral-sbtc: new-protocol-collateral 
                        }
                    )
                )

                (print {
                        redeem-vault-event: 
                            {
                                vault-id: vault-id, 
                                redeemed-collateral: redeemed-bsd-in-sbtc,
                                bsd-redeemed: partial-bsd-redeemed,
                                redeem-fee-credit: redeem-fee-credit,
                                sbtc-price: bsd-to-sbtc-price,
                            }
                        }
                )

                ;; Update all fully redeemed vaults
                (try! (fold fully-redeem-vault fully-redeemed-vaults (ok {price: bsd-to-sbtc-price, total-redeem-fee: total-redeem-fee, total-bsd-redeemed: total-bsd-redeemed})))
                true
            )
        )

        ;; Update last base rate
        (var-set last-redeem-height burn-block-height)

        ;; Update base rate
        (ok (var-set base-rate new-base-rate))
    )
)

(define-public (get-redemption-batch-info (sbtc-price uint) (sorted-vaults <sorted-vaults-trait>)) 
    (let 
        (
            (sorted-vaults-summary (unwrap-panic (contract-call? sorted-vaults get-vaults-summary)))
            (sorted-vaults-count (get total-vaults sorted-vaults-summary))
            (max-vault-count (var-get max-vaults-to-redeem))
            (vault-count (if (< sorted-vaults-count max-vault-count) sorted-vaults-count max-vault-count))
        )
        (if (is-eq vault-count u0)
            (ok {vaults: (list ), total-redeem-value: u0})
            ;; Get first vault
            (let 
                (
                    (sorted-vault-1-id (unwrap-panic (get first-vault-id sorted-vaults-summary)))
                    (vault-1-info (unwrap-panic (get-vault-compounded-info sorted-vault-1-id sbtc-price)))
                    (vault-1-bsd (get vault-total-debt vault-1-info))
                )
                    (if (is-eq vault-count u1)
                        (ok {vaults: (list sorted-vault-1-id), total-redeem-value: vault-1-bsd})
                        ;; Get second vault
                        (let 
                            (
                                (sorted-vault-2-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-1-id)))))
                                (vault-2-info (unwrap-panic (get-vault-compounded-info sorted-vault-2-id sbtc-price)))
                                (vault-2-bsd (get vault-total-debt vault-2-info))
                            )
                            (if (is-eq vault-count u2) 
                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd)})
                                ;; Get third vault
                                (let 
                                    (
                                        (sorted-vault-3-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-2-id)))))
                                        (vault-3-info (unwrap-panic (get-vault-compounded-info sorted-vault-3-id sbtc-price)))
                                        (vault-3-bsd (get vault-total-debt vault-3-info))
                                    )
                                    (if (is-eq vault-count u3) 
                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd)})
                                        ;; Get fourth vault
                                        (let 
                                            (
                                                (sorted-vault-4-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-3-id)))))
                                                (vault-4-info (unwrap-panic (get-vault-compounded-info sorted-vault-4-id sbtc-price)))
                                                (vault-4-bsd (get vault-total-debt vault-4-info))
                                            )
                                            (if (is-eq vault-count u4) 
                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd)})
                                                ;; Get fifth vault
                                                (let 
                                                    (
                                                        (sorted-vault-5-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-4-id)))))
                                                        (vault-5-info (unwrap-panic (get-vault-compounded-info sorted-vault-5-id sbtc-price)))
                                                        (vault-5-bsd (get vault-total-debt vault-5-info))
                                                    )
                                                    (if (is-eq vault-count u5) 
                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd)})
                                                        ;; Get sixth vault
                                                        (let 
                                                            (
                                                                (sorted-vault-6-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-5-id)))))
                                                                (vault-6-info (unwrap-panic (get-vault-compounded-info sorted-vault-6-id sbtc-price)))
                                                                (vault-6-bsd (get vault-total-debt vault-6-info))
                                                            )
                                                            (if (is-eq vault-count u6) 
                                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd)})
                                                                ;; Get seventh vault
                                                                (let 
                                                                    (
                                                                        (sorted-vault-7-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-6-id)))))
                                                                        (vault-7-info (unwrap-panic (get-vault-compounded-info sorted-vault-7-id sbtc-price)))
                                                                        (vault-7-bsd (get vault-total-debt vault-7-info))
                                                                    )
                                                                    (if (is-eq vault-count u7) 
                                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd)})
                                                                        ;; Get eighth vault
                                                                        (let 
                                                                            (
                                                                                (sorted-vault-8-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-7-id)))))
                                                                                (vault-8-info (unwrap-panic (get-vault-compounded-info sorted-vault-8-id sbtc-price)))
                                                                                (vault-8-bsd (get vault-total-debt vault-8-info))
                                                                            )
                                                                            (if (is-eq vault-count u8)
                                                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id sorted-vault-8-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd vault-8-bsd)})
                                                                                ;; Get ninth vault
                                                                                (let 
                                                                                    (
                                                                                        (sorted-vault-9-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-8-id)))))
                                                                                        (vault-9-info (unwrap-panic (get-vault-compounded-info sorted-vault-9-id sbtc-price)))
                                                                                        (vault-9-bsd (get vault-total-debt vault-9-info))
                                                                                    )
                                                                                    (if (is-eq vault-count u9) 
                                                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id sorted-vault-8-id sorted-vault-9-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd vault-8-bsd vault-9-bsd)})
                                                                                        ;; Get tenth vault
                                                                                        (let 
                                                                                            (
                                                                                                (sorted-vault-10-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-9-id)))))
                                                                                                (vault-10-info (unwrap-panic (get-vault-compounded-info sorted-vault-10-id sbtc-price)))
                                                                                                (vault-10-bsd (get vault-total-debt vault-10-info))
                                                                                            )
                                                                                            (if (is-eq vault-count u10) 
                                                                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id sorted-vault-8-id sorted-vault-9-id sorted-vault-10-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd vault-8-bsd vault-9-bsd vault-10-bsd)})
                                                                                                (ok {vaults: (list ), total-redeem-value: u0})                                               
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                            )                                            
                                        )
                                    )
                                )
                            )
                        )
                    )
            )
        )
    )
)

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y))

(define-read-only (div-round-down (x uint) (y uint))
  (- (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y) u1)  
)

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (div (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (div (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ ONE_FULL_UNIT u2)) ONE_FULL_UNIT))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (mul (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (mul (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

;; multiply a number of arbitrary precision with a 8-decimals fixed number
;; convert back to unit of arbitrary precision
(define-read-only (mul-perc (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (begin
      (*
        (mul (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
        (pow u10 (- decimals-a PRECISION))
      )
    )
    (begin
      (/
        (mul (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
        (pow u10 (- PRECISION decimals-a))
      )
    )
  )
)