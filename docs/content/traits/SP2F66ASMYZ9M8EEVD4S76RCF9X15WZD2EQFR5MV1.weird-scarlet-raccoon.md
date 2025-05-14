---
title: "Trait weird-scarlet-raccoon"
draft: true
---
```
(define-read-only (get-last-block-height) 
  (ok stacks-block-height)
)

(define-read-only (get-last-block-time)
  (match (get-stacks-block-info? time stacks-block-height) 
    time (ok time)
    (err u0))
)
```
