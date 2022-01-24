(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places

(define-public (migrate-fwp-wstx-wbtc-50-50)
    (let
        (
            (reduce-data (try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .token-wbtc u50000000 u50000000 .fwp-wstx-wbtc-50-50 ONE_8)))            
        )
        (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .token-wbtc u50000000 u50000000 .fwp-wstx-wbtc-50-50-v1-01 (get dx reduce-data) (some (get dy reduce-data)))
    )
)

(define-public (migrate-fwp-wstx-alex-50-50)
    (let
        (
            (reduce-data (try! (contract-call? .fixed-weight-pool reduce-position .token-wstx .age000-governance-token u50000000 u50000000 .fwp-wstx-alex-50-50 ONE_8)))            
        )
        (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .age000-governance-token u50000000 u50000000 .fwp-wstx-alex-50-50-v1-01 (get dx reduce-data) (some (get dy reduce-data)))
    )
)

(define-public (migrate-all)
    (begin
        (try! (migrate-fwp-wstx-alex-50-50))
        (migrate-fwp-wstx-wbtc-50-50)
    )
)