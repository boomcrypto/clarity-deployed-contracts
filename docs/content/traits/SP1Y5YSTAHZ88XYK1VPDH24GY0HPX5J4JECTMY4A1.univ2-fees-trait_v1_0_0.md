---
title: "Trait univ2-fees-trait_v1_0_0"
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

  (get-fees ()
      (response
       {
       swap-fee     : {num: uint, den: uint},
       protocol-fee : {num: uint, den: uint},
       }
       uint)
      )

))

;;; eof

```
