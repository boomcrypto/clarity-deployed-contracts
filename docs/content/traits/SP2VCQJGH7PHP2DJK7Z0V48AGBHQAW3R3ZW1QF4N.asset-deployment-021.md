---
title: "Trait asset-deployment-021"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v1-2)
(define-constant oracle 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.susdt-oracle-v1-0)

(define-constant supply-cap u100000000000000)
(define-constant borrow-cap u5000000000000)

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

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 init
        z-token
        token
        decimals
        supply-cap
        borrow-cap
        oracle
        z-token
      )
    )
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 add-asset token))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borrowing-enabled token true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v1-2 set-borroweable-isolated token))

    ;; Curve parameters
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-base-variable-borrow-rate token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-1 token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-2 token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-optimal-utilization-rate token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-liquidation-close-factor-percent token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-origination-fee-prc token (get origination-fee-prc curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-reserve-factor token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled token false))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block token burn-block-height))

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

```
