---
title: "Trait asset-deployment-076"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststxbtc-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant ststxbtc-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0)

(define-constant ststxbtc-supply-cap u500000000000)
(define-constant ststxbtc-borrow-cap u0)
(define-constant decimals u6)

(define-constant curve-params
  {
    base-variable-borrow-rate: u0,
    variable-rate-slope-1: u7000000,
    variable-rate-slope-2: u300000000,
    optimal-utilization-rate: u45000000,
    liquidation-close-factor-percent: u50000000,
    origination-fee-prc: u0,
    reserve-factor: u10000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .zststxbtc-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zststxbtc-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zststxbtc-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))

    (try! (contract-call? .zststxbtc-token set-approved-contract ststxbtc-z-token true))

    (try!
      (contract-call? .pool-borrow-v2-0 init
        ststxbtc-z-token
        ststxbtc-token
        decimals
        ststxbtc-supply-cap
        ststxbtc-borrow-cap
        .ststxbtc-oracle-v1-0
        ststxbtc-z-token
      )
    )
    (try! (contract-call? .pool-borrow-v2-0 add-asset ststxbtc-token))

    ;; Curve parameters
    (try! (contract-call? .pool-reserve-data set-base-variable-borrow-rate ststxbtc-token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 ststxbtc-token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-2 ststxbtc-token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? .pool-reserve-data set-optimal-utilization-rate ststxbtc-token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent ststxbtc-token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? .pool-reserve-data set-origination-fee-prc ststxbtc-token (get origination-fee-prc curve-params)))
    (try! (contract-call? .pool-reserve-data set-reserve-factor ststxbtc-token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled ststxbtc-z-token false))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block ststxbtc-z-token burn-block-height))

    ;; collateral settings
    (try! 
      (contract-call? .pool-borrow-v2-0 set-usage-as-collateral-enabled
        ststxbtc-token
        true
        u50000000
        u70000000
        u10000000
      )
    )

    (try! (contract-call? .pool-borrow-v2-0 add-isolated-asset ststxbtc-token u400000000000000))

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
