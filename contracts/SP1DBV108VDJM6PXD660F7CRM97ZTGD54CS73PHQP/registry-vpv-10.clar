

(impl-trait .registry-trait-vpv-10.registry-trait)

(use-trait sorted-vaults-trait .sorted-vaults-trait-vpv-10.sorted-vaults-trait)

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
(define-constant ERR_REDEEM_UNHEALTHY (err u222))
(define-constant ERR_STAKES (err u223))
(define-constant contract-deployer tx-sender)
(define-constant PROTOCOL_STATE_NORMAL u0)
(define-constant PROTOCOL_STATE_PAUSED u1)
(define-constant PROTOCOL_STATE_MAINTENANCE u2)
(define-constant half-day u72)
(define-constant full-day (* half-day u2))
(define-constant year (* full-day u365))
(define-constant PRECISION u8)
(define-constant ONE_FULL_UNIT u100000000)
;; (define-constant MIN_TIMELOCK_DELAY full-day)
(define-constant MIN_TIMELOCK_DELAY u1)

(define-data-var vault-collateral-ratio-threshold uint u110000000) 
(define-data-var vault-recovery-ratio-threshold uint u150000000) 
(define-data-var global-collateral-ratio-threshold uint u125000000) 
(define-data-var alpha uint (/ ONE_FULL_UNIT u2))
(define-data-var delta uint u94000000)
(define-data-var block-decay-rates (list 500 uint) (list u100000000 u98974042 u97958611 u96953597 u95958894 u94974397 u94000000 u93035600 u92081094 u91136381 u90201361 u89275933 u88360000 u87453464 u86556229 u85668198 u84789279 u83919377 u83058400 u82206256 u81362855 u80528107 u79701922 u78884215 u78074896 u77273881 u76481084 u75696420 u74919807 u74151162 u73390402 u72637448 u71892219 u71154635 u70424619 u69702092 u68986978 u68279201 u67578685 u66885357 u66199141 u65519966 u64847759 u64182449 u63523964 u62872235 u62227193 u61588768 u60956894 u60331502 u59712526 u59099901 u58493561 u57893442 u57299480 u56711612 u56129775 u55553907 u54983948 u54419836 u53861511 u53308915 u52761988 u52220673 u51684911 u51154646 u50629821 u50110380 u49596269 u49087432 u48583816 u48085367 u47592031 u47103757 u46620493 u46142186 u45668787 u45200245 u44736510 u44277532 u43823263 u43373655 u42928660 u42488230 u42052319 u41620880 u41193868 u40771236 u40352940 u39938936 u39529180 u39123627 u38722235 u38324962 u37931764 u37542600 u37157429 u36776210 u36398901 u36025464 u35655858 u35290044 u34927983 u34569637 u34214967 u33863936 u33516507 u33172642 u32832304 u32495459 u32162069 u31832100 u31505516 u31182283 u30862366 u30545731 u30232345 u29922174 u29615185 u29311346 u29010624 u28712987 u28418404 u28126844 u27838274 u27552665 u27269987 u26990208 u26713300 u26439233 u26167978 u25899505 u25633787 u25370796 u25110502 u24852879 u24597899 u24345535 u24095760 u23848548 u23603872 u23361706 u23122025 u22884803 u22650015 u22417635 u22187640 u21960004 u21734704 u21511715 u21291014 u21072577 u20856381 u20642404 u20430621 u20221012 u20013553 u19808222 u19604998 u19403859 u19204784 u19007751 u18812740 u18619729 u18428699 u18239628 u18052497 u17867286 u17683975 u17502545 u17322977 u17145250 u16969347 u16795249 u16622937 u16452393 u16283598 u16116535 u15951186 u15787534 u15625561 u15465249 u15306582 u15149543 u14994115 u14840282 u14688027 u14537334 u14388187 u14240571 u14094468 u13949865 u13806745 u13665094 u13524896 u13386136 u13248800 u13112873 u12978341 u12845188 u12713402 u12582968 u12453872 u12326101 u12199640 u12074477 u11950598 u11827990 u11706640 u11586535 u11467662 u11350008 u11233562 u11118311 u11004241 u10891343 u10779602 u10669008 u10559548 u10451212 u10343987 u10237862 u10132826 u10028867 u9925976 u9824139 u9723348 u9623590 u9524856 u9427135 u9330417 u9234691 u9139947 u9046175 u8953365 u8861507 u8770592 u8680609 u8591550 u8503404 u8416163 u8329817 u8244356 u8159773 u8076057 u7993200 u7911193 u7830028 u7749695 u7670187 u7591494 u7513608 u7436522 u7360226 u7284713 u7209975 u7136004 u7062792 u6990330 u6918613 u6847631 u6777377 u6707844 u6639024 u6570911 u6503496 u6436773 u6370734 u6305373 u6240683 u6176656 u6113286 u6050566 u5988490 u5927051 u5866242 u5806057 u5746489 u5687532 u5629181 u5571428 u5514267 u5457693 u5401700 u5346280 u5291430 u5237142 u5183411 u5130232 u5077598 u5025504 u4973944 u4922914 u4872407 u4822418 u4772942 u4723973 u4675507 u4627539 u4580062 u4533073 u4486565 u4440535 u4394977 u4349886 u4305258 u4261088 u4217371 u4174103 u4131278 u4088893 u4046943 u4005423 u3964329 u3923657 u3883402 u3843560 u3804126 u3765098 u3726469 u3688237 u3650398 u3612946 u3575879 u3539192 u3502881 u3466943 u3431374 u3396169 u3361326 u3326840 u3292708 u3258927 u3225491 u3192399 u3159646 u3127230 u3095146 u3063391 u3031962 u3000855 u2970068 u2939596 u2909437 u2879587 u2850044 u2820804 u2791864 u2763220 u2734871 u2706812 u2679041 u2651556 u2624352 u2597427 u2570779 u2544403 u2518299 u2492462 u2466891 u2441581 u2416532 u2391739 u2367201 u2342915 u2318877 u2295087 u2271540 u2248235 u2225169 u2202340 u2179745 u2157381 u2135248 u2113341 u2091659 u2070199 u2048960 u2027938 u2007133 u1986540 u1966159 u1945987 u1926022 u1906262 u1886705 u1867348 u1848190 u1829228 u1810461 u1791886 u1773502 u1755307 u1737298 u1719474 u1701833 u1684373 u1667092 u1649989 u1633060 u1616306 u1599723 u1583311 u1567067 u1550989 u1535077 u1519328 u1503740 u1488312 u1473043 u1457930 u1442972 u1428168 u1413516 u1399013 u1384660 u1370454 u1356394 u1342478 u1328705 u1315073 u1301581 u1288227 u1275010 u1261929 u1248982 u1236168 u1223486 u1210933 u1198510 u1186213 u1174043 u1161998))
(define-data-var max-hours-decay uint u72)
(define-data-var max-blocks-decay uint (* (var-get blocks-per-hour) (var-get max-hours-decay)))
(define-data-var max-decay uint u1161998)
(define-data-var blocks-per-hour uint u6)
;; (define-data-var hours-per-epoch uint u168)
(define-data-var hours-per-epoch uint u1) ;; update
(define-data-var min-borrow-fee uint (/ ONE_FULL_UNIT u200)) 
(define-data-var max-borrow-fee uint (/ ONE_FULL_UNIT u20)) 
(define-data-var min-redeem-fee uint (/ ONE_FULL_UNIT u200)) 
(define-data-var max-redeem-fee uint ONE_FULL_UNIT) 
;; (define-data-var timelock-delay uint (* u2 full-day))
(define-data-var timelock-delay uint u2) ;; update
(define-data-var min-redeem-amount uint (* u100 ONE_FULL_UNIT))
(define-data-var vault-loan-minimum uint (* u1000 ONE_FULL_UNIT))
(define-data-var vault-interest-minimum uint (/ ONE_FULL_UNIT u100))
(define-data-var vault-interest-maximum uint ONE_FULL_UNIT)
(define-data-var global-collateral-cap uint (* u2000000 ONE_FULL_UNIT))
(define-data-var protocol-fee-destination principal 'SP2MNRMNPCP1N5C6QQAKN0FDQK8G693F2VBZ2W1N7) ;; update
(define-data-var min-stability-provider-balance uint (* u1000 ONE_FULL_UNIT))
(define-data-var epoch-genesis uint burn-block-height)
(define-data-var oracle-stale-threshold-seconds uint u180) ;; 3 minutes
(define-data-var oracle-allowable-price-deviation uint u500000) ;; 5% allowable price deviation
(define-data-var max-vaults-to-redeem uint u10)

(define-data-var protocol-redistribution-params 
    { 
        total-stakes: uint,
        total-stakes-snapshot: uint,
        total-collateral-snapshot: uint,
        total-sbtc-rewards-per-unit: uint,
        total-bsd-rewards-per-unit: uint
    } 
    { 
        total-stakes: u0,
        total-stakes-snapshot: u0,
        total-collateral-snapshot: u0,
        total-sbtc-rewards-per-unit: u0,
        total-bsd-rewards-per-unit: u0
    }
)


(define-data-var aggregate-debt-and-collateral {debt-bsd: uint, collateral-sbtc: uint} {debt-bsd: u0, collateral-sbtc: u0})
(define-data-var protocol-state uint PROTOCOL_STATE_NORMAL)
(define-data-var created-vaults uint u0)
(define-data-var base-rate uint u0)
(define-data-var last-redeem-height uint u0)

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

(define-data-var last-processed-epoch uint u0)

(define-map vault uint {
    borrower: principal,
    created-height: uint,
    
    borrowed-bsd: uint,
    
    collateral-sbtc: uint,
    
    protocol-debt-bsd: uint,
    
    protocol-collateral-sbtc: uint,
    
    interest-rate: uint,
    
    last-interest-accrued: uint,
    
    future-interest-rate: uint,
    
    future-interest-epoch: uint,
    
    interest-rate-delegate: principal,

    
    stake: uint,
    vault-sbtc-rewards-snapshot: uint,
    vault-bsd-rewards-snapshot: uint,
})

(define-map vaults-per-principal principal (list 50 uint))

(define-map stability-pool-providers principal {
    liquidity-staked: uint,
    sum_t: uint,
    product_t: uint,
    checkpoint: uint,
}) 

(define-map checkpoint-rewards uint {
    checkpoint: uint,
    sum: uint,
})
(map-set checkpoint-rewards u0 {checkpoint: u0, sum: u0})

(define-read-only (get-checkpoint-sum (checkpoint uint))
    (ok (map-get? checkpoint-rewards checkpoint))
)

(define-read-only (get-is-paused)
    (ok (is-eq PROTOCOL_STATE_PAUSED (var-get protocol-state)))
)

(define-read-only (get-is-maintenance)
    (ok (is-eq PROTOCOL_STATE_MAINTENANCE (var-get protocol-state)))
)

(define-read-only (get-protocol-fee-destination)
    (ok (var-get protocol-fee-destination))
)

(define-read-only (get-stability-pool-data)
    (ok (var-get stability-pool))
)

(define-read-only (get-decay-rates)
    (ok (var-get block-decay-rates))
)

(define-read-only (get-stability-pool-provider (principal principal))
    (ok (map-get? stability-pool-providers principal))
)

(define-read-only (get-provider-calculated-balance (principal principal))
    (ok (unwrap! (calculate-compounded-deposit principal) ERR_PROVIDER_NOT_FOUND))
)

(define-public (get-active-vaults (sorted-vaults <sorted-vaults-trait>))
    (ok (get total-vaults (unwrap-panic (contract-call? sorted-vaults get-vaults-summary))))
)

(define-read-only (get-aggregate-debt-and-collateral)
    (ok (var-get aggregate-debt-and-collateral))
)

(define-read-only (get-vaults-by-principal (principal principal))
    (ok (map-get? vaults-per-principal principal))
)

(define-read-only (get-vault (vault-id uint))
    (ok (map-get? vault vault-id))
)

(define-read-only (calculate-collateral-ratio (debt uint) (collateral uint) (sbtc-price uint)) 
    (let 
        (
            (vault-collateral-in-bsd (mul-to-fixed-precision sbtc-price PRECISION collateral))
            (vault-collateral-ratio (if (is-eq debt u0) u0 ( div-to-fixed-precision vault-collateral-in-bsd PRECISION debt)))
        ) 
        (ok vault-collateral-ratio)
    )
)


(define-read-only (get-vault-compounded-info (vault-id uint) (sbtc-price uint))
    (let 
        (
            
            (vault-info (unwrap-panic (get-vault vault-id)))
            (vault-debt (unwrap-panic (get borrowed-bsd vault-info)))
            (vault-collateral (unwrap-panic (get collateral-sbtc vault-info)))
            (vault-protocol-shares (unwrap-panic (get-vault-protocol-shares vault-id)))
            (vault-calc-protocol-debt (get calculated-protocol-debt vault-protocol-shares))
            (vault-calc-protocol-collateral (get calculated-protocol-collateral vault-protocol-shares))
            (vault-attr-protocol-debt (get attributed-protocol-debt vault-protocol-shares))
            (vault-attr-protocol-collateral (get attributed-protocol-collateral vault-protocol-shares))
            
            (vault-total-debt-minus-accrual (+ vault-debt vault-calc-protocol-debt vault-attr-protocol-debt))
            (accrued-interest (unwrap-panic (get-vault-accrued-interest vault-id vault-total-debt-minus-accrual)))
            (vault-total-debt (+ vault-debt accrued-interest vault-calc-protocol-debt vault-attr-protocol-debt))
            (vault-total-collateral (+ vault-collateral vault-calc-protocol-collateral vault-attr-protocol-collateral))
            (vault-collateral-in-bsd (mul-to-fixed-precision sbtc-price PRECISION vault-total-collateral))

            (vault-collateral-ratio (div-to-fixed-precision vault-collateral-in-bsd PRECISION (if (is-eq u0 vault-total-debt) u1 vault-total-debt)))
        ) 
        (ok 
            {
                vault-total-debt: vault-total-debt,
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


(define-read-only (get-vault-protocol-shares (vault-id uint))
    (match (map-get? vault vault-id)
        current-vault
            (let 
                (   
                    (vault-collateral (get collateral-sbtc current-vault))
                    (vault-protocol-debt (get protocol-debt-bsd current-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc current-vault))
                    
                    
                    (redistribution-params (unwrap-panic (get-redistribution-params)))
                    (stake (get stake current-vault))
                    (vault-sbtc-rewards-snapshot (get vault-sbtc-rewards-snapshot current-vault))
                    (vault-bsd-rewards-snapshot (get vault-bsd-rewards-snapshot current-vault))
                    (total-sbtc-rewards-per-unit (get total-sbtc-rewards-per-unit redistribution-params))
                    (total-bsd-rewards-per-unit (get total-bsd-rewards-per-unit redistribution-params))
                    (calculated-collateral (mul stake (- total-sbtc-rewards-per-unit vault-sbtc-rewards-snapshot)))
                    (calculated-bsd (mul stake (- total-bsd-rewards-per-unit vault-bsd-rewards-snapshot)))
                )
                (ok { calculated-protocol-debt: calculated-bsd, calculated-protocol-collateral: calculated-collateral, attributed-protocol-debt: vault-protocol-debt, attributed-protocol-collateral: vault-protocol-collateral })
            )
        (ok {calculated-protocol-debt: u0, calculated-protocol-collateral: u0, attributed-protocol-debt: u0, attributed-protocol-collateral: u0})
    )
)


(define-read-only (get-base-rate)
    (ok (var-get base-rate))
)

(define-read-only (calculate-redeem-fee-rate (bsd-amount uint))
   (let 
        (
            (current-aggregate-bsd-loans (get debt-bsd (var-get aggregate-debt-and-collateral)))
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


(define-read-only (get-base-rate-constants)
   (ok 
        {
            alpha: (var-get alpha),
            delta: (var-get delta),
        }
   )
)


(define-read-only (get-redistribution-params)
    (ok (var-get protocol-redistribution-params))
)


(define-public (set-processed-epoch (new-epoch uint))
    (let
        (
            (keeper (unwrap-panic (contract-call? .controller-vpv-10 is-keeper tx-sender)))
        )
        (asserts! keeper ERR_AUTH)
        (asserts! (<= new-epoch (get-current-epoch)) ERR_INVALID_EPOCH)
        (var-set last-processed-epoch new-epoch)
        (ok true)
    )
)


(define-public (set-protocol-state (new-state uint))
    (begin
        (try! (contract-call? .controller-vpv-10 is-admin tx-sender))
        (asserts! (or (is-eq new-state PROTOCOL_STATE_NORMAL) (is-eq new-state PROTOCOL_STATE_PAUSED) (is-eq new-state PROTOCOL_STATE_MAINTENANCE)) ERR_INVALID_VALUE)
        (var-set protocol-state new-state)
        (ok true)
    )
)


(define-public (hot-pause)
    (begin
        (try! (contract-call? .controller-vpv-10 is-hot-pause-caller tx-sender))
        (var-set protocol-state PROTOCOL_STATE_PAUSED)
        (ok true)
    )
)

(define-public (set-decay-parameters (new-delta uint) (new-max-decay uint) (new-max-hours-decay uint) (new-block-decay-rates (list 500 uint)) (new-blocks-per-hour uint) (new-hours-per-epoch uint))
    (begin

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))
        
        (var-set delta new-delta)
        (var-set max-decay new-max-decay)
        (var-set max-hours-decay new-max-hours-decay)
        (var-set block-decay-rates new-block-decay-rates)
        (var-set blocks-per-hour new-blocks-per-hour)
        (var-set hours-per-epoch new-hours-per-epoch)
        (ok true)
    )
)

(define-public (set-borrow-parameters (new-min-borrow-fee uint) (new-max-borrow-fee uint) (new-loan-minimum uint))
    (begin
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (asserts! (> new-max-borrow-fee new-min-borrow-fee) ERR_INVALID_VALUE)
        (var-set min-borrow-fee new-min-borrow-fee)
        (var-set max-borrow-fee new-max-borrow-fee)
        (var-set vault-loan-minimum new-loan-minimum)
        (ok true)
    )
)

(define-public (set-redeem-parameters (new-min-redeem-fee uint) (new-max-redeem-fee uint) (new-alpha uint) (new-min-redeem-amount uint) (new-max-vaults-to-redeem uint))
    (begin
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

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
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (asserts! ( > new-vault-recovery-ratio-threshold new-vault-collateral-ratio-threshold) ERR_INVALID_VALUE)
        (var-set vault-collateral-ratio-threshold new-vault-collateral-ratio-threshold)
        (var-set vault-recovery-ratio-threshold new-vault-recovery-ratio-threshold)
        (var-set vault-interest-minimum new-interest-minimum)
        (var-set vault-interest-maximum new-interest-maximum)
        (ok true)
    )
)

(define-public (set-global-parameters (new-global-collateral-ratio-threshold uint) (new-global-collateral-cap uint) (new-protocol-fee-destination principal) (new-min-stability-provider-balance uint) (new-epoch-genesis uint) (new-oracle-stale-threshold-seconds uint) (new-oracle-allowable-price-deviation uint) (new-timelock-delay uint))
    (begin
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (asserts! (> new-global-collateral-ratio-threshold ONE_FULL_UNIT) ERR_INVALID_VALUE)
        (asserts! (>= new-timelock-delay MIN_TIMELOCK_DELAY) ERR_INVALID_VALUE)
        
        (var-set global-collateral-ratio-threshold new-global-collateral-ratio-threshold)
        (var-set global-collateral-cap new-global-collateral-cap)
        (var-set protocol-fee-destination new-protocol-fee-destination)
        (var-set min-stability-provider-balance new-min-stability-provider-balance)
        (var-set epoch-genesis new-epoch-genesis)
        (var-set oracle-stale-threshold-seconds new-oracle-stale-threshold-seconds)
        (var-set oracle-allowable-price-deviation new-oracle-allowable-price-deviation)
        (var-set timelock-delay new-timelock-delay)
        (ok true)
    )
)

(define-read-only (get-last-processed-epoch) 
    (var-get last-processed-epoch)
)

(define-read-only (get-oracle-stale-threshold-seconds) 
    (ok (var-get oracle-stale-threshold-seconds))
)

(define-read-only (get-oracle-allowable-price-deviation) 
    (ok (var-get oracle-allowable-price-deviation))
)

(define-read-only (get-timelock-delay) 
    (ok (var-get timelock-delay))
)


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
                oracle-stale-threshold-seconds: (var-get oracle-stale-threshold-seconds),
                oracle-allowable-price-deviation: (var-get oracle-allowable-price-deviation),
                borrow-fee-rate: (unwrap-panic (get-borrow-fee-rate recovery-mode))
            }
        )
    )
)


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


(define-public (get-protocol-attributes (sorted-vaults <sorted-vaults-trait>))
        (ok {
            
            total-bsd-loans: (get debt-bsd (var-get aggregate-debt-and-collateral)),
            total-sbtc-collateral: (get collateral-sbtc (var-get aggregate-debt-and-collateral)),
            active-vaults: (get total-vaults (unwrap-panic (contract-call? sorted-vaults get-vaults-summary))),
            created-vaults: (var-get created-vaults),
            is-paused: (is-eq PROTOCOL_STATE_PAUSED (var-get protocol-state)),
            is-maintenance: (is-eq PROTOCOL_STATE_MAINTENANCE (var-get protocol-state)),
            base-rate: (var-get base-rate),
            last-redeem-height: (var-get last-redeem-height),

            
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
            oracle-stale-threshold-seconds: (var-get oracle-stale-threshold-seconds),
            oracle-allowable-price-deviation: (var-get oracle-allowable-price-deviation),
            timelock-delay: (var-get timelock-delay),
        })
)


(define-public (new-vault (borrower principal) (collateral-sbtc uint) (loan-bsd uint) (interest-rate uint) (hint (optional uint)) (sorted-vaults <sorted-vaults-trait>))
    (let
        (
            (current-vault-id (var-get created-vaults))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-epoch (get-current-epoch))
            (next-epoch (+ current-epoch u1))
        )
        
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (map-set vaults-per-principal tx-sender 
            (unwrap! (as-max-len? 
                (append 
                    (default-to (list ) (map-get? vaults-per-principal tx-sender))
                    current-vault-id
                ) 
            u50) ERR_LIST_OVERFLOW)
        )

        
        (map-set vault current-vault-id {
            borrower: tx-sender,
            created-height: burn-block-height,
            borrowed-bsd: loan-bsd,
            collateral-sbtc: collateral-sbtc,
            protocol-debt-bsd: u0,
            protocol-collateral-sbtc: u0,
            interest-rate: interest-rate,
            last-interest-accrued: burn-block-height,
            future-interest-rate: interest-rate,
            future-interest-epoch: next-epoch,
            interest-rate-delegate: tx-sender,
            stake: u0, 
            vault-sbtc-rewards-snapshot: u0,
            vault-bsd-rewards-snapshot: u0,
        })
        
        (var-set aggregate-debt-and-collateral {
            debt-bsd: (+ (get debt-bsd current-aggregate) loan-bsd),
            collateral-sbtc: (+ (get collateral-sbtc current-aggregate) collateral-sbtc),
        })

        (if (> current-vault-id u0)
            (begin 
                (try! (contract-call? sorted-vaults insert current-vault-id interest-rate hint))
                (try! (update-stake-and-total-stakes current-vault-id collateral-sbtc))
            )
            
            (initialize-total-stakes current-vault-id collateral-sbtc)
        )

        (ok (var-set created-vaults (+ current-vault-id u1)))
    )
)


(define-public (mint-loan (vault-id uint) (borrow-bsd uint) (sbtc-price uint))
    (let 
        (
            
            (attributed (attribute-protocol-balances vault-id)) 

            
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-debt (get vault-debt vault-balances))
            (vault-collateral (get vault-collateral vault-balances))
            (vault-protocol-collateral (get vault-protocol-collateral vault-balances))

            
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-bsd (get debt-bsd current-aggregate))

            
            (processed-stakes (update-stake-and-total-stakes vault-id (+ vault-collateral vault-protocol-collateral)))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: (+ current-aggregate-bsd borrow-bsd),
            })
        )

        
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                borrowed-bsd: (+ vault-debt borrow-bsd),
            })
        )

        (ok true)
    )
)


