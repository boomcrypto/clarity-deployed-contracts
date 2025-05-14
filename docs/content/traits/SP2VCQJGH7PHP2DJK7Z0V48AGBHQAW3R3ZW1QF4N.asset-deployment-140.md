---
title: "Trait asset-deployment-140"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant sbtc-borrow-cap u1000000000)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-borrow-v2-0-2 set-borrowing-enabled sbtc-address true))
    (try! (contract-call? .pool-borrow-v2-0-2 set-borroweable-isolated sbtc-address))

    (try! (contract-call? .pool-reserve-data set-base-variable-borrow-rate sbtc-address u3000000))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 sbtc-address u4000000))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-2 sbtc-address u300000000))
    (try! (contract-call? .pool-reserve-data set-optimal-utilization-rate sbtc-address u80000000))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent sbtc-address u25000000))
    (try! (contract-call? .pool-reserve-data set-origination-fee-prc sbtc-address u0))
    (try! (contract-call? .pool-reserve-data set-reserve-factor sbtc-address u10000000))

    (try!
      (contract-call? .pool-borrow-v2-0-2 set-reserve sbtc-address
        (merge reserve-data-1 { borrow-cap: sbtc-borrow-cap })
      )
    )


    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
  )
    {
      before: reserve-data-1,
      after: (merge reserve-data-1 { borrow-cap: sbtc-borrow-cap })
    }
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
