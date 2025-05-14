---
title: "Trait asset-deployment-039"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant base-rate u0)

(define-constant asset-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-0-reserve-v2-0 set-approved-contract (as-contract tx-sender) true))

    (try!
      (contract-call? .pool-0-reserve-v2-0 set-user-index
        'SP1S3JBC47G2VVK0C6W7GT221C4CH3605GH95EAD9
        asset-address
        u100000000
      )
    )

    (try! (contract-call? .pool-0-reserve-v2-0 set-approved-contract (as-contract tx-sender) true))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (begin
    {
      before: (contract-call? .pool-reserve-data-2 get-base-supply-rate-read asset-address),
      after: base-rate
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
