---
title: "Trait univ2-fees-trait"
draft: true
---
```
(define-trait univ2-fees-trait
  (
  (receive   (bool uint)  (response bool uint))
  (calc-fees (uint)      (response
    {amt-in-adjusted : uint,
     amt-fee-lps     : uint,
     amt-fee-protocol: uint}
     uint))
  (init     (principal) (response bool uint))
))

;;; eof

```
