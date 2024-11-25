(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant usdh-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant usdh-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v1-2)
(define-constant usdh-oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usdh-oracle-v1-0)

(define-constant usdh-supply-cap u100000000000000)
(define-constant usdh-borrow-cap u5000000000000)

(define-constant decimals u8)

(define-constant curve-params
  {
    base-variable-borrow-rate: u0,
    variable-rate-slope-1: u6000000,
    variable-rate-slope-2: u87000000,
    optimal-utilization-rate: u80000000,
    liquidation-close-factor-percent: u5000000,
    origination-fee-prc: u0,
    reserve-factor: u10000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 init
        usdh-z-token
        usdh-token
        decimals
        usdh-supply-cap
        usdh-borrow-cap
        usdh-oracle
        usdh-z-token
      )
    )
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 add-asset usdh-token))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borrowing-enabled usdh-token true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borroweable-isolated usdh-token))

    ;; Curve parameters
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-base-variable-borrow-rate usdh-token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-1 usdh-token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-2 usdh-token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-optimal-utilization-rate usdh-token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-liquidation-close-factor-percent usdh-token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-origination-fee-prc usdh-token (get origination-fee-prc curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-reserve-factor usdh-token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled usdh-token false))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block usdh-token burn-block-height))

    (var-set executed true)
    (ok true)
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set executed true))
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)
