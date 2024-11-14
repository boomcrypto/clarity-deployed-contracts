---
title: "Trait asset-deployment-014"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant new-supply-cap u1000000000000)
(define-constant new-borrow-cap u1000000000000)

(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve aeusdc-address
        (merge reserve-data-1 { borrow-cap: new-borrow-cap, supply-cap: new-supply-cap })
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-address)))
  )
    {
      before: reserve-data-1,
      after: (merge reserve-data-1 { borrow-cap: new-borrow-cap, supply-cap: new-supply-cap })
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
