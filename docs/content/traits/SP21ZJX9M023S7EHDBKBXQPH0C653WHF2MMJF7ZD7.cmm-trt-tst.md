---
title: "Trait cmm-trt-tst"
draft: true
---
```
(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u0) u0) tx-sender 'SP21ZJX9M023S7EHDBKBXQPH0C653WHF2MMJF7ZD7))
    (ok true)))
```
