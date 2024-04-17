
(define-constant max-value u340282366920938463463374607431768211455)

(define-constant wstx-supply-cap u5000000000000)
(define-constant wstx-borrow-cap u5000000000000)

(define-constant asset .wstx)
(define-constant z-token .zwstx-v1)

(try!
  (contract-call? .pool-borrow-v1-1
    init
    z-token
    asset
    u6
    wstx-supply-cap
    wstx-borrow-cap
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-3
    asset
  )
)

(contract-call? .pool-borrow-v1-1 add-asset asset)
(contract-call? .pool-borrow-v1-1 set-borrowing-enabled asset true)
(contract-call? .pool-borrow-v1-1 set-borroweable-isolated asset)

(define-constant base u10000)

;; Curve parameters
(contract-call? .pool-reserve-data set-base-variable-borrow-rate asset u0)

(contract-call? .pool-reserve-data set-variable-rate-slope-1 asset u7000000)

(contract-call? .pool-reserve-data set-variable-rate-slope-2 asset u300000000)

(contract-call? .pool-reserve-data set-optimal-utilization-rate asset u45000000)

(contract-call? .pool-reserve-data set-liquidation-close-factor-percent asset u5000000)

(contract-call? .pool-reserve-data set-origination-fee-prc asset u0)

(contract-call? .pool-reserve-data set-reserve-factor asset u10000000)

(try! (contract-call? .zwstx-v1 set-approved-contract .pool-borrow-v1-1 true))
(try! (contract-call? .zwstx-v1 set-approved-contract .liquidation-manager-v1-1 true))
(try! (contract-call? .zwstx-v1 set-approved-contract .pool-0-reserve true))
(try! (contract-call? .zwstx-v1 set-approved-contract .borrow-helper-v2-1 true))
