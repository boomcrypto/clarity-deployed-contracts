---
title: "Trait test-gifter"
draft: true
---
```
(define-public (gift (assets uint))
  (begin
    (try! (contract-call? .mock-usdc transfer assets tx-sender .state-v1 none))
    (try! (accrue-interest))
    (try! (update-total-assets assets))
    (ok true)
  )
)

(define-private (update-total-assets (assets uint))
  (contract-call? .state-v1 increase-total-assets assets)
)

(define-private (accrue-interest)
  (let (
      (accrue-interest-params (unwrap-panic (contract-call? .state-v1 get-accrue-interest-params)))
      (accrued-interest (try! (contract-call? .linear-kinked-ir-v1 accrue-interest
        (get last-accrued-block-time accrue-interest-params)
        (get lp-interest accrue-interest-params)
        (get staked-interest accrue-interest-params)
        (try! (contract-call? .staking-reward-v1 calculate-staking-reward-percentage (contract-call? .staking-v1 get-active-staked-lp-tokens)))
        (get protocol-interest accrue-interest-params)
        (get protocol-reserve-percentage accrue-interest-params)
        (get total-assets accrue-interest-params)))
      )
    )
    (contract-call? .state-v1 set-accrued-interest accrued-interest)
  )
)
```
