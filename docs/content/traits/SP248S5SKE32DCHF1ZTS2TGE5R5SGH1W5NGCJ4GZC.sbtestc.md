---
title: "Trait sbtestc"
draft: true
---
```
(define-public (get-last-token-id)
  (if true (ok u1) (err u1))
)

(define-public (get-token-uri (token-id uint))
  (ok none)
)

(define-public (get-owner (token-id uint))
  (if true (ok none) (err u1))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if true (ok true) (err u1))
)

(define-private (callsbtc)
  (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-name)
)

```
