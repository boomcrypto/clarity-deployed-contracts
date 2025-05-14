---
title: "Trait asset-deployment-109"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant increase u2562)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
    (new-last-liquidity-cumulative-index (+ (get last-liquidity-cumulative-index reserve-data-1) increase))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v2-0 set-reserve sbtc-address
        (merge reserve-data-1 {
          last-liquidity-cumulative-index: new-last-liquidity-cumulative-index,
          last-updated-block: stacks-block-height
          }
        )
      )
    )

    (try! (contract-call? .base-apy-read set-rate increase))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read sbtc-address)))
    (new-last-liquidity-cumulative-index (+ (get last-liquidity-cumulative-index reserve-data-1) increase))
  )
    {
      before: reserve-data-1,
      after: (merge reserve-data-1
        {
          last-liquidity-cumulative-index: new-last-liquidity-cumulative-index,
          last-updated-block: stacks-block-height
        }
      )
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