(define-public (repay-loan (vault-id uint) (repay-amount uint) (sbtc-price uint))
    (let 
        (
            
            (attributed (attribute-protocol-balances vault-id))

            
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-bsd (get debt-bsd current-aggregate))

            
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-debt (get vault-debt vault-balances))
            (vault-protocol-debt (get vault-protocol-debt vault-balances))
            (vault-collateral (get vault-collateral vault-balances))
            (vault-protocol-collateral (get vault-protocol-collateral vault-balances))

            
            (new-vault-debt (if (> repay-amount vault-debt) u0 (- vault-debt repay-amount)))
            (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- repay-amount vault-debt)) vault-protocol-debt))

            
            (processed-stakes (update-stake-and-total-stakes vault-id (+ vault-collateral vault-protocol-collateral)))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                debt-bsd: (- current-aggregate-bsd repay-amount)
            })
        )

        
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


(define-public (add-collateral (vault-id uint) (add-amount uint) (sbtc-price uint))
    (let
        (
            
            (attributed (attribute-protocol-balances vault-id))

            
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-collateral (get vault-collateral vault-balances))
            (vault-protocol-collateral (get vault-protocol-collateral vault-balances))

            
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-sbtc (get collateral-sbtc current-aggregate))

            
            (new-vault-collateral (+ vault-collateral vault-protocol-collateral add-amount))
            (processed-stakes (update-stake-and-total-stakes vault-id new-vault-collateral))
        ) 

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                collateral-sbtc: (+ current-aggregate-sbtc add-amount)
            })
        )

        
        (map-set vault vault-id (merge 
            (unwrap-panic (map-get? vault vault-id)) 
            { 
                collateral-sbtc: (+ vault-collateral add-amount),
            })
        )

        (ok true)
    )
)


