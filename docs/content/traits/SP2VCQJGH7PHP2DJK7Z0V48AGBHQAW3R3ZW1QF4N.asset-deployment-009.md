---
title: "Trait asset-deployment-009"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant new-supply-cap u25000000000000)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-1
        (merge reserve-data-1 { supply-cap: new-supply-cap })
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    {
      before: reserve-data-1,
      after: (merge reserve-data-1 { supply-cap: new-supply-cap })
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
