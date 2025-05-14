---
title: "Trait ststxbtc-oracle-v1-1"
draft: true
---
```
(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
      get-value
      "STX/USD"
    )))
  )
    (ok (get value oracle-data))
  )
)


;; prices are fixed to 8 decimals
(define-read-only (get-price)
  (let (
    (oracle-data (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle
      get-value
      "STX/USD"
    )))
  )
    (get value oracle-data)
  )
)

```
