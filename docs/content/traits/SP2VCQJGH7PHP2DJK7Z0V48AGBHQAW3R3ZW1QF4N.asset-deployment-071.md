---
title: "Trait asset-deployment-071"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! 
        (contract-call? .pool-borrow-v2-0 set-usage-as-collateral-enabled
            sbtc-address
            true
            u50000000
            u70000000
            u10000000
        )
    )

    (try! (contract-call? .pool-borrow-v2-0 add-isolated-asset sbtc-address u100000000000000))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent sbtc-address u50000000))

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
      after: reserve-data-1
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
