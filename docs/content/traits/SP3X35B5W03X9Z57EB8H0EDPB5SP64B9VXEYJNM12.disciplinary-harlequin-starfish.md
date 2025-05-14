---
title: "Trait disciplinary-harlequin-starfish"
draft: true
---
```

(define-read-only (get-timestamp-time (block uint))
  (get-stacks-block-info? time block)
)

(define-read-only (get-timestamp-now)
  (get-stacks-block-info? time stacks-block-height)
)

(define-read-only (get-timestamp-minus-1)
  (get-stacks-block-info? time (- stacks-block-height u1))
)

```
