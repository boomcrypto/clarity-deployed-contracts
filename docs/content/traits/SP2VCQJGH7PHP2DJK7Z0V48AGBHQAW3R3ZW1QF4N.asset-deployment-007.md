---
title: "Trait asset-deployment-007"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant new-supply-cap u15000000000000)
;; (define-constant new-borrow-cap u1000000000000)

(define-constant diko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read diko-token)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve diko-token
        (merge reserve-data-1 { supply-cap: new-supply-cap })
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read diko-token)))
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
