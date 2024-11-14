---
title: "Trait curve-fees-trait"
draft: true
---
```
(define-trait curve-fees-trait
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
