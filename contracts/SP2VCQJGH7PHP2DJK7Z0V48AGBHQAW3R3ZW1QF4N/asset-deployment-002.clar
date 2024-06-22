(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant diko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant diko-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2)

(define-constant diko-supply-cap u1000000000000)
(define-constant diko-borrow-cap u1000000000000)

(define-constant curve-params
  {
    base-variable-borrow-rate: u0,
    variable-rate-slope-1: u7000000,
    variable-rate-slope-2: u300000000,
    optimal-utilization-rate: u45000000,
    liquidation-close-factor-percent: u5000000,
    origination-fee-prc: u0,
    reserve-factor: u10000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 init
        diko-z-token
        diko-token
        u6
        diko-supply-cap
        diko-borrow-cap
        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.diko-oracle-v1-1
        diko-z-token
      )
    )
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 add-asset diko-token))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borrowing-enabled diko-token true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borroweable-isolated diko-token))

    ;; Curve parameters
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-base-variable-borrow-rate diko-token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-1 diko-token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-2 diko-token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-optimal-utilization-rate diko-token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-liquidation-close-factor-percent diko-token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-origination-fee-prc diko-token (get origination-fee-prc curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-reserve-factor diko-token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled diko-z-token false))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block diko-z-token burn-block-height))

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