(define-public (remove-collateral (vault-id uint) (remove-amount uint) (sbtc-price uint))
    (let
        (
            
            (attributed (attribute-protocol-balances vault-id))

            
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (current-aggregate-sbtc (get collateral-sbtc current-aggregate))

             
            (vault-balances (unwrap-panic (get-vault-compounded-info vault-id sbtc-price)))
            (vault-collateral (get vault-collateral vault-balances))
            (vault-protocol-collateral (get vault-protocol-collateral vault-balances))

            
            (new-vault-collateral (if (> remove-amount vault-collateral) u0 (- vault-collateral remove-amount)))
            (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- remove-amount vault-collateral)) vault-protocol-collateral))
        
            
            (processed-stakes (update-stake-and-total-stakes vault-id (+ new-vault-collateral new-protocol-collateral)))

        ) 

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { 
                collateral-sbtc: (- current-aggregate-sbtc remove-amount)
            })
        )

        
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


(define-public (close-vault (vault-id uint) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
            (borrower (get borrower current-vault))
        )
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))
        
        (map-delete vault vault-id)

        
        (try! (contract-call? sorted-vaults remove vault-id))

        
        (map-set vaults-per-principal borrower (get new-list (try! 
            (fold remove-vault-id-from-principal-list 
                (unwrap! (as-max-len? 
                    (default-to (list ) (map-get? vaults-per-principal borrower))

                u50) ERR_LIST_OVERFLOW) (ok {found: false, compare-uint: vault-id, new-list: (list )})))))
    
        (ok true)
    )
)


