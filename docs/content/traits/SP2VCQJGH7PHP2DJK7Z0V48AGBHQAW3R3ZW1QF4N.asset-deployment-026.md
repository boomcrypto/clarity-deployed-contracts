---
title: "Trait asset-deployment-026"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant sbtc-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0)

(define-constant sbtc-supply-cap u1000000000000)
(define-constant sbtc-borrow-cap u0)
(define-constant decimals u8)

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

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))

    (try!
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 init
        sbtc-z-token
        sbtc-token
        decimals
        sbtc-supply-cap
        sbtc-borrow-cap
        .sbtc-oracle-v1-0
        sbtc-z-token
      )
    )
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 add-asset sbtc-token))

    ;; ;; Curve parameters
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-base-variable-borrow-rate sbtc-token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-1 sbtc-token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-variable-rate-slope-2 sbtc-token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-optimal-utilization-rate sbtc-token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-liquidation-close-factor-percent sbtc-token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-origination-fee-prc sbtc-token (get origination-fee-prc curve-params)))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-reserve-factor sbtc-token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled sbtc-z-token false))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block sbtc-z-token burn-block-height))

    (asserts! false (err u20))
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
