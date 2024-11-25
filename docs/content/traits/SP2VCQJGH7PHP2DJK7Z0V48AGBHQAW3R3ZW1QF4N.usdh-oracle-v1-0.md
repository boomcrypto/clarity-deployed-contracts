---
title: "Trait usdh-oracle-v1-0"
draft: true
---
```
(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-read-only (from-fixed-to-precision (a uint) (decimals-a uint))
  (contract-call? .math-v1-2 from-fixed-to-precision a decimals-a)
)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (begin
    (asserts! true (err u1))
    ;; convert to fixed precision
    (ok u100000000)
  )
)


;; prices are fixed to 8 decimals
(define-read-only (get-price)
  (begin
    ;; convert to fixed precision
    u100000000
  )
)

```
