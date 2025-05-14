---
title: "Trait imperial-plum-chicken"
draft: true
---
```
(define-read-only (get-timestamp-now)
  (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
)
```
