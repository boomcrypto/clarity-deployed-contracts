---
title: "Trait robust-tan-hamster"
draft: true
---
```

(define-constant stx-den u1000000)

(define-private (convert-stx-to-ststx (stx-price uint))
  (let (
    (ratio
      (try!
        (contract-call? 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v2
          get-stx-per-ststx
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1
        )
      )
    )
  )
    (ok (/ (* stx-price ratio) stx-den))
  )
)
```
