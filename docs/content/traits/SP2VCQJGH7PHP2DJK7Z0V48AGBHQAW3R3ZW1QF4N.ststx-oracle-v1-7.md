---
title: "Trait ststx-oracle-v1-7"
draft: true
---
```
(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-constant stx-den u1000000)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (ratio
      (try!
        (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2
          get-stx-per-ststx
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1
        )
      )
    )
    (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
      get-value
      "STX/USD"
    )))
  )
    ;; convert to fixed precision
    (ok (/ (* (get value oracle-data) ratio) stx-den))
  )
)

(define-read-only (get-price)
  (let (
    (total-stx-amount (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1 get-total-stx)))
    (ststxbtc-supply (unwrap-panic (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token get-total-supply)))
    (stx-for-ststx (- total-stx-amount ststxbtc-supply))
    (ratio (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2 get-stx-per-ststx-helper stx-for-ststx))
    (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
      get-value
      "STX/USD"
    )))
  )
    ;; convert to fixed precision
    (/ (* (get value oracle-data) ratio) stx-den)
  )
)

```
