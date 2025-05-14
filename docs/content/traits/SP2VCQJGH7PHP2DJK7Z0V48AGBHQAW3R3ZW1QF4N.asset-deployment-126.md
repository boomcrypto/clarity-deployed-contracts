---
title: "Trait asset-deployment-126"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant params {
  liquidity-rate: u930000,
  sbtc-price: u8040000000000,
  wstx-price: u60330000,
})

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try!
      (contract-call? .incentives set-liquidity-rate
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        .wstx
        (get liquidity-rate params)
      )
    )

    (try!
      (contract-call? .incentives set-price
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        (get sbtc-price params)
      )
    )

    (try!
      (contract-call? .incentives set-price
        .wstx
        (get wstx-price params)
      )
    )

    (var-set executed true)
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
