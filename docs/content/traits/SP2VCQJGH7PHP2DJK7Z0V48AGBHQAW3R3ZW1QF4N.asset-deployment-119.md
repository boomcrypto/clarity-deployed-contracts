---
title: "Trait asset-deployment-119"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant stx-address .wstx)
(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)

(define-constant stx-oracle .stx-oracle-v1-4)
(define-constant ststx-oracle .ststx-oracle-v1-5)
(define-constant ststxbtc-oracle .ststxbtc-oracle-v1-1)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read stx-address)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try!
      (contract-call? .pool-borrow-v2-0 set-reserve stx-address
        (merge reserve-data-1 { oracle: stx-oracle })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-0 set-reserve ststx-address
        (merge reserve-data-2 { oracle: ststx-oracle })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-0 set-reserve ststxbtc-address
        (merge reserve-data-3 { oracle: ststxbtc-oracle })
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read stx-address)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-address)))
  )

    (print { old: reserve-data-1, new: (merge reserve-data-1 { oracle: stx-oracle }) })
    (print { old: reserve-data-2, new: (merge reserve-data-2 { oracle: ststx-oracle }) })
    (print { old: reserve-data-3, new: (merge reserve-data-3 { oracle: ststxbtc-oracle }) })

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