(define-public (accrue-interest (vault-id uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (current-aggregate (var-get aggregate-debt-and-collateral))
            (vault-balances (unwrap-panic (get-vault-protocol-shares vault-id)))
            (vault-debt (get borrowed-bsd current-vault))
            (vault-protocol-debt (get attributed-protocol-debt vault-balances))
            (vault-protocol-calculated-debt (get calculated-protocol-debt vault-balances))
            (vault-total-debt-minus-accrual (+ vault-debt vault-protocol-debt vault-protocol-calculated-debt))
            (accrued-interest (unwrap-panic (get-vault-accrued-interest vault-id vault-total-debt-minus-accrual)))
        )
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (print {
            accrue-interest-event: {
                vault-id: vault-id,
                accrued-interest: accrued-interest,
            }
        })

        
        (map-set vault vault-id (merge 
            current-vault 
            {   borrowed-bsd: (+ vault-debt accrued-interest),
                last-interest-accrued: burn-block-height })
        )

        
        (ok (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { debt-bsd: (+ (get debt-bsd current-aggregate) accrued-interest) })
        ))
    )
)


(define-read-only (get-vault-accrued-interest (vault-id uint) (vault-total-debt uint))
    (match (map-get? vault vault-id)
        current-vault
            (let 
                (
                    (vault-interest-rate (get interest-rate current-vault))
                    (vault-last-interest-accrued (get last-interest-accrued current-vault))
                    (blocks-to-accrue ( - burn-block-height vault-last-interest-accrued))
                )
                (ok (/ (* (mul-to-fixed-precision vault-total-debt PRECISION vault-interest-rate) blocks-to-accrue) year))
            )
        (ok u0)
    )
)


(define-public (update-interest-rate (vault-id uint) (new-interest-rate uint))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (ok (map-set vault vault-id (merge current-vault { future-interest-rate: new-interest-rate })))
    )
)


(define-public (update-delegate (vault-id uint) (new-rate-delegate principal))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (ok (map-set vault vault-id (merge current-vault { interest-rate-delegate: new-rate-delegate })))
    )
)


(define-public (update-epoch-rate (vault-id uint) (hint (optional uint)) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
            (future-interest-rate (get future-interest-rate current-vault))
            (future-interest-epoch (get future-interest-epoch current-vault))
            (current-epoch (get-current-epoch))
            (next-epoch (+ current-epoch u1))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

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

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
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

                
                (map-set stability-pool-providers tx-sender {
                    liquidity-staked: (+ compounded-deposit amount),
                    product_t: current-product,
                    sum_t: current-sum,
                    checkpoint: current-checkpoint,
                })

                
                (var-set stability-pool (merge current-stability-pool 
                {
                    aggregate-bsd: increased-aggregate-bsd,
                    aggregate-sbtc: decreased-aggregate-sbtc,
                    current-checkpoint: current-checkpoint,
                }))
            )
            (let 
                (
                    (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards current-checkpoint))))
                )
                
                (map-set stability-pool-providers tx-sender {
                    liquidity-staked: amount,
                    product_t: current-product,
                    sum_t: current-sum,
                    checkpoint: current-checkpoint,
                })

                
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


(define-public (remove-liquidity (amount uint) (provider principal))
    (let 
        (
            (current-stability-pool (var-get stability-pool))
            (current-checkpoint (get current-checkpoint current-stability-pool))
            (decreased-aggregate-bsd (- (get aggregate-bsd current-stability-pool) amount))
            (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards current-checkpoint))))
            (current-product (get product current-stability-pool))
            (calculated-rewards (unwrap-panic (calculate-provider-rewards provider)))
            (compounded-deposit (unwrap-panic (calculate-compounded-deposit provider)))
            (decreased-aggregate-sbtc (- (get aggregate-sbtc current-stability-pool) calculated-rewards))
        )
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set stability-pool 
        {
            aggregate-bsd: decreased-aggregate-bsd,
            aggregate-sbtc: decreased-aggregate-sbtc,
            active:  (get active current-stability-pool),
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

        
        (ok (if (is-eq amount compounded-deposit)

            
            (begin

                (print {
                    remove-provider-event: {
                        provider: provider,
                    }
                })

                
                (map-delete stability-pool-providers provider)

                
                (var-set stability-pool 
                    {
                        aggregate-bsd: decreased-aggregate-bsd, 
                        aggregate-sbtc: decreased-aggregate-sbtc, 
                        active: (get new-list (try! (fold remove-principal-from-list (get active current-stability-pool) (ok {found: false, compare-principal: provider, new-list: (list )})))),
                        product: (get product current-stability-pool), 
                        current-checkpoint: (get current-checkpoint current-stability-pool)
                    } 
                )
            )

            
            (map-set stability-pool-providers provider {
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

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (if (is-eq compounded-deposit u0)
            (begin 
                
                (map-delete stability-pool-providers provider)

                
                (ok (var-set stability-pool 
                {
                    aggregate-bsd: current-aggregate-bsd,
                    aggregate-sbtc: decreased-aggregate-sbtc,
                    active: (get new-list (try! (fold remove-principal-from-list (get active current-stability-pool) (ok {found: false, compare-principal: provider, new-list: (list )})))),
                    product: (get product current-stability-pool),
                    current-checkpoint: current-checkpoint,
                }))
            )
            (begin 
                (map-set stability-pool-providers tx-sender {
                liquidity-staked: compounded-deposit,
                product_t: current-product,
                sum_t: current-sum,
                checkpoint: current-checkpoint,
                })

                
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





(define-private (delete-vault (vault-id uint) (sorted-vaults <sorted-vaults-trait>)) 

    (let 
        (
            (vault-info (unwrap-panic (map-get? vault vault-id)))
            (borrower (get borrower vault-info))
        )

        
        (map-set vaults-per-principal borrower (get new-list (try! 
            (fold remove-vault-id-from-principal-list 
                (unwrap! (as-max-len? 
                    (default-to (list ) (map-get? vaults-per-principal borrower))

                u50) ERR_LIST_OVERFLOW) (ok {found: false, compare-uint: vault-id, new-list: (list )})))))

        
        (try! (contract-call? sorted-vaults remove vault-id))

        
        (ok (map-delete vault vault-id))
    )
)


(define-private (fully-redeem-vault (vault-id uint) (helper-tuple (response {price: uint, total-redeem-fee: uint, total-bsd-redeemed: uint} uint)))
    (match helper-tuple
        ok-tuple
        (let
            (                 
                
                (updated-balances (attribute-protocol-balances vault-id))

                
                (aggregate-balances (var-get aggregate-debt-and-collateral))
                (aggregate-bsd (get debt-bsd aggregate-balances))
                (aggregate-sbtc (get collateral-sbtc aggregate-balances))

                
                (accrued (accrue-interest vault-id))

                
                (updated-vault (unwrap-panic (map-get? vault vault-id)))
                (vault-debt (get borrowed-bsd updated-vault))
                (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                (vault-total-debt (+ vault-debt vault-protocol-debt))
                (vault-collateral (get collateral-sbtc updated-vault))
                (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))
                (vault-total-collateral (+ vault-collateral vault-protocol-collateral))

                (redeemed-bsd-in-sbtc ( div-to-fixed-precision vault-total-debt PRECISION (get price ok-tuple)))
                (vault-share ( div-to-fixed-precision vault-total-debt PRECISION (get total-bsd-redeemed ok-tuple)))
                (dividend ( mul-to-fixed-precision vault-total-debt PRECISION (get total-redeem-fee ok-tuple)))
                (redeem-fee-credit (div-round-down dividend (get total-bsd-redeemed ok-tuple)))
                (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
            
                (processed-stakes (update-stake-and-total-stakes vault-id (+ new-vault-collateral new-protocol-collateral redeem-fee-credit)))
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
                            rate: (get interest-rate updated-vault),
                        }
                    }
            )

            
            (map-set vault vault-id
                (merge 
                    (unwrap-panic (map-get? vault vault-id))
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

(define-private (get-decay-rate (elapsed-blocks uint))
    (if (> elapsed-blocks (var-get max-blocks-decay)) (var-get max-decay) (unwrap-panic (element-at (var-get block-decay-rates) elapsed-blocks)))
)

(define-private (get-blocks-since-last-redeem) 
    (- burn-block-height (var-get last-redeem-height))
)


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
            (elapsed-blocks (get-blocks-since-last-redeem))
            (decay-rate (get-decay-rate elapsed-blocks))
            (decayed-base-rate (mul-to-fixed-precision decay-rate u8 (var-get base-rate)))
        )
        decayed-base-rate
    )  
)

(define-read-only (calculate-provider-rewards (provider principal))
    (let 
        (
            (current-provider (unwrap! (map-get? stability-pool-providers provider) ERR_PROVIDER_NOT_FOUND))
            (claimable-rewards-checkpoint (get checkpoint current-provider))
            (current-sum (get sum (unwrap-panic (map-get? checkpoint-rewards claimable-rewards-checkpoint))))
            (current-provider-bsd (get liquidity-staked current-provider))
            (current-provider-sum (get sum_t current-provider))
            (current-provider-product (get product_t current-provider))
            (new-sum (- current-sum current-provider-sum))
            
            
            (calculated-rewards (/ (div-round-down (mul current-provider-bsd (if (is-eq new-sum u0) u0 (- new-sum u1))) current-provider-product) ONE_FULL_UNIT))
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



(define-private (remove-vault-id-from-principal-list (list-uint uint) (helper-tuple-response (response {found: bool, compare-uint: uint, new-list: (list 50 uint)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-uint (get compare-uint helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )

                
                (if (is-eq current-found true)
                    
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-uint) u50) ERR_LIST_OVERFLOW)}
                    ))
                    
                    (if (is-eq current-compare-uint list-uint)
                        
                        (ok (merge 
                            helper-tuple
                            {found: true}
                        ))
                        
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




(define-private (remove-principal-from-list (list-principal principal) (helper-tuple-response (response {found: bool, compare-principal: principal, new-list: (list 1000 principal)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-principal (get compare-principal helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )
                
                (if current-found
                    
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u1000) ERR_LIST_OVERFLOW)}
                    ))
                    
                    (if (is-eq list-principal current-compare-principal)
                        
                        (ok (merge 
                            helper-tuple
                            {found: true, new-list: current-new-list}
                        ))
                        
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





(define-private (attribute-protocol-balances (vault-id uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (protocol-debt (get protocol-debt-bsd current-vault))
            (protocol-collateral (get protocol-collateral-sbtc current-vault))

            (calc-protocol-share (unwrap-panic (get-vault-protocol-shares vault-id)))
            (calc-protocol-debt-add (get calculated-protocol-debt calc-protocol-share))
            (calc-protocol-collateral-add (get calculated-protocol-collateral calc-protocol-share))

            (global-redistribution-params (var-get protocol-redistribution-params))
            (total-sbtc-rewards-per-unit (get total-sbtc-rewards-per-unit global-redistribution-params))
            (total-bsd-rewards-per-unit (get total-bsd-rewards-per-unit global-redistribution-params))
           
            
            (new-protocol-debt (+ protocol-debt calc-protocol-debt-add))
            (new-protocol-collateral (+ protocol-collateral calc-protocol-collateral-add))
        )

        (map-set vault vault-id 
                (merge 
                    current-vault
                    { 
                        protocol-debt-bsd: new-protocol-debt,
                        protocol-collateral-sbtc: new-protocol-collateral,
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
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            current-aggregate 
            { collateral-sbtc: (- (get collateral-sbtc current-aggregate) vault-total-collateral) })
        )

        (remove-stake vault-id)

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
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (map-delete stability-pool-providers provider)

        
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


(define-public (liquidation-update-provider-distribution (vault-id uint) (liquidated-stability-bsd uint) (liquidated-stability-sbtc uint) (delete bool) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (total-bsd (get debt-bsd (var-get aggregate-debt-and-collateral)))
            (total-sbtc (get collateral-sbtc (var-get aggregate-debt-and-collateral)))
                        
            
            (current-stability-pool (var-get stability-pool))
            (current-stability-pool-bsd (get aggregate-bsd current-stability-pool))
            (current-stability-pool-sbtc (get aggregate-sbtc current-stability-pool))
            
            (stored-checkpoint (get current-checkpoint current-stability-pool))
            (stored-sum (get sum (unwrap-panic (map-get? checkpoint-rewards stored-checkpoint))))
            
            (calc-stability-product (mul (get product current-stability-pool) (div-round-down (- current-stability-pool-bsd liquidated-stability-bsd) current-stability-pool-bsd)))

            
            (calc-stability-sum (+ stored-sum (mul (div (* liquidated-stability-sbtc ONE_FULL_UNIT) current-stability-pool-bsd) (get product current-stability-pool))))       

            (current-sum calc-stability-sum)
            (current-product (if (is-eq calc-stability-product u0) ONE_FULL_UNIT calc-stability-product))
            (current-checkpoint (if (is-eq calc-stability-product u0) (+ stored-checkpoint u1) stored-checkpoint))
        )
        
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (if (is-eq calc-stability-product u0)
            
            (begin 
                (map-set checkpoint-rewards stored-checkpoint {checkpoint: stored-checkpoint, sum: current-sum})
                (map-set checkpoint-rewards current-checkpoint {checkpoint: current-checkpoint, sum: current-sum})
            )
            
            (map-set checkpoint-rewards current-checkpoint {checkpoint: current-checkpoint, sum: current-sum})
        )

        
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: (- total-bsd liquidated-stability-bsd),
                collateral-sbtc: (- total-sbtc liquidated-stability-sbtc) 
            })
        )
       
        
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
            (begin
                (remove-stake vault-id)
                (close-vault vault-id sorted-vaults)
            )
            (ok true)
        )
    )
)


(define-public (clear-stability-dust)
    (let 
        (
            (current-stability-pool (var-get stability-pool))
            (current-aggregate-bsd (get aggregate-bsd current-stability-pool))
            (current-aggregate-sbtc (get aggregate-sbtc current-stability-pool))
            (active-providers (get active current-stability-pool))
            (active-providers-count (len active-providers))
        )

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (if (and (is-eq active-providers-count u0) (or (> current-aggregate-bsd u0) (> current-aggregate-sbtc u0)))
            (begin
                
                (var-set stability-pool (merge current-stability-pool 
                {
                    aggregate-bsd: u0,
                    aggregate-sbtc: u0,
                }))

                (print {
                    clear-stability-dust-event: {
                        cleared-aggregate-bsd: current-aggregate-bsd,
                        cleared-aggregate-sbtc: current-aggregate-sbtc,
                        active-providers-count: active-providers-count,
                    }
                })

                (ok true)
            )
            (ok false)
        )
    )
)


(define-public (liquidation-update-vault-redistribution (vault-id uint) (liquidated-redistribution-bsd uint) (liquidated-redistribution-sbtc uint) (delete bool) (sorted-vaults <sorted-vaults-trait>))
    (let 
        (
            (total-bsd (get debt-bsd (var-get aggregate-debt-and-collateral)))
            (total-sbtc (get collateral-sbtc (var-get aggregate-debt-and-collateral)))         
        )
        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        (print {
            redistribution-event: 
                {
                    vault-id: vault-id, 
                    redistribution-amount-bsd: liquidated-redistribution-bsd, 
                    redistribution-amount-sbtc: liquidated-redistribution-sbtc,
                    aggregate-bsd: total-bsd,
                    aggregate-sbtc: total-sbtc,
                }
            }
        )

        (if (is-eq delete true)
            (begin
                (remove-stake vault-id)
                (redistribute-debt-and-collateral liquidated-redistribution-bsd liquidated-redistribution-sbtc)
                (update-snapshots total-sbtc)
                (close-vault vault-id sorted-vaults)
            )
            (ok true)
        )
    )
)


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

        
        (try! (contract-call? .controller-vpv-10 is-protocol-caller contract-caller))

        
        (var-set aggregate-debt-and-collateral (merge 
            (var-get aggregate-debt-and-collateral) 
            { 
                debt-bsd: decreased-aggregate-bsd-debt,
                collateral-sbtc: decreased-aggregate-sbtc-collateral 
            })
        )

        
        (if (is-eq vaults-len u1)
            
            (let
                (
                    (vault-id (unwrap-panic (element-at? vaults u0)))
                    (current-vault (unwrap-panic (map-get? vault vault-id)))

                    
                    (accrued (accrue-interest vault-id))

                    
                    (updated-balances (attribute-protocol-balances vault-id))

                    
                    (updated-vault (unwrap-panic (map-get? vault vault-id)))
                    (vault-debt (get borrowed-bsd updated-vault))
                    (vault-collateral (get collateral-sbtc updated-vault))
                    (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))

                    
                    
                    (redeemed-bsd-in-sbtc ( div-to-fixed-precision partial-bsd-redeemed PRECISION bsd-to-sbtc-price))
                    (new-vault-debt (if (> partial-bsd-redeemed vault-debt) u0 (- vault-debt partial-bsd-redeemed)))
                    (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- partial-bsd-redeemed vault-debt)) vault-protocol-debt))
                    (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                    (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
                    
                    (processed-stakes (update-stake-and-total-stakes vault-id (+ new-vault-collateral new-protocol-collateral total-redeem-fee)))
                )

                (print {
                        redeem-vault-event: 
                            {
                                vault-id: vault-id, 
                                redeemed-collateral: redeemed-bsd-in-sbtc,
                                bsd-redeemed: partial-bsd-redeemed,
                                redeem-fee-credit: total-redeem-fee, 
                                sbtc-price: bsd-to-sbtc-price,
                                rate: (get interest-rate updated-vault),
                            }
                        }
                )

                
                (map-set vault vault-id
                    (merge 
                        (unwrap-panic (map-get? vault vault-id))
                        { 
                            borrowed-bsd: new-vault-debt,
                            protocol-debt-bsd: new-protocol-debt,
                            collateral-sbtc: (+ new-vault-collateral total-redeem-fee),
                            protocol-collateral-sbtc: new-protocol-collateral
                        }
                    )
                )
            )   
            
            (let 
                (
                    
                    (fully-redeemed-vaults (unwrap! (slice? vaults u0 (- (len vaults) u1)) ERR_SLICE))

                    
                    (vault-id (unwrap-panic (element-at? vaults (- (len vaults) u1))))

                    
                    (accrued (accrue-interest vault-id))

                    (current-vault (unwrap-panic (map-get? vault vault-id)))
                    (redeemed-bsd-in-sbtc ( div-to-fixed-precision partial-bsd-redeemed PRECISION bsd-to-sbtc-price))
                    (dividend ( mul-to-fixed-precision partial-bsd-redeemed PRECISION total-redeem-fee))
                    (redeem-fee-credit (div-round-down dividend total-bsd-redeemed))
                    
                    
                    (updated-balances (attribute-protocol-balances vault-id))

                    
                    (updated-vault (unwrap-panic (map-get? vault vault-id)))
                    (vault-debt (get borrowed-bsd updated-vault))
                    (vault-protocol-debt (get protocol-debt-bsd updated-vault))
                    (vault-collateral (get collateral-sbtc updated-vault))
                    (vault-protocol-collateral (get protocol-collateral-sbtc updated-vault))

                    
                    
                    (new-vault-debt (if (> partial-bsd-redeemed vault-debt) u0 (- vault-debt partial-bsd-redeemed)))
                    (new-protocol-debt (if (is-eq new-vault-debt u0) (- vault-protocol-debt (- partial-bsd-redeemed vault-debt)) vault-protocol-debt))
                    (new-vault-collateral (if (> redeemed-bsd-in-sbtc vault-collateral) u0 (- vault-collateral redeemed-bsd-in-sbtc)))
                    (new-protocol-collateral (if (is-eq new-vault-collateral u0) (- vault-protocol-collateral (- redeemed-bsd-in-sbtc vault-collateral)) vault-protocol-collateral))
                
                    (processed-stakes (update-stake-and-total-stakes vault-id (+ new-vault-collateral new-protocol-collateral redeem-fee-credit)))
                )

                
                (map-set vault vault-id
                    (merge 
                        (unwrap-panic (map-get? vault vault-id))
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
                                rate: (get interest-rate updated-vault),
                            }
                        }
                )

                
                (try! (fold fully-redeem-vault fully-redeemed-vaults (ok {price: bsd-to-sbtc-price, total-redeem-fee: total-redeem-fee, total-bsd-redeemed: total-bsd-redeemed})))
                true
            )
        )

        
        (var-set last-redeem-height burn-block-height)

        
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
            (healthy-cr (var-get vault-collateral-ratio-threshold))
        )
        (if (is-eq vault-count u0)
            (ok {vaults: (list ), total-redeem-value: u0})
            
            (let 
                (
                    (sorted-vault-1-id (unwrap-panic (get first-vault-id sorted-vaults-summary)))
                    (vault-1-info (unwrap-panic (get-vault-compounded-info sorted-vault-1-id sbtc-price)))
                    (vault-1-bsd (get vault-total-debt vault-1-info))
                    (vault-1-cr (get vault-collateral-ratio vault-1-info))
                    (vault-1-healthy (asserts! (>= vault-1-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                )
                    (if (is-eq vault-count u1)
                        (ok {vaults: (list sorted-vault-1-id), total-redeem-value: vault-1-bsd})
                        
                        (let 
                            (
                                (sorted-vault-2-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-1-id)))))
                                (vault-2-info (unwrap-panic (get-vault-compounded-info sorted-vault-2-id sbtc-price)))
                                (vault-2-bsd (get vault-total-debt vault-2-info))
                                (vault-2-cr (get vault-collateral-ratio vault-2-info))
                                (vault-2-healthy (asserts! (>= vault-2-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                            )
                            (if (is-eq vault-count u2) 
                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd)})
                                
                                (let 
                                    (
                                        (sorted-vault-3-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-2-id)))))
                                        (vault-3-info (unwrap-panic (get-vault-compounded-info sorted-vault-3-id sbtc-price)))
                                        (vault-3-bsd (get vault-total-debt vault-3-info))
                                        (vault-3-cr (get vault-collateral-ratio vault-3-info))
                                        (vault-3-healthy (asserts! (>= vault-3-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                    )
                                    (if (is-eq vault-count u3) 
                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd)})
                                        
                                        (let 
                                            (
                                                (sorted-vault-4-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-3-id)))))
                                                (vault-4-info (unwrap-panic (get-vault-compounded-info sorted-vault-4-id sbtc-price)))
                                                (vault-4-bsd (get vault-total-debt vault-4-info))
                                                (vault-4-cr (get vault-collateral-ratio vault-4-info))
                                                (vault-4-healthy (asserts! (>= vault-4-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                            )
                                            (if (is-eq vault-count u4) 
                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd)})
                                                
                                                (let 
                                                    (
                                                        (sorted-vault-5-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-4-id)))))
                                                        (vault-5-info (unwrap-panic (get-vault-compounded-info sorted-vault-5-id sbtc-price)))
                                                        (vault-5-bsd (get vault-total-debt vault-5-info))
                                                        (vault-5-cr (get vault-collateral-ratio vault-5-info))
                                                        (vault-5-healthy (asserts! (>= vault-5-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                                    )
                                                    (if (is-eq vault-count u5) 
                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd)})
                                                        
                                                        (let 
                                                            (
                                                                (sorted-vault-6-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-5-id)))))
                                                                (vault-6-info (unwrap-panic (get-vault-compounded-info sorted-vault-6-id sbtc-price)))
                                                                (vault-6-bsd (get vault-total-debt vault-6-info))
                                                                (vault-6-cr (get vault-collateral-ratio vault-6-info))
                                                                (vault-6-healthy (asserts! (>= vault-6-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                                            )
                                                            (if (is-eq vault-count u6) 
                                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd)})
                                                                
                                                                (let 
                                                                    (
                                                                        (sorted-vault-7-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-6-id)))))
                                                                        (vault-7-info (unwrap-panic (get-vault-compounded-info sorted-vault-7-id sbtc-price)))
                                                                        (vault-7-bsd (get vault-total-debt vault-7-info))
                                                                        (vault-7-cr (get vault-collateral-ratio vault-7-info))
                                                                        (vault-7-healthy (asserts! (>= vault-7-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                                                    )
                                                                    (if (is-eq vault-count u7) 
                                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd)})
                                                                        
                                                                        (let 
                                                                            (
                                                                                (sorted-vault-8-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-7-id)))))
                                                                                (vault-8-info (unwrap-panic (get-vault-compounded-info sorted-vault-8-id sbtc-price)))
                                                                                (vault-8-bsd (get vault-total-debt vault-8-info))
                                                                                (vault-8-cr (get vault-collateral-ratio vault-8-info))
                                                                                (vault-8-healthy (asserts! (>= vault-8-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                                                            )
                                                                            (if (is-eq vault-count u8)
                                                                                (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id sorted-vault-8-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd vault-8-bsd)})
                                                                                
                                                                                (let 
                                                                                    (
                                                                                        (sorted-vault-9-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-8-id)))))
                                                                                        (vault-9-info (unwrap-panic (get-vault-compounded-info sorted-vault-9-id sbtc-price)))
                                                                                        (vault-9-bsd (get vault-total-debt vault-9-info))
                                                                                        (vault-9-cr (get vault-collateral-ratio vault-9-info))
                                                                                        (vault-9-healthy (asserts! (>= vault-9-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
                                                                                    )
                                                                                    (if (is-eq vault-count u9) 
                                                                                        (ok {vaults: (list sorted-vault-1-id sorted-vault-2-id sorted-vault-3-id sorted-vault-4-id sorted-vault-5-id sorted-vault-6-id sorted-vault-7-id sorted-vault-8-id sorted-vault-9-id), total-redeem-value: (+ vault-1-bsd vault-2-bsd vault-3-bsd vault-4-bsd vault-5-bsd vault-6-bsd vault-7-bsd vault-8-bsd vault-9-bsd)})
                                                                                        
                                                                                        (let 
                                                                                            (
                                                                                                (sorted-vault-10-id (unwrap-panic (unwrap-panic (contract-call? sorted-vaults get-next-vault-id (some sorted-vault-9-id)))))
                                                                                                (vault-10-info (unwrap-panic (get-vault-compounded-info sorted-vault-10-id sbtc-price)))
                                                                                                (vault-10-bsd (get vault-total-debt vault-10-info))
                                                                                                (vault-10-cr (get vault-collateral-ratio vault-10-info))
                                                                                                (vault-10-healthy (asserts! (>= vault-10-cr healthy-cr) ERR_REDEEM_UNHEALTHY))
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


(define-private (compute-new-stake (vault-collateral uint))
    (let 
    (
      (redistribution-params (var-get protocol-redistribution-params))
            (total-collateral-snapshot (get total-collateral-snapshot redistribution-params))
      (total-stakes-snapshot (get total-stakes-snapshot redistribution-params))
    )
    (if (is-eq total-collateral-snapshot u0)
      (ok vault-collateral)
      (if (is-eq total-stakes-snapshot u0)
        (err ERR_STAKES)
        (let
          (
            (stake (div (mul vault-collateral total-stakes-snapshot) total-collateral-snapshot)) 
          )
          (ok stake)
        )
      )     
    )
  )
)


(define-private (initialize-total-stakes (vault-id uint) (vault-collateral uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (redistribution-params (var-get protocol-redistribution-params))
        )
        (var-set protocol-redistribution-params
            (merge 
                redistribution-params
                {
                    total-stakes: vault-collateral
                }
            )
        )
        (map-set vault vault-id (merge current-vault {stake: vault-collateral}))
    )
)

(define-private (remove-stake (vault-id uint))
    (let 
        (
            (current-vault (unwrap-panic (map-get? vault vault-id)))
            (redistribution-params (var-get protocol-redistribution-params))
            (total-stakes (get total-stakes redistribution-params))
            (vault-stake (get stake current-vault))
            (new-total-stakes (- total-stakes vault-stake))
        )
        (var-set protocol-redistribution-params
            (merge 
                redistribution-params
                {
                    total-stakes: new-total-stakes
                }
            )
        )
    )
)

(define-private (update-stake-and-total-stakes (vault-id uint) (vault-collateral uint))
    (let 
        (
            (current-vault (unwrap! (map-get? vault vault-id) ERR_VAULT_NOT_FOUND))
            (old-stake (get stake current-vault))
            (new-stake (unwrap-panic (compute-new-stake vault-collateral)))
            (redistribution-params (var-get protocol-redistribution-params))
            (total-stakes (get total-stakes redistribution-params))
            (total-sbtc-rewards-per-unit (get total-sbtc-rewards-per-unit redistribution-params))
            (total-bsd-rewards-per-unit (get total-bsd-rewards-per-unit redistribution-params))
            (new-total-stakes (+ (- total-stakes old-stake) new-stake))
            (new-vault-sbtc-rewards-checkpoint total-sbtc-rewards-per-unit)
            (new-vault-bsd-rewards-checkpoint total-bsd-rewards-per-unit)
        )   
        (begin 
            
            (map-set vault vault-id 
                (merge 
                    current-vault {
                        stake: new-stake, 
                        vault-sbtc-rewards-snapshot: new-vault-sbtc-rewards-checkpoint, 
                        vault-bsd-rewards-snapshot: new-vault-bsd-rewards-checkpoint
                    }
                )
            )

            
            (ok (var-set protocol-redistribution-params
                (merge 
                    redistribution-params
                    {
                        total-stakes: new-total-stakes,
                    }
                )
            ))                  
        )
    )
)

(define-private (update-snapshots (total-collateral uint))
    (let 
        (
            (redistribution-params (var-get protocol-redistribution-params))
            (total-stakes (get total-stakes redistribution-params))
            (new-total-stakes-snapshot total-stakes)
            (new-total-collateral-snapshot total-collateral)
        )
        (begin
            
            (var-set protocol-redistribution-params
                (merge 
                    redistribution-params
                    {
                        total-stakes-snapshot: new-total-stakes-snapshot,
                        total-collateral-snapshot: new-total-collateral-snapshot,
                    }
                )
            )
        )
    )
)

(define-private (redistribute-debt-and-collateral (liquidated-debt uint) (liquidated-collateral uint))
    (let 
        (
            (redistribution-params (var-get protocol-redistribution-params))
            (total-sbtc-rewards-per-unit (get total-sbtc-rewards-per-unit redistribution-params))
            (total-bsd-rewards-per-unit (get total-bsd-rewards-per-unit redistribution-params))
            (total-stakes (get total-stakes redistribution-params))
            (liquidation-sbtc-rewards (/ (div-round-down (* liquidated-collateral ONE_FULL_UNIT) total-stakes) ONE_FULL_UNIT))
            (liquidation-bsd-rewards (/ (div (* liquidated-debt ONE_FULL_UNIT) total-stakes) ONE_FULL_UNIT))
            (new-total-sbtc-rewards-per-unit (+ total-sbtc-rewards-per-unit liquidation-sbtc-rewards))
            (new-total-bsd-rewards-per-unit (+ total-bsd-rewards-per-unit liquidation-bsd-rewards))
        )
        (var-set protocol-redistribution-params
            (merge 
                redistribution-params
                {
                    total-sbtc-rewards-per-unit: new-total-sbtc-rewards-per-unit,
                    total-bsd-rewards-per-unit: new-total-bsd-rewards-per-unit,
                }
            )
        )
    )
)

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x ONE_FULL_UNIT) (/ y u2)) y))

(define-read-only (div-round-down (x uint) (y uint))
  (/ (* x ONE_FULL_UNIT) y)
)

(define-read-only (div-round-up (x uint) (y uint))
  (/ (+ (* x ONE_FULL_UNIT) (- y u1)) y)
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ ONE_FULL_UNIT u2)) ONE_FULL_UNIT))

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (div (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (div (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a PRECISION)
    (mul (/ a (pow u10 (- decimals-a PRECISION))) b-fixed)
    (mul (* a (pow u10 (- PRECISION decimals-a))) b-fixed)
  )
)



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